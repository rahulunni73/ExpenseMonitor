//
//  Transaction.swift
//  ExpenseMonitor
//
//  Created by Ospyn on 14/07/26.
//

import SwiftData
import Foundation


@Model
final class Transaction:Identifiable {
    
    var id: String
    var title: String
    var amount: Double
    var category: String
    var type: CategoryType
    var date: Date
    var note: String?

    var categoryIcon: String = "tag.fill"

    var serverID: String?
    var isSynced: Bool = false
    var lastModified: Date = Date()

    var linkedLoanID: String?
    var linkedChitFundID: String?
    var linkedInstallmentNumber: Int?

    init(id: String, title: String, amount: Double, category: String, type: CategoryType = .expense, date: Date = Date(), note: String? = nil, categoryIcon: String = "tag.fill", linkedLoanID: String? = nil, linkedChitFundID: String? = nil, linkedInstallmentNumber: Int? = nil) {
        self.id = id
        self.title = title
        self.amount = amount
        self.category = category
        self.type = type
        self.date = date
        self.note = note
        self.categoryIcon = categoryIcon
        self.linkedLoanID = linkedLoanID
        self.linkedChitFundID = linkedChitFundID
        self.linkedInstallmentNumber = linkedInstallmentNumber
    }

}

extension Transaction {
    /// Falls back to the category name when no note was entered, so rows/detail
    /// never show a blank headline for a transaction that only has a category.
    var displayTitle: String {
        title.isEmpty ? category : title
    }
}
