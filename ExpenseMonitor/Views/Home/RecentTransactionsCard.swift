//
//  RecentTransactionsCard.swift
//  ExpenseMonitor
//

import SwiftUI

struct RecentTransactionsCard: View {
    let transactions: [Expense]
    var onViewAll: (() -> Void)? = nil

    @Environment(\.themeColors) private var themeColors
    @Environment(\.typography) private var typography

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text("Recent Transactions")
                    .font(typography.headline)
                Spacer()
                Button {
                    onViewAll?()
                } label: {
                    Text("View All")
                        .font(typography.subheadline)
                        .foregroundStyle(themeColors.accent)
                }
                .buttonStyle(.plain)
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
        .background(themeColors.surface)
        .clipShape(RoundedRectangle(cornerRadius: 16))
        .overlay {
            RoundedRectangle(cornerRadius: 16)
                .strokeBorder(Color.primary.opacity(0.08), lineWidth: 1)
        }
    }
}

#Preview {
    RecentTransactionsCard(transactions: [
        Expense(id: "201", title: "Starbucks", amount: 450, category: "Food", categoryIcon: "fork.knife"),
        Expense(id: "202", title: "Salary", amount: 50000, category: "Salary", type: .income, categoryIcon: "banknote.fill"),
        Expense(id: "203", title: "Petrol", amount: 2800, category: "Transport", categoryIcon: "car.fill")
    ])
}
