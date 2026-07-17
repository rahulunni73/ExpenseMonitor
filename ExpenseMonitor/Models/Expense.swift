//
//  Expense.swift
//  ExpenseMonitor
//
//  Created by Ospyn on 14/07/26.
//

import SwiftData
import Foundation


@Model
final class Expense:Identifiable {
    
    var id: String
    var title: String
    var amount: Double
    var category: String
    var type: CategoryType
    var expenseDate: Date
    var note: String?

    var categoryIcon: String = "tag.fill"
    var categoryColorName: String = "systemGray"

    var serverID: String?
    var isSynced: Bool = false
    var lastModified: Date = Date()

    init(id: String, title: String, amount: Double, category: String, type: CategoryType = .expense, expenseDate: Date = Date(), note: String? = nil, categoryIcon: String = "tag.fill", categoryColorName: String = "systemGray") {
        self.id = id
        self.title = title
        self.amount = amount
        self.category = category
        self.type = type
        self.expenseDate = expenseDate
        self.note = note
        self.categoryIcon = categoryIcon
        self.categoryColorName = categoryColorName
    }
    
}
