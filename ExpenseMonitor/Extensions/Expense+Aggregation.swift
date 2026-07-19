//
//  Expense+Aggregation.swift
//  ExpenseMonitor
//

import SwiftUI

private let categoryBreakdownPalette: [Color] = [
    .systemBlue, .systemGreen, .systemOrange, .systemPurple,
    .systemTeal, .systemPink, .systemYellow, .systemIndigo
].map(Color.init)

func expenseSpendingPoints(from expenses: [Expense]) -> [SpendingPoint] {
    let calendar = Calendar.current
    let grouped = Dictionary(grouping: expenses) { calendar.startOfDay(for: $0.expenseDate) }
    return grouped.keys.sorted().map { day in
        let total = (grouped[day] ?? []).reduce(0) { $0 + $1.amount }
        return SpendingPoint(day: day.formatted(.dateTime.day().month(.abbreviated)), amount: total)
    }
}

func expenseCategoryBreakdown(from expenses: [Expense]) -> [CategoryBreakdown] {
    let total = expenses.reduce(0) { $0 + $1.amount }
    guard total > 0 else { return [] }
    let grouped = Dictionary(grouping: expenses) { $0.category }
    return grouped.keys.sorted().enumerated().map { index, category in
        let categoryTotal = (grouped[category] ?? []).reduce(0) { $0 + $1.amount }
        let percent = (categoryTotal / total) * 100
        return CategoryBreakdown(category: category, percent: percent, color: categoryBreakdownPalette[index % categoryBreakdownPalette.count])
    }
    .sorted { $0.percent > $1.percent }
}
