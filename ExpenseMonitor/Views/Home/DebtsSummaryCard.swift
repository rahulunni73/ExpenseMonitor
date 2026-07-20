//
//  DebtsSummaryCard.swift
//  ExpenseMonitor
//

import SwiftUI

struct DebtsSummaryCard: View {
    let owedToMe: Double
    let owedByMe: Double

    @Environment(\.themeColors) private var themeColors
    @Environment(\.typography) private var typography

    private var hasDebts: Bool {
        owedToMe > 0 || owedByMe > 0
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Debts")
                .font(typography.headline)

            if hasDebts {
                HStack(spacing: 12) {
                    pill(title: "OWED TO ME", amount: owedToMe, color: themeColors.income)
                    pill(title: "OWED BY ME", amount: owedByMe, color: themeColors.expense)
                }
            } else {
                emptyStateView
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

    private func pill(title: String, amount: Double, color: Color) -> some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(title)
                .font(typography.caption)
            Text(amount.currencyFormatted)
                .font(typography.headline)
        }
        .padding()
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(color.opacity(0.15))
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }

    private var emptyStateView: some View {
        HStack(spacing: 12) {
            Image(systemName: "person.2")
                .font(.system(size: 20))
                .foregroundStyle(.secondary)
            Text("No debts tracked")
                .font(typography.subheadline)
                .foregroundStyle(.secondary)
            Spacer()
        }
        .padding(.vertical, 8)
    }
}

#Preview {
    VStack(spacing: 16) {
        DebtsSummaryCard(owedToMe: 8500, owedByMe: 2400)
        DebtsSummaryCard(owedToMe: 0, owedByMe: 0)
    }
    .padding()
}
