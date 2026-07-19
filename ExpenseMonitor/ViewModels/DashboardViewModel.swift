//
//  DashboardViewModel.swift
//  ExpenseMonitor
//
//  Created by Ospyn on 15/07/26.
//

import SwiftUI

@Observable
class DashboardViewModel {
    var netBalance: Double = 45280.50
    var income: Double = 10000
    var expense: Double = 5000

    var spendingPoints: [SpendingPoint] = [
        SpendingPoint(day: "1 Jun", amount: 400),
        SpendingPoint(day: "8 Jun", amount: 650),
        SpendingPoint(day: "15 Jun", amount: 250),
        SpendingPoint(day: "22 Jun", amount: 900),
        SpendingPoint(day: "30 Jun", amount: 1100)
    ]

    var breakdownData: [CategoryBreakdown] = [
        CategoryBreakdown(category: "Housing", percent: 45, color: Color(.systemBlue)),
        CategoryBreakdown(category: "Food", percent: 25, color: Color(.systemGreen)),
        CategoryBreakdown(category: "Other", percent: 30, color: Color(.systemRed))
    ]

    var recentTransactions: [Expense] = [
        Expense(id: "201", title: "Starbucks", amount: 450, category: "Food", categoryIcon: "fork.knife"),
        Expense(id: "202", title: "Salary", amount: 50000, category: "Salary", type: .income, categoryIcon: "banknote.fill"),
        Expense(id: "203", title: "Petrol", amount: 2800, category: "Transport", categoryIcon: "car.fill")
    ]

    var emiReminderTitle: String = "Home Loan EMI"
    var emiReminderSubtitle: String = "₹12,500 due in 3 days"
}
