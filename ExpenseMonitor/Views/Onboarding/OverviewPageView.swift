//
//  OverviewPageView.swift
//  ExpenseMonitor
//
//  Created by Ospyn on 21/07/26.

import SwiftUI

struct OverviewPageView: View {
    @Environment(\.themeColors) private var themeColors
    @Environment(\.typography) private var typography

    var body: some View {
        VStack(spacing: 32) {
            Spacer()

            statCard

            VStack(spacing: 12) {
                Text("Your Financial Radar")
                    .font(typography.title2Bold)
                    .multilineTextAlignment(.center)

                Text("Home gives you an instant read on your balances, obligations, and reports.")
                    .font(typography.subheadline)
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 32)
            }

            Spacer()
            Spacer()
        }
    }

    private var statCard: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("TOTAL BALANCE")
                .font(typography.caption)
                .foregroundStyle(.secondary)

            Text("₹4,82,500")
                .font(typography.amount(size: 32))

            HStack(spacing: 4) {
                Image(systemName: "arrow.up.right")
                    .font(.caption2)
                Text("+12.4% this month")
                    .font(typography.caption)
            }
            .foregroundStyle(themeColors.income)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding()
        .background(themeColors.surface)
        .clipShape(RoundedRectangle(cornerRadius: 16))
        .overlay {
            RoundedRectangle(cornerRadius: 16)
                .strokeBorder(Color.primary.opacity(0.08), lineWidth: 1)
        }
        .padding(.horizontal, 32)
    }
}

#Preview {
    OverviewPageView()
}
