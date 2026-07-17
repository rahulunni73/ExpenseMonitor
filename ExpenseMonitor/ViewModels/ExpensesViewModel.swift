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

@Observable
class ExpensesViewModel {
    
    
    private let repository: ExpenseRepository
    var expenses: [Expense] = []
    var selectedMonth: Date = Date()
    var selectedDay: Date? = nil
    var searchText: String = ""
    var typeFilter: CategoryType? = nil
    var categoryFilters: Set<String> = []

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
        expenses = repository.fetchAll()
    }

    func addExpense(_ expense: Expense) {
        repository.add(expense)
        loadExpenses()
    }

    // TEMPORARY — dev-only test data, remove this method once no longer needed.
    func seedSampleData() {
        let calendar = Calendar.current
        let today = Date()
        func daysAgo(_ n: Int) -> Date { calendar.date(byAdding: .day, value: -n, to: today) ?? today }
        func monthsAgo(_ n: Int) -> Date { calendar.date(byAdding: .month, value: -n, to: today) ?? today }

        let samples: [Expense] = [
            Expense(id: UUID().uuidString, title: "Grocery Shopping", amount: 1450, category: "Food", expenseDate: today, categoryIcon: "fork.knife", categoryColorName: "systemGreen"),
            Expense(id: UUID().uuidString, title: "Uber Ride", amount: 320, category: "Transport", expenseDate: daysAgo(2), categoryIcon: "car.fill", categoryColorName: "systemOrange"),
            Expense(id: UUID().uuidString, title: "Netflix Subscription", amount: 649, category: "Entertainment", expenseDate: daysAgo(5), categoryIcon: "film.fill", categoryColorName: "systemPurple"),
            Expense(id: UUID().uuidString, title: "Electricity Bill", amount: 2100, category: "Bills", expenseDate: monthsAgo(1), categoryIcon: "doc.text.fill", categoryColorName: "systemIndigo"),
            Expense(id: UUID().uuidString, title: "Coffee with Friends", amount: 280, category: "Food", expenseDate: daysAgo(1), categoryIcon: "fork.knife", categoryColorName: "systemGreen"),
            Expense(id: UUID().uuidString, title: "Gym Membership", amount: 1800, category: "Health", expenseDate: monthsAgo(1), categoryIcon: "heart.fill", categoryColorName: "systemRed"),
            Expense(id: UUID().uuidString, title: "Amazon Order", amount: 3499, category: "Shopping", expenseDate: daysAgo(10), categoryIcon: "bag.fill", categoryColorName: "systemPink"),
            Expense(id: UUID().uuidString, title: "Petrol", amount: 1200, category: "Transport", expenseDate: daysAgo(3), categoryIcon: "car.fill", categoryColorName: "systemOrange"),
            Expense(id: UUID().uuidString, title: "Movie Tickets", amount: 600, category: "Entertainment", expenseDate: monthsAgo(2), categoryIcon: "film.fill", categoryColorName: "systemPurple"),
            Expense(id: UUID().uuidString, title: "Mobile Recharge", amount: 399, category: "Bills", expenseDate: today, categoryIcon: "doc.text.fill", categoryColorName: "systemIndigo"),
            Expense(id: UUID().uuidString, title: "Dinner Out", amount: 950, category: "Food", expenseDate: daysAgo(7), categoryIcon: "fork.knife", categoryColorName: "systemGreen"),
            Expense(id: UUID().uuidString, title: "Doctor Visit", amount: 700, category: "Health", expenseDate: monthsAgo(1), categoryIcon: "heart.fill", categoryColorName: "systemRed"),
            Expense(id: UUID().uuidString, title: "Book Purchase", amount: 540, category: "Education", expenseDate: daysAgo(15), categoryIcon: "book.fill", categoryColorName: "systemTeal"),
            Expense(id: UUID().uuidString, title: "Flight Booking", amount: 8200, category: "Travel", expenseDate: monthsAgo(2), categoryIcon: "airplane", categoryColorName: "systemBlue"),
            Expense(id: UUID().uuidString, title: "Home Wi-Fi Bill", amount: 999, category: "Bills", expenseDate: today, categoryIcon: "doc.text.fill", categoryColorName: "systemIndigo"),
            Expense(id: UUID().uuidString, title: "Salary", amount: 55000, category: "Salary", type: .income, expenseDate: today, categoryIcon: "banknote.fill", categoryColorName: "systemGreen")
        ]
        samples.forEach { repository.add($0) }
        loadExpenses()
    }

    func deleteItems(from sectionExpenses: [Expense], at offsets: IndexSet) {
        withAnimation {
            let itemsToDelete = offsets.map { sectionExpenses[$0] }
            itemsToDelete.forEach { repository.delete($0) }
            let deletedIDs = Set(itemsToDelete.map(\.id))
            expenses.removeAll { deletedIDs.contains($0.id) }
        }
    }
}
