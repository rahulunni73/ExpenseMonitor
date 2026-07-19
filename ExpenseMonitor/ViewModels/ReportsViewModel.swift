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
    private let expenseRepository: ExpenseRepository
    private let loanRepository: LoanRepository
    private let chitFundRepository: ChitFundRepository

    private var expenses: [Expense] = []
    private var loans: [Loan] = []
    private var chitFunds: [ChitFund] = []

    var granularity: ReportGranularity = .month
    var referenceDate: Date = Date()
    var customRange: DateInterval?

    init(expenseRepository: ExpenseRepository, loanRepository: LoanRepository, chitFundRepository: ChitFundRepository) {
        self.expenseRepository = expenseRepository
        self.loanRepository = loanRepository
        self.chitFundRepository = chitFundRepository
        loadData()
    }

    func loadData() {
        expenses = expenseRepository.fetchAll()
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

    var filteredExpenses: [Expense] {
        let interval = periodInterval
        return expenses.filter { interval.contains($0.expenseDate) }
    }

    private var previousPeriodExpenses: [Expense] {
        let interval = previousPeriodInterval
        return expenses.filter { interval.contains($0.expenseDate) }
    }

    var income: Double {
        filteredExpenses.filter { $0.type == .income }.reduce(0) { $0 + $1.amount }
    }

    var expense: Double {
        filteredExpenses.filter { $0.type == .expense }.reduce(0) { $0 + $1.amount }
    }

    var netBalance: Double {
        income - expense
    }

    var spendingPoints: [SpendingPoint] {
        expenseSpendingPoints(from: filteredExpenses.filter { $0.type == .expense })
    }

    var breakdownData: [CategoryBreakdown] {
        expenseCategoryBreakdown(from: filteredExpenses.filter { $0.type == .expense })
    }

    func expenses(onDate date: Date) -> [Expense] {
        filteredExpenses.filter { $0.type == .expense && Calendar.current.isDate($0.expenseDate, inSameDayAs: date) }
    }

    func expenses(inCategory category: String) -> [Expense] {
        filteredExpenses.filter { $0.type == .expense && $0.category == category }
    }

    private var previousExpense: Double {
        previousPeriodExpenses.filter { $0.type == .expense }.reduce(0) { $0 + $1.amount }
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

    private var currentMonthExpenses: [Expense] {
        expenses.filter { Calendar.current.isDate($0.expenseDate, equalTo: Date(), toGranularity: .month) }
    }

    private var currentMonthIncome: Double {
        currentMonthExpenses.filter { $0.type == .income }.reduce(0) { $0 + $1.amount }
    }

    private var totalDueThisMonth: Double {
        let cutoff = startOfNextCalendarMonth()
        return dueAmount(for: loans, before: cutoff) + dueAmount(for: chitFunds, before: cutoff)
    }

    var burdenPercent: Double? {
        guard currentMonthIncome > 0 else { return nil }
        return (totalDueThisMonth / currentMonthIncome) * 100
    }
}
