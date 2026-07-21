//
//  PINEntryView.swift
//  ExpenseMonitor
//
//  Created by Ospyn on 21/07/26.

import SwiftUI

struct PINEntryView: View {
    let title: String
    var subtitle: String? = nil
    var errorMessage: String? = nil
    let onComplete: (String) -> Void

    @State private var enteredDigits = ""
    private let pinLength = 4

    @Environment(\.themeColors) private var themeColors
    @Environment(\.typography) private var typography

    private let keypadColumns = Array(repeating: GridItem(.flexible()), count: 3)
    private let keypadKeys = [
        "1", "2", "3",
        "4", "5", "6",
        "7", "8", "9",
        "", "0", "⌫"
    ]

    var body: some View {
        VStack(spacing: 24) {
            VStack(spacing: 8) {
                Text(title)
                    .font(typography.title2Bold)

                if let subtitle {
                    Text(subtitle)
                        .font(typography.subheadline)
                        .foregroundStyle(.secondary)
                }

                if let errorMessage {
                    Text(errorMessage)
                        .font(typography.caption)
                        .foregroundStyle(themeColors.expense)
                }
            }
            .multilineTextAlignment(.center)

            dotsRow

            Spacer()

            LazyVGrid(columns: keypadColumns, spacing: 16) {
                ForEach(keypadKeys, id: \.self) { key in
                    keypadButton(key)
                }
            }
            .padding(.horizontal, 40)
        }
        .padding()
    }

    private var dotsRow: some View {
        HStack(spacing: 16) {
            ForEach(0..<pinLength, id: \.self) { index in
                Circle()
                    .fill(index < enteredDigits.count ? themeColors.accent : themeColors.surfaceSecondary)
                    .frame(width: 16, height: 16)
            }
        }
    }

    @ViewBuilder
    private func keypadButton(_ key: String) -> some View {
        switch key {
        case "":
            Color.clear
                .frame(height: 64)
        case "⌫":
            Button {
                if !enteredDigits.isEmpty {
                    enteredDigits.removeLast()
                }
            } label: {
                Image(systemName: "delete.left")
                    .font(.title3)
                    .frame(maxWidth: .infinity)
                    .frame(height: 64)
            }
            .buttonStyle(.plain)
        default:
            Button {
                guard enteredDigits.count < pinLength else { return }
                enteredDigits += key
                if enteredDigits.count == pinLength {
                    let pin = enteredDigits
                    enteredDigits = ""
                    onComplete(pin)
                }
            } label: {
                Text(key)
                    .font(typography.font(weight: .medium, size: 26, relativeTo: .title2))
                    .frame(maxWidth: .infinity)
                    .frame(height: 64)
                    .background(themeColors.surfaceSecondary)
                    .clipShape(Circle())
            }
            .buttonStyle(.plain)
        }
    }
}

#Preview {
    PINEntryView(title: "Enter PIN", subtitle: "Enter your 4-digit PIN to continue", onComplete: { _ in })
}
