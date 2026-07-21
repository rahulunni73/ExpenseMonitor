//
//  EMIPageView.swift
//  ExpenseMonitor
//
//  Created by Ospyn on 21/07/26.

import SwiftUI
import Charts

struct EMIPageView: View {
    @Environment(\.themeColors) private var themeColors
    @Environment(\.typography) private var typography

    var body: some View {
        VStack(spacing: 24) {
            Spacer()

            heroCard

            HStack(spacing: 16) {
                miniCard(percent: 0.4, color: themeColors.expense, label: "Chit Cycle 4/10", amount: "₹12,000")
                miniCard(percent: 0.8, color: themeColors.accent, label: "Car Loan", amount: "₹8,500")
            }
            .padding(.horizontal, 32)

            VStack(spacing: 12) {
                Text("Smart EMI Tracking")
                    .font(typography.title2Bold)
                    .multilineTextAlignment(.center)

                Text("Stay ahead of loan payments and chit fund cycles with reminders and visual progress.")
                    .font(typography.subheadline)
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 32)
            }

            Spacer()
            Spacer()
        }
    }

    private var heroCard: some View {
        VStack(spacing: 12) {
            ring(percent: 0.7, color: themeColors.accent, size: 110) {
                Text("70%")
                    .font(typography.subheadlineBold)
            }

            VStack(spacing: 2) {
                Text("Home Loan EMI")
                    .font(typography.subheadline)
                Text("₹45,000")
                    .font(typography.amount(size: 20))
                    .foregroundStyle(themeColors.accent)
                Text("Due in 5 days")
                    .font(typography.caption)
                    .foregroundStyle(.secondary)
            }
        }
        .padding()
        .background(themeColors.surface)
        .clipShape(RoundedRectangle(cornerRadius: 20))
        .overlay {
            RoundedRectangle(cornerRadius: 20)
                .strokeBorder(Color.primary.opacity(0.08), lineWidth: 1)
        }
        .padding(.horizontal, 32)
    }

    private func miniCard(percent: Double, color: Color, label: String, amount: String) -> some View {
        VStack(spacing: 8) {
            ring(percent: percent, color: color, size: 64) {
                Text("\(Int(percent * 100))%")
                    .font(typography.caption2)
            }
            Text(label)
                .font(typography.caption)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
            Text(amount)
                .font(typography.subheadlineBold)
        }
        .frame(maxWidth: .infinity)
        .padding()
        .background(themeColors.surface)
        .clipShape(RoundedRectangle(cornerRadius: 16))
        .overlay {
            RoundedRectangle(cornerRadius: 16)
                .strokeBorder(Color.primary.opacity(0.08), lineWidth: 1)
        }
    }

    private func ring<Label: View>(percent: Double, color: Color, size: CGFloat, @ViewBuilder label: () -> Label) -> some View {
        ZStack {
            Chart([("paid", percent), ("remaining", 1 - percent)], id: \.0) { item in
                SectorMark(angle: .value("Value", item.1), innerRadius: .ratio(0.72))
                    .foregroundStyle(item.0 == "paid" ? color : themeColors.surfaceSecondary)
                    .cornerRadius(3)
            }
            .frame(width: size, height: size)

            label()
        }
    }
}

#Preview {
    EMIPageView()
}
