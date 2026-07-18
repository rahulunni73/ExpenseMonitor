//
//  ThemeEnvironment.swift
//  ExpenseMonitor
//

import SwiftUI

private struct ThemeColorsKey: EnvironmentKey {
    static let defaultValue = Theme.default.colors
}

private struct AppTypographyKey: EnvironmentKey {
    static let defaultValue: AppTypography = HelveticaNeueTypography()
}

extension EnvironmentValues {
    var themeColors: ThemeColors {
        get { self[ThemeColorsKey.self] }
        set { self[ThemeColorsKey.self] = newValue }
    }

    var typography: AppTypography {
        get { self[AppTypographyKey.self] }
        set { self[AppTypographyKey.self] = newValue }
    }
}
