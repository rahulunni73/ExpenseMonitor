//
//  AppLockView.swift
//  ExpenseMonitor
//
//  Created by Ospyn on 21/07/26.

import SwiftUI

struct AppLockView: View {
    var onUnlock: () -> Void

    @Environment(\.themeColors) private var themeColors
    @Environment(\.typography) private var typography

    @State private var showPINEntry = false

    var body: some View {
        Group {
            if showPINEntry {
                PINUnlockView(onUnlock: onUnlock)
            } else {
                biometricPrompt
            }
        }
        .onAppear(perform: attemptBiometricUnlock)
    }

    private var biometricPrompt: some View {
        VStack(spacing: 16) {
            Spacer()

            Image(systemName: BiometricAuthService.availableBiometry == .faceID ? "faceid" : "touchid")
                .font(.system(size: 56))
                .foregroundStyle(themeColors.accent)

            Text("ExpenseMonitor is Locked")
                .font(typography.title2Bold)

            Spacer()

            Button {
                attemptBiometricUnlock()
            } label: {
                Text("Try Again")
                    .font(typography.headline)
                    .foregroundStyle(.white)
                    .frame(maxWidth: .infinity)
                    .frame(height: 50)
                    .background(themeColors.accent)
                    .clipShape(RoundedRectangle(cornerRadius: 12))
            }
            .buttonStyle(.plain)

            Button {
                showPINEntry = true
            } label: {
                Text("Enter PIN Instead")
                    .font(typography.subheadline)
                    .foregroundStyle(themeColors.accent)
            }
            .buttonStyle(.plain)
            .padding(.bottom, 24)
        }
        .padding(.horizontal, 32)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(themeColors.background)
    }

    private func attemptBiometricUnlock() {
        guard BiometricAuthService.availableBiometry != .none else {
            showPINEntry = true
            return
        }

        BiometricAuthService.authenticate(reason: "Unlock ExpenseMonitor") { success in
            if success {
                onUnlock()
            }
            // Failure or cancel: stay on this screen. The user can tap
            // "Try Again" to re-trigger Face ID/Touch ID, or "Enter PIN Instead".
        }
    }
}

#Preview {
    AppLockView(onUnlock: {})
}
