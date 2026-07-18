//
//  SettingsView.swift
//  ExpenseMonitor
//

import SwiftUI

struct SettingsView: View {
    let entitlements: EntitlementsProviding

    @Environment(\.dismiss) private var dismiss
    @Environment(\.typography) private var typography

    private var appVersion: String {
        Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "1.0"
    }

    var body: some View {
        VStack(spacing: 0) {
            HStack {
                Button("Done") {
                    dismiss()
                }
                Spacer()
                Text("Settings")
                    .font(typography.headline)
                Spacer()
                Color.clear
                    .frame(width: 44, height: 44)
            }
            .padding()

            // Future "Appearance" section belongs here — rows calling themeManager.select(theme)/
            // .select(typography), following the same settingsRow/"Coming soon" pattern below,
            // once a theme-picker screen exists.
            List {
                Section("Categories") {
                    settingsRow(icon: "tag.fill", iconColor: Color(.systemBlue), title: "Manage Categories", detail: "Coming soon")
                }

                Section("Preferences") {
                    settingsRow(icon: "indianrupeesign.circle.fill", iconColor: Color(.systemGreen), title: "Currency", detail: "INR (₹)")
                }

                Section("Premium") {
                    settingsRow(
                        icon: "icloud.fill",
                        iconColor: Color(.systemBlue),
                        title: "Cloud Sync",
                        detail: entitlements.isUnlocked(.cloudSync) ? "Unlocked" : "Locked"
                    )
                }

                Section("About") {
                    settingsRow(icon: "info.circle.fill", iconColor: Color(.systemGray), title: "Version", detail: appVersion)
                }
            }
            .listStyle(.insetGrouped)
        }
        .background(Color(.systemGroupedBackground))
    }

    private func settingsRow(icon: String, iconColor: Color, title: String, detail: String) -> some View {
        HStack {
            Image(systemName: icon)
                .foregroundStyle(.white)
                .frame(width: 28, height: 28)
                .background(iconColor)
                .clipShape(RoundedRectangle(cornerRadius: 7))
            Text(title)
                .font(typography.body)
            Spacer()
            Text(detail)
                .font(typography.body)
                .foregroundStyle(.secondary)
        }
        .padding(.vertical, 4)
    }
}

#Preview {
    SettingsView(entitlements: StubEntitlementsProvider())
}
