//
//  CompletedDebtsView.swift
//  ExpenseMonitor
//

import SwiftUI

struct CompletedDebtsView: View {
    let debts: [Debt]
    var onChange: (() -> Void)? = nil

    @State private var debtForDetail: Debt?

    @Environment(\.dismiss) private var dismiss
    @Environment(\.themeColors) private var themeColors
    @Environment(\.typography) private var typography

    var body: some View {
        VStack(spacing: 0) {
            HStack {
                Button("Done") {
                    dismiss()
                }
                Spacer()
                Text("Completed Debts")
                    .font(typography.headline)
                Spacer()
                Color.clear
                    .frame(width: 44, height: 44)
            }
            .padding()

            if debts.isEmpty {
                VStack(spacing: 12) {
                    Image(systemName: "checkmark.circle")
                        .font(.system(size: 40))
                        .foregroundStyle(.secondary)
                    Text("No completed debts yet")
                        .font(typography.headline)
                    Text("Debts move here once they're fully repaid.")
                        .font(typography.subheadline)
                        .foregroundStyle(.secondary)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 32)
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            } else {
                ScrollView {
                    VStack(spacing: 12) {
                        ForEach(debts) { debt in
                            row(debt)
                                .onTapGesture {
                                    debtForDetail = debt
                                }
                        }
                    }
                    .padding()
                }
            }
        }
        .background(themeColors.background)
        .fullScreenCover(item: $debtForDetail, onDismiss: onChange) { debt in
            DebtDetailView(debt: debt, onChange: onChange)
        }
    }

    private func row(_ debt: Debt) -> some View {
        HStack(spacing: 12) {
            Image(systemName: debt.direction.icon)
                .foregroundStyle(themeColors.accent)
                .frame(width: 44, height: 44)
                .background(themeColors.accent.opacity(0.15))
                .clipShape(Circle())

            VStack(alignment: .leading, spacing: 2) {
                Text(debt.personName)
                    .font(typography.subheadline)
                Text(debt.direction.title)
                    .font(typography.caption)
                    .foregroundStyle(.secondary)
            }

            Spacer()

            VStack(alignment: .trailing, spacing: 2) {
                Text(debt.amount.currencyFormatted)
                    .font(typography.amount(size: 15))
                if let settledDate = debt.settledDate {
                    Text("Settled \(settledDate.formatted(.dateTime.day().month(.abbreviated)))")
                        .font(typography.caption2)
                        .foregroundStyle(.secondary)
                }
            }
        }
        .padding(12)
        .background(themeColors.surface)
        .clipShape(RoundedRectangle(cornerRadius: 14))
        .overlay {
            RoundedRectangle(cornerRadius: 14)
                .strokeBorder(Color.primary.opacity(0.08), lineWidth: 1)
        }
        .contentShape(Rectangle())
    }
}

#Preview {
    CompletedDebtsView(debts: [
        Debt(id: "1", personName: "Rahul", direction: .owedToMe, amount: 500, amountRepaid: 500, date: Date(), isSettled: true, settledDate: Date())
    ])
}
