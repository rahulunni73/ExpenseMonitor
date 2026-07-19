//
//  BurdenRatioCard.swift
//  ExpenseMonitor
//

import SwiftUI

struct BurdenRatioCard: View {
    let percent: Double

    @Environment(\.themeColors) private var themeColors
    @Environment(\.typography) private var typography

    private var valueColor: Color {
        percent >= 50 ? themeColors.expense : themeColors.accent
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text("EMI & Chit Burden — Current Month")
                .font(typography.caption)
                .foregroundStyle(.secondary)
            Text(String(format: "%.0f%%", percent))
                .font(typography.amount(size: 28))
                .foregroundStyle(valueColor)
            Text("of this month's income, regardless of the period shown above")
                .font(typography.caption2)
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
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
    BurdenRatioCard(percent: 38)
        .padding()
}
