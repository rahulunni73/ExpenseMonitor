//
//  SpendingTrendCard.swift
//  ExpenseMonitor
//

import SwiftUI
import Charts



struct SpendingTrendCard: View {
    let points: [SpendingPoint]

    @State private var granularity = "DAILY"
    private let granularities = ["DAILY", "MONTHLY", "YEARLY"]

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text("Spending Trend")
                    .font(.headline)

                Spacer()

                HStack(spacing: 4) {
                    ForEach(granularities, id: \.self) { option in
                        Text(option)
                            .font(.system(size: 11, weight: .semibold, design: .rounded))
                            .foregroundStyle(option == granularity ? .primary : .secondary)
                            .padding(.horizontal, 10)
                            .padding(.vertical, 6)
                            .background(option == granularity ? Color.white : Color.clear)
                            .clipShape(RoundedRectangle(cornerRadius: 6))
                            .shadow(color: .black.opacity(option == granularity ? 0.1 : 0), radius: 2, y: 1)
                            .contentShape(Rectangle())
                            .onTapGesture { granularity = option }
                    }
                }
                .padding(2)
                .background(Color(.systemGray5))
                .clipShape(RoundedRectangle(cornerRadius: 8))
            }

            Chart(points) { point in
                BarMark(
                    x: .value("Day", point.day),
                    y: .value("Amount", point.amount),
                    width: .ratio(0.2)
                )
                .foregroundStyle(Color(.systemBlue))
                .cornerRadius(4)
                
            }
            .frame(height: 180)
        }
        .padding()
        .background(Color(.secondarySystemGroupedBackground))
        .clipShape(RoundedRectangle(cornerRadius: 16))
    }
}

#Preview {
    SpendingTrendCard(points: [
        SpendingPoint(day: "1 Jun", amount: 400),
        SpendingPoint(day: "8 Jun", amount: 650),
        SpendingPoint(day: "15 Jun", amount: 250),
        SpendingPoint(day: "22 Jun", amount: 900),
        SpendingPoint(day: "30 Jun", amount: 1100)
    ])
}
