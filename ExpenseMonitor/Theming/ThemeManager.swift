//
//  ThemeManager.swift
//  ExpenseMonitor
//

import SwiftUI

@Observable
final class ThemeManager {
    private(set) var currentTheme: Theme
    private(set) var currentTypography: AppTypography

    private static let themeDefaultsKey = "selectedThemeID"

    init(theme: Theme? = nil, typography: AppTypography = HelveticaNeueTypography()) {
        if let theme {
            self.currentTheme = theme
        } else if let savedID = UserDefaults.standard.string(forKey: Self.themeDefaultsKey),
                  let savedTheme = Theme.allPresets.first(where: { $0.id == savedID }) {
            self.currentTheme = savedTheme
        } else {
            self.currentTheme = .default
        }
        self.currentTypography = typography
    }

    func select(_ theme: Theme) {
        currentTheme = theme
        UserDefaults.standard.set(theme.id, forKey: Self.themeDefaultsKey)
    }

    func select(_ typography: AppTypography) {
        currentTypography = typography
    }
}
