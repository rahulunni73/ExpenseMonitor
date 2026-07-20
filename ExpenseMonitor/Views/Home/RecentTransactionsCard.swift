//
//  RecentTransactionsCard.swift
//  ExpenseMonitor
//

import SwiftUI

struct RecentTransactionsCard: View {
    let transactions: [Transaction]
    var onViewAll: (() -> Void)? = nil

    @Environment(\.themeColors) private var themeColors
    @Environment(\.typography) private var typography

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text("Recent Transactions")
                    .font(typography.headline)
                Spacer()
                if !transactions.isEmpty {
                    Button {
                        onViewAll?()
                    } label: {
                        Text("View All")
                            .font(typography.subheadline)
                            .foregroundStyle(themeColors.accent)
                    }
                    .buttonStyle(.plain)
                }
            }

            if transactions.isEmpty {
                emptyStateView
            } else {
                VStack(spacing: 8) {
                    ForEach(transactions) { transaction in
                        TransactionRow(transaction: transaction)
                        if transaction.id != transactions.last?.id {
                            Divider()
                        }
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

    private var emptyStateView: some View {
        HStack(spacing: 12) {
            Image(systemName: "tray")
                .font(.system(size: 20))
                .foregroundStyle(.secondary)
            Text("No transactions yet")
                .font(typography.subheadline)
                .foregroundStyle(.secondary)
            Spacer()
        }
        .padding(.vertical, 8)
    }
}

#Preview {
    RecentTransactionsCard(transactions: [
        Transaction(id: "201", title: "Starbucks", amount: 450, category: "Food", categoryIcon: "fork.knife"),
        Transaction(id: "202", title: "Salary", amount: 50000, category: "Salary", type: .income, categoryIcon: "banknote.fill"),
        Transaction(id: "203", title: "Petrol", amount: 2800, category: "Transport", categoryIcon: "car.fill")
    ])
}
