//
//  Color+Adaptive.swift
//  ExpenseMonitor
//

import SwiftUI

extension UIColor {
    convenience init(hex: UInt32) {
        self.init(
            red: CGFloat((hex >> 16) & 0xFF) / 255,
            green: CGFloat((hex >> 8) & 0xFF) / 255,
            blue: CGFloat(hex & 0xFF) / 255,
            alpha: 1
        )
    }
}

extension Color {
    /// Resolves to a different UIColor depending on light/dark appearance —
    /// mirrors how Apple's own semantic colors (e.g. Color(.systemGroupedBackground))
    /// behave under the hood.
    init(light: UIColor, dark: UIColor) {
        self.init(uiColor: UIColor { traits in
            traits.userInterfaceStyle == .dark ? dark : light
        })
    }
}
