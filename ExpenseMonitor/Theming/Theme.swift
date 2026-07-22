//
//  Theme.swift
//  ExpenseMonitor
//

import SwiftUI

struct Theme: Identifiable, Equatable {
    let id: String
    let name: String
    let colors: ThemeColors
}

extension Theme {
    static let midnight = Theme(
        id: "midnight",
        name: "Midnight",
        colors: ThemeColors(
            accent: Color(light: UIColor(hex: 0x5B4B94), dark: UIColor(hex: 0xFF6B35)),
            income: Color(.systemGreen),
            expense: Color(.systemRed),
            background: Color(light: UIColor(hex: 0xF4F2FB), dark: UIColor(hex: 0x0D0D0F)),
            backgroundTop: Color(light: UIColor(hex: 0xE3DEFA), dark: UIColor(hex: 0x0D0D0F)),
            surface: Color(light: UIColor(hex: 0xFFFFFF), dark: UIColor(hex: 0x1C1C1E)),
            surfaceSecondary: Color(light: UIColor(hex: 0xECE9F7), dark: UIColor(hex: 0x2C2C2E))
        )
    )

    static let noir = Theme(
        id: "noir",
        name: "Noir",
        colors: ThemeColors(
            accent: Color(light: UIColor(hex: 0x000000), dark: UIColor(hex: 0xFFFFFF)),
            income: Color(.systemGreen),
            expense: Color(.systemRed),
            background: Color(light: UIColor(hex: 0xFFFFFF), dark: UIColor(hex: 0x000000)),
            backgroundTop: Color(light: UIColor(hex: 0xFFFFFF), dark: UIColor(hex: 0x000000)),
            surface: Color(light: UIColor(hex: 0xFFFFFF), dark: UIColor(hex: 0x1A1A1A)),
            surfaceSecondary: Color(light: UIColor(hex: 0xF2F2F2), dark: UIColor(hex: 0x262626))
        )
    )

    static let allPresets: [Theme] = [.midnight, .noir]

    static let `default` = Theme.midnight
}
