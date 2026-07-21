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

            previewStage

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

    private var previewStage: some View {
        ZStack {
            BouncingHeroRingCard(percent: 0.7, label: "Home Loan EMI", amount: "₹45,000", caption: "Due in 5 days")

            FloatingMiniRingCard(percent: 0.4, color: themeColors.expense, label: "Chit Cycle 4/10", amount: "₹12,000", offset: CGSize(width: 95, height: -120), animationDelay: 0)

            FloatingMiniRingCard(percent: 0.8, color: themeColors.accent, label: "Car Loan", amount: "₹8,500", offset: CGSize(width: -95, height: 110), animationDelay: 1.5)
        }
        .frame(height: 340)
        .padding(.horizontal, 24)
    }
}

private struct BouncingHeroRingCard: View {
    let percent: Double
    let label: String
    let amount: String
    let caption: String

    @State private var isBouncing = false

    @Environment(\.themeColors) private var themeColors
    @Environment(\.typography) private var typography

    var body: some View {
        VStack(spacing: 12) {
            ProgressRing(percent: percent, color: themeColors.accent, size: 110) {
                Text("\(Int(percent * 100))%")
                    .font(typography.subheadlineBold)
            }

            VStack(spacing: 2) {
                Text(label)
                    .font(typography.subheadline)
                Text(amount)
                    .font(typography.amount(size: 20))
                    .foregroundStyle(themeColors.accent)
                Text(caption)
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
        .offset(y: isBouncing ? -6 : 6)
        .onAppear {
            withAnimation(.easeInOut(duration: 2.4).repeatForever(autoreverses: true)) {
                isBouncing = true
            }
        }
    }
}

private struct FloatingMiniRingCard: View {
    let percent: Double
    let color: Color
    let label: String
    let amount: String
    let offset: CGSize
    let animationDelay: Double

    @State private var isFloating = false

    @Environment(\.themeColors) private var themeColors
    @Environment(\.typography) private var typography

    var body: some View {
        VStack(spacing: 8) {
            ProgressRing(percent: percent, color: color, size: 64) {
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
        .frame(width: 120)
        .padding()
        .background(themeColors.surface)
        .clipShape(RoundedRectangle(cornerRadius: 16))
        .overlay {
            RoundedRectangle(cornerRadius: 16)
                .strokeBorder(Color.primary.opacity(0.08), lineWidth: 1)
        }
        .offset(x: offset.width, y: isFloating ? offset.height - 8 : offset.height + 8)
        .rotationEffect(.degrees(isFloating ? 2 : -2))
        .onAppear {
            withAnimation(.easeInOut(duration: 3).repeatForever(autoreverses: true).delay(animationDelay)) {
                isFloating = true
            }
        }
    }
}

private struct ProgressRing<Label: View>: View {
    let percent: Double
    let color: Color
    let size: CGFloat
    let label: Label

    @Environment(\.themeColors) private var themeColors

    init(percent: Double, color: Color, size: CGFloat, @ViewBuilder label: () -> Label) {
        self.percent = percent
        self.color = color
        self.size = size
        self.label = label()
    }

    var body: some View {
        ZStack {
            Chart([("paid", percent), ("remaining", 1 - percent)], id: \.0) { item in
                SectorMark(angle: .value("Value", item.1), innerRadius: .ratio(0.72))
                    .foregroundStyle(item.0 == "paid" ? color : themeColors.surfaceSecondary)
                    .cornerRadius(3)
            }
            .frame(width: size, height: size)

            label
        }
    }
}

#Preview {
    EMIPageView()
}
