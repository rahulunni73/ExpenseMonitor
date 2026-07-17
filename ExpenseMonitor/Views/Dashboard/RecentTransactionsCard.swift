//
//  RecentTransactionsCard.swift
//  ExpenseMonitor
//

import SwiftUI

struct RecentTransactionsCard: View {
    let transactions: [Expense]

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text("Recent Transactions")
                    .font(.headline)
                Spacer()
                Text("View All")
                    .font(.subheadline)
                    .foregroundStyle(Color(.systemBlue))
            }

            VStack(spacing: 8) {
                ForEach(transactions) { transaction in
                    ExpenseRow(expense: transaction)
                    if transaction.id != transactions.last?.id {
                        Divider()
                    }
                }
            }
        }
        .padding()
        .background(Color(.secondarySystemGroupedBackground))
        .clipShape(RoundedRectangle(cornerRadius: 16))
    }
}

#Preview {
    RecentTransactionsCard(transactions: [
        Expense(id: "201", title: "Starbucks", amount: 450, category: "Food", categoryIcon: "fork.knife", categoryColorName: "systemGreen"),
        Expense(id: "202", title: "Salary", amount: 50000, category: "Salary", type: .income, categoryIcon: "banknote.fill", categoryColorName: "systemGreen"),
        Expense(id: "203", title: "Petrol", amount: 2800, category: "Transport", categoryIcon: "car.fill", categoryColorName: "systemOrange")
    ])
}
