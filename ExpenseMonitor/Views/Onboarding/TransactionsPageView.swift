//
//  TransactionsPageView.swift
//  ExpenseMonitor
//

import SwiftUI

struct TransactionsPageView: View {
    @Environment(\.themeColors) private var themeColors
    @Environment(\.typography) private var typography

    var body: some View {
        VStack(spacing: 32) {
            Spacer()

            previewStage

            VStack(spacing: 12) {
                Text("Effortless Logging")
                    .font(typography.title2Bold)
                    .multilineTextAlignment(.center)

                Text("Categorize and search your spending in seconds, all in one place.")
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
            FloatingTransactionCard(icon: "fork.knife", title: "Lunch", amount: "₹450", offset: CGSize(width: -70, height: -70), animationDelay: 0)
            FloatingTransactionCard(icon: "car.fill", title: "Auto", amount: "₹120", offset: CGSize(width: 65, height: -10), animationDelay: 1.5)
            FloatingTransactionCard(icon: "cart.fill", title: "Grocery", amount: "₹1,200", offset: CGSize(width: -75, height: 55), animationDelay: 3)

            BouncingRupeeBadge()
        }
        .frame(height: 260)
        .padding(.horizontal, 24)
    }
}

private struct FloatingTransactionCard: View {
    let icon: String
    let title: String
    let amount: String
    let offset: CGSize
    let animationDelay: Double

    @State private var isFloating = false

    @Environment(\.themeColors) private var themeColors
    @Environment(\.typography) private var typography

    var body: some View {
        HStack(spacing: 8) {
            Image(systemName: icon)
                .foregroundStyle(themeColors.accent)
                .frame(width: 32, height: 32)
                .background(themeColors.accent.opacity(0.15))
                .clipShape(Circle())

            VStack(alignment: .leading, spacing: 1) {
                Text(title)
                    .font(typography.caption)
                    .foregroundStyle(.secondary)
                Text(amount)
                    .font(typography.subheadlineBold)
                    .foregroundStyle(themeColors.expense)
            }
        }
        .padding(10)
        .background(themeColors.surface)
        .clipShape(RoundedRectangle(cornerRadius: 14))
        .overlay {
            RoundedRectangle(cornerRadius: 14)
                .strokeBorder(Color.primary.opacity(0.08), lineWidth: 1)
        }
        .offset(x: offset.width, y: isFloating ? offset.height - 10 : offset.height + 10)
        .rotationEffect(.degrees(isFloating ? 3 : -3))
        .onAppear {
            withAnimation(.easeInOut(duration: 3).repeatForever(autoreverses: true).delay(animationDelay)) {
                isFloating = true
            }
        }
    }
}

private struct BouncingRupeeBadge: View {
    @State private var isBouncing = false

    @Environment(\.themeColors) private var themeColors
    @Environment(\.typography) private var typography

    var body: some View {
        Circle()
            .fill(themeColors.accent)
            .frame(width: 88, height: 88)
            .overlay {
                Text("₹")
                    .font(typography.amount(size: 32))
                    .foregroundStyle(.white)
            }
            .overlay {
                Circle()
                    .strokeBorder(themeColors.background, lineWidth: 4)
            }
            .shadow(color: .black.opacity(0.15), radius: 8, y: 4)
            .offset(y: isBouncing ? -8 : 0)
            .onAppear {
                withAnimation(.easeInOut(duration: 2).repeatForever(autoreverses: true)) {
                    isBouncing = true
                }
            }
    }
}

#Preview {
    TransactionsPageView()
}








/*

//
//  TransactionsPageView.swift
//  ExpenseMonitor
//
//  Created by Ospyn on 21/07/26.


import SwiftUI

struct TransactionsPageView: View {
    @Environment(\.themeColors) private var themeColors
    @Environment(\.typography) private var typography

    private let previewRows: [(icon: String, title: String, category: String, amount: String)] = [
        ("bag.fill", "Lifestyle Store", "Shopping", "₹4,299"),
        ("fork.knife", "Indigo Gourmet", "Dining", "₹1,850"),
        ("fuelpump.fill", "HP Petrol Pump", "Transport", "₹1,200")
    ]

    var body: some View {
        VStack(spacing: 32) {
            Spacer()

            previewCard

            VStack(spacing: 12) {
                Text("Effortless Logging")
                    .font(typography.title2Bold)
                    .multilineTextAlignment(.center)

                Text("Categorize and search your spending in seconds, all in one place.")
                    .font(typography.subheadline)
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 32)
            }

            Spacer()
            Spacer()
        }
    }

    private var previewCard: some View {
        VStack(spacing: 8) {
            ForEach(previewRows, id: \.title) { row in
                previewRow(row)
                if row.title != previewRows.last?.title {
                    Divider()
                }
            }
        }
        .padding()
        .background(themeColors.surface)
        .clipShape(RoundedRectangle(cornerRadius: 16))
        .overlay {
            RoundedRectangle(cornerRadius: 16)
                .strokeBorder(Color.primary.opacity(0.08), lineWidth: 1)
        }
        .padding(.horizontal, 32)
    }

    private func previewRow(_ row: (icon: String, title: String, category: String, amount: String)) -> some View {
        HStack(spacing: 12) {
            Image(systemName: row.icon)
                .foregroundStyle(themeColors.accent)
                .frame(width: 40, height: 40)
                .background(themeColors.accent.opacity(0.15))
                .clipShape(Circle())

            VStack(alignment: .leading, spacing: 2) {
                Text(row.title)
                    .font(typography.subheadline)
                Text(row.category)
                    .font(typography.caption)
                    .foregroundStyle(.secondary)
            }

            Spacer()

            Text(row.amount)
                .font(typography.amount(size: 15))
        }
    }
}

#Preview {
    TransactionsPageView()
}
*/
