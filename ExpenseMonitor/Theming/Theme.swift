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
    static let classic = Theme(
        id: "classic",
        name: "Classic",
        colors: ThemeColors(
            accent: Color(.systemBlue),
            income: Color(.systemGreen),
            expense: Color(.systemRed)
        )
    )

    static let ocean = Theme(
        id: "ocean",
        name: "Ocean",
        colors: ThemeColors(
            accent: Color(.systemTeal),
            income: Color(.systemMint),
            expense: Color(.systemOrange)
        )
    )

    static let forest = Theme(
        id: "forest",
        name: "Forest",
        colors: ThemeColors(
            accent: Color(.systemGreen),
            income: Color(.systemMint),
            expense: Color(.systemBrown)
        )
    )

    static let sunset = Theme(
        id: "sunset",
        name: "Sunset",
        colors: ThemeColors(
            accent: Color(.systemOrange),
            income: Color(.systemGreen),
            expense: Color(.systemPink)
        )
    )

    static let allPresets: [Theme] = [.classic, .ocean, .forest, .sunset]

    static let `default` = Theme.classic
}
