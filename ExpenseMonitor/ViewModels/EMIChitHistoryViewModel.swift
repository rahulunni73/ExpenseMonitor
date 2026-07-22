//
//  EMIChitHistoryViewModel.swift
//  ExpenseMonitor
//

import Foundation

struct EMIMonthGroup: Identifiable {
    let date: Date
    let total: Double
    let transactions: [Transaction]
    var id: Date { date }
}

struct EMIYearGroup: Identifiable {
    let year: Int
    let total: Double
    let months: [EMIMonthGroup]
    var id: Int { year }
}

struct UpcomingMonthGroup: Identifiable {
    let date: Date
    let total: Double
    var id: Date { date }
}

struct UpcomingYearGroup: Identifiable {
    let year: Int
    let total: Double
    let months: [UpcomingMonthGroup]
    var id: Int { year }
}

@Observable
class EMIChitHistoryViewModel {
    private let transactionRepository: TransactionRepository
    private let loanRepository: LoanRepository
    private let chitFundRepository: ChitFundRepository

    var yearGroups: [EMIYearGroup] = []
    var upcomingYearGroups: [UpcomingYearGroup] = []

    init(transactionRepository: TransactionRepository, loanRepository: LoanRepository, chitFundRepository: ChitFundRepository) {
        self.transactionRepository = transactionRepository
        self.loanRepository = loanRepository
        self.chitFundRepository = chitFundRepository
        loadData()
    }

    func loadData() {
        loadPaidHistory()
        loadUpcoming()
    }

    private func loadPaidHistory() {
        let emiTransactions = transactionRepository.fetchAll()
            .filter { $0.linkedLoanID != nil || $0.linkedChitFundID != nil }

        let byYear = Dictionary(grouping: emiTransactions) { Calendar.current.component(.year, from: $0.date) }

        yearGroups = byYear.map { year, transactions in
            let byMonth = Dictionary(grouping: transactions) {
                Calendar.current.dateInterval(of: .month, for: $0.date)?.start ?? $0.date
            }
            let months = byMonth.map { start, transactions in
                EMIMonthGroup(date: start, total: transactions.reduce(0) { $0 + $1.amount }, transactions: transactions)
            }.sorted { $0.date < $1.date }

            return EMIYearGroup(year: year, total: transactions.reduce(0) { $0 + $1.amount }, months: months)
        }.sorted { $0.year < $1.year }
    }

    /// Every not-yet-paid installment/contribution across all loans and chit funds, projected
    /// from each schedule's own due dates — grouped the same way as the paid history, but
    /// ordered soonest-first since these are still ahead, not behind.
    private func loadUpcoming() {
        var entries: [(date: Date, amount: Double)] = []

        for loan in loanRepository.fetchAll() {
            for installment in loan.installments where !installment.isPaid {
                entries.append((installment.dueDate, loan.installmentAmount))
            }
        }
        for chitFund in chitFundRepository.fetchAll() {
            for contribution in chitFund.contributions where !contribution.isPaid {
                entries.append((contribution.dueDate, chitFund.monthlyContribution))
            }
        }

        let byYear = Dictionary(grouping: entries) { Calendar.current.component(.year, from: $0.date) }

        upcomingYearGroups = byYear.map { year, entries in
            let byMonth = Dictionary(grouping: entries) {
                Calendar.current.dateInterval(of: .month, for: $0.date)?.start ?? $0.date
            }
            let months = byMonth.map { start, entries in
                UpcomingMonthGroup(date: start, total: entries.reduce(0) { $0 + $1.amount })
            }.sorted { $0.date < $1.date }

            return UpcomingYearGroup(year: year, total: entries.reduce(0) { $0 + $1.amount }, months: months)
        }.sorted { $0.year < $1.year }
    }
}
