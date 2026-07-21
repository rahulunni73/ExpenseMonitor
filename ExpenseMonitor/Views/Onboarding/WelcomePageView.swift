//
//  WelcomePageView.swift
//  ExpenseMonitor
//
//  Created by Ospyn on 21/07/26.

import SwiftUI

struct WelcomePageView: View {
    @Environment(\.themeColors) private var themeColors
    @Environment(\.typography) private var typography

    var body: some View {
        VStack(spacing: 32) {
            Spacer()

            heroCard

            VStack(spacing: 12) {
                Text("Master Your Money")
                    .font(typography.title2Bold)
                    .multilineTextAlignment(.center)

                Text("Track your income, expenses, and everything in between — simply and privately.")
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
        RoundedRectangle(cornerRadius: 32)
            .fill(themeColors.surface)
            .frame(width: 220, height: 220)
            .overlay {
                Circle()
                    .fill(themeColors.accent.opacity(0.15))
                    .frame(width: 140, height: 140)
                    .overlay {
                        Text("₹")
                            .font(typography.amount(size: 56))
                            .foregroundStyle(themeColors.accent)
                    }
            }
            .overlay {
                RoundedRectangle(cornerRadius: 32)
                    .strokeBorder(Color.primary.opacity(0.08), lineWidth: 1)
            }
    }
}

#Preview {
    WelcomePageView()
}
