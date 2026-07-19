//
//  NetBalanceCard.swift
//  ExpenseMonitor
//

import SwiftUI

struct NetBalanceCard: View {
    let balance: Double
    let income: Double
    let expense: Double

    @Environment(\.themeColors) private var themeColors
    @Environment(\.typography) private var typography

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {

            Text("NET BALANCE")
                .font(typography.caption)
                .foregroundStyle(.secondary)
            Text(balance.currencyFormatted)
                .font(typography.amount(size: 28))

            HStack(spacing: 12) {

                VStack(alignment: .leading, spacing: 4) {
                    HStack(spacing: 4) {
                        Image(systemName: "arrow.down")
                            .foregroundStyle(themeColors.income)
                            .font(.caption)
                        Text("INCOME")
                            .font(typography.caption)
                    }
                    Text(income.currencyFormatted)
                        .font(typography.headline)
                }
                .padding()
                .frame(maxWidth: .infinity, alignment: .leading)
                .background(themeColors.income.opacity(0.15))
                .clipShape(RoundedRectangle(cornerRadius: 12))

                VStack(alignment: .leading, spacing: 4) {
                    HStack(spacing: 4) {
                        Image(systemName: "arrow.up")
                            .foregroundStyle(themeColors.expense)
                            .font(.caption)
                        Text("EXPENSE")
                            .font(typography.caption)
                    }
                    Text(expense.currencyFormatted)
                        .font(typography.headline)
                }
                .padding()
                .frame(maxWidth: .infinity, alignment: .leading)
                .background(themeColors.expense.opacity(0.15))
                .clipShape(RoundedRectangle(cornerRadius: 12))

            }
        }
        .padding()
        .background(themeColors.surface)
        .clipShape(RoundedRectangle(cornerRadius: 16))
    }
}

#Preview {
    NetBalanceCard(balance: 45280.50, income: 10000, expense: 5000)
}
