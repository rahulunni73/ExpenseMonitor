//
//  EMIReminderCard.swift
//  ExpenseMonitor
//

import SwiftUI

struct EMIReminderCard: View {
    let title: String
    let subtitle: String

    @Environment(\.themeColors) private var themeColors
    @Environment(\.typography) private var typography

    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: "arrow.triangle.2.circlepath")
                .foregroundStyle(themeColors.accent)
                .padding(10)
                .background(themeColors.accent.opacity(0.15))
                .clipShape(Circle())

            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(typography.subheadlineBold)
                Text(subtitle)
                    .font(typography.caption)
                    .foregroundStyle(.secondary)
            }

            Spacer()

            Image(systemName: "chevron.right")
                .font(.caption)
                .foregroundStyle(.secondary)
        }
        .padding()
        .background(Color(.secondarySystemGroupedBackground))
        .overlay(alignment: .leading) {
            Rectangle()
                .fill(themeColors.accent)
                .frame(width: 4)
        }
        .clipShape(RoundedRectangle(cornerRadius: 16))
    }
}

#Preview {
    EMIReminderCard(title: "Home Loan EMI", subtitle: "₹12,500 due in 3 days")
}
