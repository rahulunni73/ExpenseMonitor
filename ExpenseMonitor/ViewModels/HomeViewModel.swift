//
//  HomeViewModel.swift
//  ExpenseMonitor
//

import Foundation

@Observable
class HomeViewModel {
    private let transactionRepository: TransactionRepository
    private let loanRepository: LoanRepository
    private let chitFundRepository: ChitFundRepository

    private var transactions: [Transaction] = []
    private var loans: [Loan] = []
    private var chitFunds: [ChitFund] = []

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

    private var currentMonthTransactions: [Transaction] {
        transactions.filter { Calendar.current.isDate($0.date, equalTo: Date(), toGranularity: .month) }
    }

    var income: Double {
        currentMonthTransactions.filter { $0.type == .income }.reduce(0) { $0 + $1.amount }
    }

    var expense: Double {
        currentMonthTransactions.filter { $0.type == .expense }.reduce(0) { $0 + $1.amount }
    }

    var netBalance: Double {
        income - expense
    }

    var recentTransactions: [Transaction] {
        Array(currentMonthTransactions.sorted { $0.date > $1.date }.prefix(5))
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
        currentMonthTransactions
            .filter { transaction in
                guard let linkedLoanID = transaction.linkedLoanID else { return false }
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
        return currentMonthTransactions
            .filter { transaction in
                guard let linkedChitFundID = transaction.linkedChitFundID else { return false }
                return chitIDs.contains(linkedChitFundID)
            }
            .reduce(0) { $0 + $1.amount }
    }
}
