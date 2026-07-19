//
//  ThemePickerView.swift
//  ExpenseMonitor
//

import SwiftUI

struct ThemePickerView: View {
    @Environment(ThemeManager.self) private var themeManager
    @Environment(\.dismiss) private var dismiss
    @Environment(\.themeColors) private var themeColors
    @Environment(\.typography) private var typography

    var body: some View {
        VStack(spacing: 0) {
            HStack {
                Button("Done") {
                    dismiss()
                }
                Spacer()
                Text("Theme")
                    .font(typography.headline)
                Spacer()
                Color.clear
                    .frame(width: 44, height: 44)
            }
            .padding()

            List {
                ForEach(Theme.allPresets) { theme in
                    row(for: theme)
                }
            }
            .listStyle(.insetGrouped)
        }
        .background(themeColors.background)
    }

    private func row(for theme: Theme) -> some View {
        let isSelected = theme.id == themeManager.currentTheme.id
        return HStack(spacing: 12) {
            swatch(theme.colors)
            Text(theme.name)
                .font(typography.body)
            Spacer()
            if isSelected {
                Image(systemName: "checkmark")
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundStyle(themeColors.accent)
            }
        }
        .padding(.vertical, 6)
        .contentShape(Rectangle())
        .onTapGesture {
            themeManager.select(theme)
        }
    }

    private func swatch(_ colors: ThemeColors) -> some View {
        HStack(spacing: -10) {
            Circle()
                .fill(colors.accent)
                .frame(width: 28, height: 28)
            Circle()
                .fill(colors.surface)
                .frame(width: 28, height: 28)
                .overlay {
                    Circle().strokeBorder(Color.primary.opacity(0.15), lineWidth: 1)
                }
            Circle()
                .fill(colors.background)
                .frame(width: 28, height: 28)
                .overlay {
                    Circle().strokeBorder(Color.primary.opacity(0.15), lineWidth: 1)
                }
        }
    }
}

#Preview {
    ThemePickerView()
        .environment(ThemeManager())
}
