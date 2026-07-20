//
//  Debt.swift
//  ExpenseMonitor
//

import SwiftData
import Foundation

enum DebtDirection: String, Codable {
    case owedToMe = "OWED_TO_ME"
    case owedByMe = "OWED_BY_ME"

    var title: String {
        switch self {
        case .owedToMe: return "Owed to Me"
        case .owedByMe: return "Owed by Me"
        }
    }

    var icon: String {
        switch self {
        case .owedToMe: return "arrow.down.circle.fill"
        case .owedByMe: return "arrow.up.circle.fill"
        }
    }
}

/// Informal personal lending — money owed between you and another person, with no fixed
/// schedule or interest. Deliberately kept out of the Transaction/Reports pipeline: giving
/// or repaying a debt is a transfer (moving value between cash and a receivable/payable),
/// not real income or expense, so counting it there would distort spending totals.
@Model
final class Debt: Identifiable {
    var id: String
    var personName: String
    var direction: DebtDirection
    var amount: Double
    var amountRepaid: Double = 0
    var date: Date
    var note: String?
    var isSettled: Bool = false
    var settledDate: Date?

    init(id: String, personName: String, direction: DebtDirection, amount: Double, amountRepaid: Double = 0, date: Date, note: String? = nil, isSettled: Bool = false, settledDate: Date? = nil) {
        self.id = id
        self.personName = personName
        self.direction = direction
        self.amount = amount
        self.amountRepaid = amountRepaid
        self.date = date
        self.note = note
        self.isSettled = isSettled
        self.settledDate = settledDate
    }
}

extension Debt {
    var remainingAmount: Double {
        max(amount - amountRepaid, 0)
    }

    var progress: Double {
        amount > 0 ? min(amountRepaid / amount, 1) : 0
    }
}
