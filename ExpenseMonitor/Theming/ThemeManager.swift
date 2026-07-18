//
//  ThemeManager.swift
//  ExpenseMonitor
//

import SwiftUI

@Observable
final class ThemeManager {
    private(set) var currentTheme: Theme
    private(set) var currentTypography: AppTypography

    init(theme: Theme = .default, typography: AppTypography = HelveticaNeueTypography()) {
        self.currentTheme = theme
        self.currentTypography = typography
    }

    func select(_ theme: Theme) {
        currentTheme = theme
    }

    func select(_ typography: AppTypography) {
        currentTypography = typography
    }
}
