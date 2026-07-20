//
//  TransactionRow.swift
//  ExpenseMonitor
//
//  Created by Ospyn on 14/07/26.
//

import SwiftUI

struct TransactionRow: View {

    let transaction: Transaction
    var onTap: (() -> Void)? = nil

    @Environment(\.themeColors) private var themeColors
    @Environment(\.typography) private var typography

    private var amountColor: Color {
        transaction.type == .income ? themeColors.income : themeColors.expense
    }

    private var amountPrefix: String {
        transaction.type == .income ? "+" : "-"
    }

    var body: some View {
        HStack(alignment: .center, spacing: 12) {
            Image(systemName: transaction.categoryIcon)
                .foregroundStyle(themeColors.accent)
                .frame(width: 40, height: 40)
                .background(themeColors.accent.opacity(0.15))
                .clipShape(Circle())

            VStack(alignment: .leading, spacing: 2) {
                Text(transaction.title)
                    .font(typography.subheadline)

                HStack(spacing: 4) {
                    Text(transaction.category)
                    Text("•")
                    Text(transaction.date.formatted(date: .omitted, time: .shortened))
                }
                .font(typography.caption)
                .foregroundStyle(.secondary)
            }

            Spacer()

            Text("\(amountPrefix)\(transaction.amount.currencyFormatted)")
                .font(typography.amount(size: 15))
                .foregroundStyle(amountColor)
        }
        .contentShape(Rectangle())
        .onTapGesture {
            onTap?()
        }
    }
}

#Preview {
    TransactionRow(transaction: Transaction(
        id: "preview",
        title: "Groceries",
        amount: 450,
        category: "Food",
        type: .expense,
        date: Date(),
        categoryIcon: "fork.knife"
    ))
}
