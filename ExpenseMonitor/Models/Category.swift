//
//  Category.swift
//  ExpenseMonitor
//

import SwiftData
import SwiftUI

enum CategoryType: String, Codable {
    case income = "INCOME"
    case expense = "EXPENSE"
}

@Model
final class Category: Identifiable {
    var id: String
    var name: String
    var icon: String
    var colorName: String
    var type: CategoryType
    var isSystemDefined: Bool

    init(id: String, name: String, icon: String, colorName: String, type: CategoryType, isSystemDefined: Bool = false) {
        self.id = id
        self.name = name
        self.icon = icon
        self.colorName = colorName
        self.type = type
        self.isSystemDefined = isSystemDefined
    }

    var swiftUIColor: Color {
        Category.color(for: colorName)
    }

    static func color(for colorName: String) -> Color {
        switch colorName {
        case "systemBlue": return Color(.systemBlue)
        case "systemGreen": return Color(.systemGreen)
        case "systemRed": return Color(.systemRed)
        case "systemOrange": return Color(.systemOrange)
        case "systemPurple": return Color(.systemPurple)
        case "systemTeal": return Color(.systemTeal)
        case "systemPink": return Color(.systemPink)
        case "systemIndigo": return Color(.systemIndigo)
        default: return Color(.systemGray)
        }
    }
}
