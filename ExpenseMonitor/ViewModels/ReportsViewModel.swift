//
//  ReportsViewModel.swift
//  ExpenseMonitor
//

import Foundation

enum ReportGranularity: String, CaseIterable {
    case week = "Week"
    case month = "Month"
    case year = "Year"
    case custom = "Custom"

    /// nil for `.custom` — an arbitrary range has no matching calendar unit.
    var calendarComponent: Calendar.Component? {
        switch self {
        case .week: return .weekOfYear
        case .month: return .month
        case .year: return .year
        case .custom: return nil
        }
    }
}

@Observable
class ReportsViewModel {
    private let transactionRepository: TransactionRepository
    private let loanRepository: LoanRepository
    private let chitFundRepository: ChitFundRepository

    private var transactions: [Transaction] = []
    private var loans: [Loan] = []
    private var chitFunds: [ChitFund] = []

    var granularity: ReportGranularity = .month
    var referenceDate: Date = Date()
    var customRange: DateInterval?

    init(transactionRepository: TransactionRepository, loanRepository: LoanRepository, chitFundRepository: ChitFundRepository) {
        self.transactionRepository = transactionRepository
        self.loanRepository = loanRepository
        self.chitFundRepository = chitFundRepository
        loadData()
    }

    func loadData() {
        transactions = transactionRepository.fetchAll()
        loans = loanRepository.fetchAll()
        chitFunds = chitFundRepository.fetchAll()
    }

    var periodInterval: DateInterval {
        if granularity == .custom {
            return customRange ?? DateInterval(start: referenceDate, duration: 0)
        }
        guard let component = granularity.calendarComponent else {
            return DateInterval(start: referenceDate, duration: 0)
        }
        return Calendar.current.dateInterval(of: component, for: referenceDate)
            ?? DateInterval(start: referenceDate, duration: 0)
    }

    /// For calendar granularities, "previous" means the prior calendar unit (handles Feb being
    /// shorter than Jan, etc). For a custom range, there's no calendar unit to shift by, so
    /// "previous" is defined as an equal-duration window immediately before the picked range.
    private var previousPeriodInterval: DateInterval {
        if granularity == .custom {
            let interval = periodInterval
            let previousStart = interval.start.addingTimeInterval(-interval.duration)
            return DateInterval(start: previousStart, end: interval.start)
        }
        guard let component = granularity.calendarComponent else {
            return DateInterval(start: referenceDate, duration: 0)
        }
        let previousReferenceDate = Calendar.current.date(byAdding: component, value: -1, to: referenceDate) ?? referenceDate
        return Calendar.current.dateInterval(of: component, for: previousReferenceDate)
            ?? DateInterval(start: previousReferenceDate, duration: 0)
    }

    var filteredTransactions: [Transaction] {
        let interval = periodInterval
        return transactions.filter { interval.contains($0.date) }
    }

    private var previousPeriodTransactions: [Transaction] {
        let interval = previousPeriodInterval
        return transactions.filter { interval.contains($0.date) }
    }

    var income: Double {
        filteredTransactions.filter { $0.type == .income }.reduce(0) { $0 + $1.amount }
    }

    var expense: Double {
        filteredTransactions.filter { $0.type == .expense }.reduce(0) { $0 + $1.amount }
    }

    var netBalance: Double {
        income - expense
    }

    var spendingPoints: [SpendingPoint] {
        expenseSpendingPoints(from: filteredTransactions.filter { $0.type == .expense })
    }

    var breakdownData: [CategoryBreakdown] {
        expenseCategoryBreakdown(from: filteredTransactions.filter { $0.type == .expense })
    }

    func transactions(onDate date: Date) -> [Transaction] {
        filteredTransactions.filter { $0.type == .expense && Calendar.current.isDate($0.date, inSameDayAs: date) }
    }

    func transactions(inCategory category: String) -> [Transaction] {
        filteredTransactions.filter { $0.type == .expense && $0.category == category }
    }

    private var previousExpense: Double {
        previousPeriodTransactions.filter { $0.type == .expense }.reduce(0) { $0 + $1.amount }
    }

    var expenseDelta: Double? {
        guard previousExpense > 0 else { return nil }
        return expense - previousExpense
    }

    var expenseDeltaPercent: Double? {
        guard let expenseDelta, previousExpense > 0 else { return nil }
        return (expenseDelta / previousExpense) * 100
    }

    func goToPreviousPeriod() {
        guard let component = granularity.calendarComponent else { return }
        referenceDate = Calendar.current.date(byAdding: component, value: -1, to: referenceDate) ?? referenceDate
    }

    func goToNextPeriod() {
        guard let component = granularity.calendarComponent else { return }
        referenceDate = Calendar.current.date(byAdding: component, value: 1, to: referenceDate) ?? referenceDate
    }

    // MARK: EMI/Chit burden — always the real current calendar month, independent of the browsed period above.

    private var currentMonthTransactions: [Transaction] {
        transactions.filter { Calendar.current.isDate($0.date, equalTo: Date(), toGranularity: .month) }
    }

    private var currentMonthIncome: Double {
        currentMonthTransactions.filter { $0.type == .income }.reduce(0) { $0 + $1.amount }
    }

    private var totalDueThisMonth: Double {
        let cutoff = startOfNextCalendarMonth()
        return dueAmount(for: loans, before: cutoff) + dueAmount(for: chitFunds, before: cutoff)
    }

    var burdenPercent: Double? {
        guard currentMonthIncome > 0 else { return nil }
        return (totalDueThisMonth / currentMonthIncome) * 100
    }

    // MARK: Year in Review — only meaningful when browsing a full calendar year with real data.

    var yearInReview: YearInReview? {
        guard granularity == .year else { return nil }
        let yearTransactions = filteredTransactions
        guard !yearTransactions.isEmpty else { return nil }

        let calendar = Calendar.current
        let year = calendar.component(.year, from: referenceDate)
        let expenseOnly = yearTransactions.filter { $0.type == .expense }

        let topCategory = expenseCategoryBreakdown(from: expenseOnly).first

        let busiestMonth: (label: String, amount: Double)? = Dictionary(grouping: expenseOnly) { calendar.component(.month, from: $0.date) }
            .map { month, transactions in (month, transactions.reduce(0) { $0 + $1.amount }) }
            .max { $0.1 < $1.1 }
            .map { month, amount in (calendar.monthSymbols[month - 1], amount) }

        let biggestExpense = expenseOnly.max { $0.amount < $1.amount }

        let totalEMIChitPaid = yearTransactions
            .filter { $0.linkedLoanID != nil || $0.linkedChitFundID != nil }
            .reduce(0) { $0 + $1.amount }

        return YearInReview(
            year: year,
            income: income,
            expense: expense,
            netSavings: netBalance,
            transactionCount: yearTransactions.count,
            topCategory: topCategory,
            busiestMonth: busiestMonth,
            biggestExpense: biggestExpense,
            totalEMIChitPaid: totalEMIChitPaid
        )
    }
}
