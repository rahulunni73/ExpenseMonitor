//
//  ExpenseDetailView.swift
//  ExpenseMonitor
//

import SwiftUI

struct ExpenseDetailView: View {
    let expense: Expense
    var onEdit: () -> Void
    var onDelete: () -> Void

    @Environment(\.dismiss) private var dismiss
    @Environment(\.themeColors) private var themeColors
    @Environment(\.typography) private var typography

    private var amountColor: Color {
        expense.type == .income ? themeColors.income : themeColors.expense
    }

    private var amountPrefix: String {
        expense.type == .income ? "+" : "-"
    }

    var body: some View {
        VStack(spacing: 0) {
            HStack {
                Button("Cancel") {
                    dismiss()
                }
                Spacer()
                Text("Expense")
                    .font(typography.headline)
                Spacer()
                Color.clear
                    .frame(width: 44, height: 44)
            }
            .padding()

            ScrollView {
                VStack(spacing: 24) {
                    VStack(spacing: 12) {
                        Image(systemName: expense.categoryIcon)
                            .font(.title)
                            .foregroundStyle(themeColors.accent)
                            .frame(width: 72, height: 72)
                            .background(themeColors.accent.opacity(0.15))
                            .clipShape(Circle())

                        Text(expense.title)
                            .font(typography.title3Bold)

                        Text("\(amountPrefix)\(expense.amount.currencyFormatted)")
                            .font(typography.amount(size: 34))
                            .foregroundStyle(amountColor)
                    }
                    .padding(.top, 12)

                    VStack(spacing: 0) {
                        detailRow(label: "Category", value: expense.category)
                        Divider().padding(.leading)
                        detailRow(label: "Type", value: expense.type == .income ? "Income" : "Expense")
                        Divider().padding(.leading)
                        detailRow(label: "Date", value: expense.expenseDate.formatted(date: .abbreviated, time: .shortened))
                        if let note = expense.note, !note.isEmpty {
                            Divider().padding(.leading)
                            detailRow(label: "Note", value: note)
                        }
                    }
                    .background(themeColors.surface)
                    .clipShape(RoundedRectangle(cornerRadius: 12))
                    .padding(.horizontal)
                }
            }

            HStack(spacing: 12) {
                Button {
                    onEdit()
                } label: {
                    Text("Edit")
                        .font(typography.headline)
                        .foregroundStyle(.white)
                        .frame(maxWidth: .infinity)
                        .frame(height: 52)
                        .background(themeColors.accent)
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                }

                Button {
                    onDelete()
                } label: {
                    Text("Delete")
                        .font(typography.headline)
                        .foregroundStyle(Color(.systemRed))
                        .frame(maxWidth: .infinity)
                        .frame(height: 52)
                        .background(Color(.systemRed).opacity(0.15))
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                }
            }
            .padding()
        }
        .background(themeColors.background)
    }

    private func detailRow(label: String, value: String) -> some View {
        HStack {
            Text(label)
                .font(typography.body)
                .foregroundStyle(.secondary)
            Spacer()
            Text(value)
                .font(typography.body)
                .multilineTextAlignment(.trailing)
        }
        .padding()
    }
}

#Preview {
    ExpenseDetailView(
        expense: Expense(
            id: "preview",
            title: "Home Wi-Fi Bill",
            amount: 999,
            category: "Housing & Utilities",
            type: .expense,
            expenseDate: Date(),
            note: "Monthly broadband plan",
            categoryIcon: "house.fill"
        ),
        onEdit: {},
        onDelete: {}
    )
}
