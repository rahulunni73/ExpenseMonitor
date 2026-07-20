//
//  TransactionsViewModel.swift
//  ExpenseMonitor
//

import SwiftUI

struct TransactionDaySection: Identifiable {
    let id: Date
    let date: Date
    let transactions: [Transaction]

    var title: String {
        if Calendar.current.isDateInToday(date) {
            return "Today"
        } else if Calendar.current.isDateInYesterday(date) {
            return "Yesterday"
        } else {
            return date.formatted(.dateTime.weekday(.wide).day().month(.wide))
        }
    }
}

struct PendingDeletion {
    let transactions: [Transaction]
    let task: Task<Void, Never>
}

@Observable
class TransactionsViewModel {


    private let repository: TransactionRepository
    var transactions: [Transaction] = []
    var selectedMonth: Date = Date()
    var selectedDay: Date? = nil
    var searchText: String = ""
    var typeFilter: CategoryType? = nil
    var categoryFilters: Set<String> = []
    var pendingDeletion: PendingDeletion?

    init(repository: TransactionRepository) {
        self.repository = repository
        loadTransactions()
    }

    var filteredTransactions: [Transaction] {
        transactions
            .filter { transaction in
                if let selectedDay {
                    return Calendar.current.isDate(transaction.date, inSameDayAs: selectedDay)
                } else {
                    return Calendar.current.isDate(transaction.date, equalTo: selectedMonth, toGranularity: .month)
                }
            }
            .filter { typeFilter == nil || $0.type == typeFilter }
            .filter { categoryFilters.isEmpty || categoryFilters.contains($0.category) }
            .filter { searchText.isEmpty || $0.title.localizedCaseInsensitiveContains(searchText) }
    }

    var totalExpense: Double {
        filteredTransactions.filter { $0.type == .expense }.reduce(0) { $0 + $1.amount }
    }

    var totalIncome: Double {
        filteredTransactions.filter { $0.type == .income }.reduce(0) { $0 + $1.amount }
    }

    var balance: Double {
        totalIncome - totalExpense
    }

    var groupedTransactions: [TransactionDaySection] {
        let grouped = Dictionary(grouping: filteredTransactions) { transaction in
            Calendar.current.startOfDay(for: transaction.date)
        }
        return grouped.keys.sorted(by: >).map { day in
            let dayTransactions = (grouped[day] ?? []).sorted { $0.date > $1.date }
            return TransactionDaySection(id: day, date: day, transactions: dayTransactions)
        }
    }

    func loadTransactions() {
        let fetched = repository.fetchAll()
        if let pendingDeletion {
            let pendingIDs = Set(pendingDeletion.transactions.map(\.id))
            transactions = fetched.filter { !pendingIDs.contains($0.id) }
        } else {
            transactions = fetched
        }
    }

    func addTransaction(_ transaction: Transaction) {
        repository.add(transaction)
        loadTransactions()
    }

    func deleteItems(from sectionTransactions: [Transaction], at offsets: IndexSet) {
        beginPendingDeletion(offsets.map { sectionTransactions[$0] })
    }

    func deleteTransaction(_ transaction: Transaction) {
        beginPendingDeletion([transaction])
    }

    private func beginPendingDeletion(_ itemsToDelete: [Transaction]) {
        commitPendingDeletion()

        let deletedIDs = Set(itemsToDelete.map(\.id))

        let task = Task { @MainActor [weak self] in
            try? await Task.sleep(for: .seconds(4))
            guard !Task.isCancelled else { return }
            self?.commitPendingDeletion()
        }
        withAnimation {
            transactions.removeAll { deletedIDs.contains($0.id) }
            pendingDeletion = PendingDeletion(transactions: itemsToDelete, task: task)
        }
    }

    func undoDelete() {
        guard let pendingDeletion else { return }
        pendingDeletion.task.cancel()
        withAnimation {
            transactions.append(contentsOf: pendingDeletion.transactions)
            self.pendingDeletion = nil
        }
    }

    private func commitPendingDeletion() {
        guard let pendingDeletion else { return }
        pendingDeletion.transactions.forEach { repository.delete($0) }
        self.pendingDeletion = nil
    }
}
