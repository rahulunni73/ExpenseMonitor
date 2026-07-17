//
//  ExpenseRow.swift
//  ExpenseMonitor
//
//  Created by Ospyn on 14/07/26.
//

import SwiftUI

struct ExpenseRow: View {

    let expense: Expense
    var onTap: (() -> Void)? = nil

    private var amountColor: Color {
        expense.type == .income ? Color(.systemGreen) : Color(.systemRed)
    }

    private var amountPrefix: String {
        expense.type == .income ? "+" : "-"
    }

    var body: some View {
        HStack(alignment: .center, spacing: 12) {
            Image(systemName: expense.categoryIcon)
                .foregroundStyle(Category.color(for: expense.categoryColorName))
                .frame(width: 40, height: 40)
                .background(Category.color(for: expense.categoryColorName).opacity(0.15))
                .clipShape(Circle())

            VStack(alignment: .leading, spacing: 2) {
                Text(expense.title)
                    .font(.subheadline)

                HStack(spacing: 4) {
                    Text(expense.category)
                    Text("•")
                    Text(expense.expenseDate.formatted(date: .omitted, time: .shortened))
                }
                .font(.caption)
                .foregroundStyle(.secondary)
            }

            Spacer()

            Text("\(amountPrefix)₹\(expense.amount, specifier: "%.2f")")
                .font(.subheadline.bold())
                .foregroundStyle(amountColor)
        }
        .contentShape(Rectangle())
        .onTapGesture {
            onTap?()
        }
    }
}

#Preview {
    ExpenseRow(expense: Expense(
        id: "preview",
        title: "Groceries",
        amount: 450,
        category: "Food",
        type: .expense,
        expenseDate: Date(),
        categoryIcon: "fork.knife",
        categoryColorName: "systemGreen"
    ))
}
