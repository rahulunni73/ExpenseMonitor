//
//  ExpensesViewModel.swift
//  ExpenseMonitor
//

import SwiftUI

struct ExpenseDaySection: Identifiable {
    let id: Date
    let date: Date
    let expenses: [Expense]

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
    let expenses: [Expense]
    let task: Task<Void, Never>
}

@Observable
class ExpensesViewModel {


    private let repository: ExpenseRepository
    var expenses: [Expense] = []
    var selectedMonth: Date = Date()
    var selectedDay: Date? = nil
    var searchText: String = ""
    var typeFilter: CategoryType? = nil
    var categoryFilters: Set<String> = []
    var pendingDeletion: PendingDeletion?

    init(repository: ExpenseRepository) {
        self.repository = repository
        loadExpenses()
    }

    var filteredExpenses: [Expense] {
        expenses
            .filter { expense in
                if let selectedDay {
                    return Calendar.current.isDate(expense.expenseDate, inSameDayAs: selectedDay)
                } else {
                    return Calendar.current.isDate(expense.expenseDate, equalTo: selectedMonth, toGranularity: .month)
                }
            }
            .filter { typeFilter == nil || $0.type == typeFilter }
            .filter { categoryFilters.isEmpty || categoryFilters.contains($0.category) }
            .filter { searchText.isEmpty || $0.title.localizedCaseInsensitiveContains(searchText) }
    }

    var totalExpense: Double {
        filteredExpenses.filter { $0.type == .expense }.reduce(0) { $0 + $1.amount }
    }

    var totalIncome: Double {
        filteredExpenses.filter { $0.type == .income }.reduce(0) { $0 + $1.amount }
    }

    var balance: Double {
        totalIncome - totalExpense
    }

    var groupedExpenses: [ExpenseDaySection] {
        let grouped = Dictionary(grouping: filteredExpenses) { expense in
            Calendar.current.startOfDay(for: expense.expenseDate)
        }
        return grouped.keys.sorted(by: >).map { day in
            let dayExpenses = (grouped[day] ?? []).sorted { $0.expenseDate > $1.expenseDate }
            return ExpenseDaySection(id: day, date: day, expenses: dayExpenses)
        }
    }

    func loadExpenses() {
        let fetched = repository.fetchAll()
        if let pendingDeletion {
            let pendingIDs = Set(pendingDeletion.expenses.map(\.id))
            expenses = fetched.filter { !pendingIDs.contains($0.id) }
        } else {
            expenses = fetched
        }
    }

    func addExpense(_ expense: Expense) {
        repository.add(expense)
        loadExpenses()
    }

    func deleteItems(from sectionExpenses: [Expense], at offsets: IndexSet) {
        beginPendingDeletion(offsets.map { sectionExpenses[$0] })
    }

    func deleteExpense(_ expense: Expense) {
        beginPendingDeletion([expense])
    }

    private func beginPendingDeletion(_ itemsToDelete: [Expense]) {
        commitPendingDeletion()

        let deletedIDs = Set(itemsToDelete.map(\.id))

        let task = Task { @MainActor [weak self] in
            try? await Task.sleep(for: .seconds(4))
            guard !Task.isCancelled else { return }
            self?.commitPendingDeletion()
        }
        withAnimation {
            expenses.removeAll { deletedIDs.contains($0.id) }
            pendingDeletion = PendingDeletion(expenses: itemsToDelete, task: task)
        }
    }

    func undoDelete() {
        guard let pendingDeletion else { return }
        pendingDeletion.task.cancel()
        withAnimation {
            expenses.append(contentsOf: pendingDeletion.expenses)
            self.pendingDeletion = nil
        }
    }

    private func commitPendingDeletion() {
        guard let pendingDeletion else { return }
        pendingDeletion.expenses.forEach { repository.delete($0) }
        self.pendingDeletion = nil
    }
}
