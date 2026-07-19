//
//  HomeViewModel.swift
//  ExpenseMonitor
//

import Foundation

@Observable
class HomeViewModel {
    private let expenseRepository: ExpenseRepository
    private let loanRepository: LoanRepository
    private let chitFundRepository: ChitFundRepository

    private var expenses: [Expense] = []
    private var loans: [Loan] = []
    private var chitFunds: [ChitFund] = []

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

    private var currentMonthExpenses: [Expense] {
        expenses.filter { Calendar.current.isDate($0.expenseDate, equalTo: Date(), toGranularity: .month) }
    }

    var income: Double {
        currentMonthExpenses.filter { $0.type == .income }.reduce(0) { $0 + $1.amount }
    }

    var expense: Double {
        currentMonthExpenses.filter { $0.type == .expense }.reduce(0) { $0 + $1.amount }
    }

    var netBalance: Double {
        income - expense
    }

    var recentTransactions: [Expense] {
        Array(currentMonthExpenses.sorted { $0.expenseDate > $1.expenseDate }.prefix(5))
    }

    var hasLoans: Bool {
        loans.contains { $0.type == .loan }
    }

    var hasCreditCards: Bool {
        loans.contains { $0.type == .creditCard }
    }

    var hasChitFunds: Bool {
        !chitFunds.isEmpty
    }

    private func paidAmount(forLoanIDs loanIDs: Set<String>) -> Double {
        currentMonthExpenses
            .filter { expense in
                guard let linkedLoanID = expense.linkedLoanID else { return false }
                return loanIDs.contains(linkedLoanID)
            }
            .reduce(0) { $0 + $1.amount }
    }

    var loanDueAmount: Double {
        dueAmount(for: loans.filter { $0.type == .loan }, before: startOfNextCalendarMonth())
    }

    var loanPaidAmount: Double {
        paidAmount(forLoanIDs: Set(loans.filter { $0.type == .loan }.map(\.id)))
    }

    var creditCardDueAmount: Double {
        dueAmount(for: loans.filter { $0.type == .creditCard }, before: startOfNextCalendarMonth())
    }

    var creditCardPaidAmount: Double {
        paidAmount(forLoanIDs: Set(loans.filter { $0.type == .creditCard }.map(\.id)))
    }

    var chitDueAmount: Double {
        dueAmount(for: chitFunds, before: startOfNextCalendarMonth())
    }

    var chitPaidAmount: Double {
        let chitIDs = Set(chitFunds.map(\.id))
        return currentMonthExpenses
            .filter { expense in
                guard let linkedChitFundID = expense.linkedChitFundID else { return false }
                return chitIDs.contains(linkedChitFundID)
            }
            .reduce(0) { $0 + $1.amount }
    }
}
