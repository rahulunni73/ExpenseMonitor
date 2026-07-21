//
//  PINSetupView.swift
//  ExpenseMonitor
//
//  Created by Ospyn on 21/07/26.

import SwiftUI

struct PINSetupView: View {
    var onComplete: () -> Void

    @Environment(\.dismiss) private var dismiss
    @Environment(\.themeColors) private var themeColors
    @Environment(\.typography) private var typography

    private enum Stage {
        case enter
        case confirm
    }

    @State private var stage: Stage = .enter
    @State private var firstPIN = ""
    @State private var errorMessage: String?

    var body: some View {
        VStack(spacing: 0) {
            HStack {
                Button("Cancel") {
                    dismiss()
                }
                Spacer()
                Text("App Lock")
                    .font(typography.headline)
                Spacer()
                Image(systemName: "lock.fill")
                    .foregroundStyle(.secondary)
            }
            .padding()

            PINEntryView(
                title: stage == .enter ? "Set a PIN" : "Confirm PIN",
                subtitle: stage == .enter
                    ? "This unlocks ExpenseMonitor when Face ID / Touch ID isn't available."
                    : "Enter the same PIN again to confirm.",
                errorMessage: errorMessage,
                onComplete: handleEntry
            )
        }
        .background(themeColors.background)
    }

    private func handleEntry(_ pin: String) {
        switch stage {
        case .enter:
            firstPIN = pin
            errorMessage = nil
            stage = .confirm
        case .confirm:
            if pin == firstPIN {
                KeychainService.savePIN(pin)
                onComplete()
                dismiss()
            } else {
                errorMessage = "PINs didn't match. Try again."
                firstPIN = ""
                stage = .enter
            }
        }
    }
}

#Preview {
    PINSetupView(onComplete: {})
}
