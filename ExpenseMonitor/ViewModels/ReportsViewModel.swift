//
//  ReportsViewModel.swift
//  ExpenseMonitor
//

import Foundation

enum ReportGranularity: String, CaseIterable {
    case week = "Week"
    case month = "Month"
    case year = "Year"

    var calendarComponent: Calendar.Component {
        switch self {
        case .week: return .weekOfYear
        case .month: return .month
        case .year: return .year
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
        Calendar.current.dateInterval(of: granularity.calendarComponent, for: referenceDate)
            ?? DateInterval(start: referenceDate, duration: 0)
    }

    private var previousPeriodInterval: DateInterval {
        let previousReferenceDate = Calendar.current.date(byAdding: granularity.calendarComponent, value: -1, to: referenceDate) ?? referenceDate
        return Calendar.current.dateInterval(of: granularity.calendarComponent, for: previousReferenceDate)
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
        referenceDate = Calendar.current.date(byAdding: granularity.calendarComponent, value: -1, to: referenceDate) ?? referenceDate
    }

    func goToNextPeriod() {
        referenceDate = Calendar.current.date(byAdding: granularity.calendarComponent, value: 1, to: referenceDate) ?? referenceDate
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
