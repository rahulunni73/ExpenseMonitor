//
//  Category.swift
//  ExpenseMonitor
//

import SwiftData

enum CategoryType: String, Codable {
    case income = "INCOME"
    case expense = "EXPENSE"
}

@Model
final class Category: Identifiable {
    var id: String
    var name: String
    var icon: String
    var type: CategoryType
    var isSystemDefined: Bool

    init(id: String, name: String, icon: String, type: CategoryType, isSystemDefined: Bool = false) {
        self.id = id
        self.name = name
        self.icon = icon
        self.type = type
        self.isSystemDefined = isSystemDefined
    }
}
