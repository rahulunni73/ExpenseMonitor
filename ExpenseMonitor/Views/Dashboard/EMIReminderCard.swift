//
//  EMIReminderCard.swift
//  ExpenseMonitor
//

import SwiftUI

struct EMIReminderCard: View {
    let title: String
    let subtitle: String

    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: "arrow.triangle.2.circlepath")
                .foregroundStyle(Color(.systemBlue))
                .padding(10)
                .background(Color(.systemBlue).opacity(0.15))
                .clipShape(Circle())

            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.subheadline)
                    .bold()
                Text(subtitle)
                    .font(.caption)
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
                .fill(Color(.systemBlue))
                .frame(width: 4)
        }
        .clipShape(RoundedRectangle(cornerRadius: 16))
    }
}

#Preview {
    EMIReminderCard(title: "Home Loan EMI", subtitle: "₹12,500 due in 3 days")
}
