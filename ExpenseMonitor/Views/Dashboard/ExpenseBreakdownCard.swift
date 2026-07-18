//
//  ExpenseBreakdownCard.swift
//  ExpenseMonitor
//

import SwiftUI
import Charts



struct ExpenseBreakdownCard: View {
    let data: [CategoryBreakdown]

    @Environment(\.typography) private var typography

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Expense Breakdown")
                .font(typography.headline)

            HStack(spacing: 24) {
                ZStack {
                    Chart(data) { item in
                        SectorMark(
                            angle: .value("Percent", item.percent),
                            innerRadius: .ratio(0.6)
                        )
                        .foregroundStyle(item.color)
                    }
                    .frame(width: 140, height: 140)

                    Text("100%")
                        .font(typography.headline)
                }

                VStack(alignment: .leading, spacing: 12) {
                    ForEach(data) { item in
                        HStack {
                            Circle()
                                .fill(item.color)
                                .frame(width: 8, height: 8)
                            Text(item.category)
                            Spacer()
                            Text("\(Int(item.percent))%")
                                .foregroundStyle(.secondary)
                        }
                    }
                }
            }
        }
        .padding()
        .background(Color(.secondarySystemGroupedBackground))
        .clipShape(RoundedRectangle(cornerRadius: 16))
    }
}

#Preview {
    ExpenseBreakdownCard(data: [
        CategoryBreakdown(category: "Housing", percent: 45, color: Color(.systemBlue)),
        CategoryBreakdown(category: "Food", percent: 25, color: Color(.systemGreen)),
        CategoryBreakdown(category: "Other", percent: 30, color: Color(.systemRed))
    ])
}
