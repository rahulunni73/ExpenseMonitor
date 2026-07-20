//
//  TransactionDetailView.swift
//  ExpenseMonitor
//

import SwiftUI

struct TransactionDetailView: View {
    let transaction: Transaction
    var onEdit: () -> Void
    var onDelete: () -> Void

    @Environment(\.dismiss) private var dismiss
    @Environment(\.themeColors) private var themeColors
    @Environment(\.typography) private var typography

    private var amountColor: Color {
        transaction.type == .income ? themeColors.income : themeColors.expense
    }

    private var amountPrefix: String {
        transaction.type == .income ? "+" : "-"
    }

    var body: some View {
        VStack(spacing: 0) {
            HStack {
                Button("Cancel") {
                    dismiss()
                }
                Spacer()
                Text("Transaction")
                    .font(typography.headline)
                Spacer()
                Color.clear
                    .frame(width: 44, height: 44)
            }
            .padding()

            ScrollView {
                VStack(spacing: 24) {
                    VStack(spacing: 12) {
                        Image(systemName: transaction.categoryIcon)
                            .font(.title)
                            .foregroundStyle(themeColors.accent)
                            .frame(width: 72, height: 72)
                            .background(themeColors.accent.opacity(0.15))
                            .clipShape(Circle())

                        Text(transaction.title)
                            .font(typography.title3Bold)

                        Text("\(amountPrefix)\(transaction.amount.currencyFormatted)")
                            .font(typography.amount(size: 34))
                            .foregroundStyle(amountColor)
                    }
                    .padding(.top, 12)

                    VStack(spacing: 0) {
                        detailRow(label: "Category", value: transaction.category)
                        Divider().padding(.leading)
                        detailRow(label: "Type", value: transaction.type == .income ? "Income" : "Expense")
                        Divider().padding(.leading)
                        detailRow(label: "Date", value: transaction.date.formatted(date: .abbreviated, time: .shortened))
                        if let note = transaction.note, !note.isEmpty {
                            Divider().padding(.leading)
                            detailRow(label: "Note", value: note)
                        }
                    }
                    .background(themeColors.surface)
                    .clipShape(RoundedRectangle(cornerRadius: 12))
                    .overlay {
                        RoundedRectangle(cornerRadius: 12)
                            .strokeBorder(Color.primary.opacity(0.08), lineWidth: 1)
                    }
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
    TransactionDetailView(
        transaction: Transaction(
            id: "preview",
            title: "Home Wi-Fi Bill",
            amount: 999,
            category: "Housing & Utilities",
            type: .expense,
            date: Date(),
            note: "Monthly broadband plan",
            categoryIcon: "house.fill"
        ),
        onEdit: {},
        onDelete: {}
    )
}
