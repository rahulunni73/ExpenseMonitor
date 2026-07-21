//
//  PINUnlockView.swift
//  ExpenseMonitor
//
//  Created by Ospyn on 21/07/26.


import SwiftUI

struct PINUnlockView: View {
    var onUnlock: () -> Void

    @Environment(\.themeColors) private var themeColors
    @State private var errorMessage: String?

    var body: some View {
        PINEntryView(
            title: "Enter PIN",
            subtitle: "Enter your PIN to unlock ExpenseMonitor.",
            errorMessage: errorMessage,
            onComplete: handleEntry
        )
        .background(themeColors.background)
    }

    private func handleEntry(_ pin: String) {
        if pin == KeychainService.loadPIN() {
            errorMessage = nil
            onUnlock()
        } else {
            errorMessage = "Incorrect PIN. Try again."
        }
    }
}

#Preview {
    PINUnlockView(onUnlock: {})
}
