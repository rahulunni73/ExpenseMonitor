//
//  SpendingTrendCard.swift
//  ExpenseMonitor
//

import SwiftUI
import Charts



struct SpendingTrendCard: View {
    let points: [SpendingPoint]

    @Environment(\.themeColors) private var themeColors
    @Environment(\.typography) private var typography

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Spending Trend")
                .font(typography.headline)

            Chart(points) { point in
                BarMark(
                    x: .value("Day", point.day),
                    y: .value("Amount", point.amount),
                    width: .ratio(0.2)
                )
                .foregroundStyle(themeColors.accent)
                .cornerRadius(4)
                
            }
            .frame(height: 180)
        }
        .padding()
        .background(themeColors.surface)
        .clipShape(RoundedRectangle(cornerRadius: 16))
        .overlay {
            RoundedRectangle(cornerRadius: 16)
                .strokeBorder(Color.primary.opacity(0.08), lineWidth: 1)
        }
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
