//
//  NetBalanceCard.swift
//  ExpenseMonitor
//

import SwiftUI

struct NetBalanceCard: View {
    let balance: Double
    let income: Double
    let expense: Double

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {

            Text("NET BALANCE")
                .font(.caption)
                .foregroundStyle(.secondary)
            Text("₹\(balance, specifier: "%.2f")")
                .font(.title)
                .bold()

            HStack(spacing: 12) {

                VStack(alignment: .leading, spacing: 4) {
                    HStack(spacing: 4) {
                        Image(systemName: "arrow.down")
                            .foregroundStyle(Color(.systemGreen))
                        Text("INCOME")
                    }
                    .font(.caption)
                    Text("₹\(income, specifier: "%.0f")")
                        .font(.headline)
                }
                .padding()
                .frame(maxWidth: .infinity, alignment: .leading)
                .background(Color(.systemGreen).opacity(0.15))
                .clipShape(RoundedRectangle(cornerRadius: 12))

                VStack(alignment: .leading, spacing: 4) {
                    HStack(spacing: 4) {
                        Image(systemName: "arrow.up")
                            .foregroundStyle(Color(.systemRed))
                        Text("EXPENSE")
                            .font(.caption)
                    }
                    Text("₹\(expense, specifier: "%.0f")")
                        .font(.headline)
                }
                .padding()
                .frame(maxWidth: .infinity, alignment: .leading)
                .background(Color(.systemRed).opacity(0.15))
                .clipShape(RoundedRectangle(cornerRadius: 12))

            }
        }
        .padding()
        .background(Color(.secondarySystemGroupedBackground))
        .clipShape(RoundedRectangle(cornerRadius: 16))
    }
}

#Preview {
    NetBalanceCard(balance: 45280.50, income: 10000, expense: 5000)
}
