//
//  ChitFund.swift
//  ExpenseMonitor
//

import SwiftData
import Foundation

@Model
final class ChitFund: Identifiable {
    var id: String
    var name: String
    var organizer: String?
    var monthlyContribution: Double
    var chitValue: Double
    var startDate: Date
    var numberOfMonths: Int
    var paidContributions: [Int] = []
    var payoutMonth: Int?
    var payoutAmount: Double?
    var penalties: [InstallmentPenalty] = []
    var note: String?

    init(id: String, name: String, organizer: String? = nil, monthlyContribution: Double, chitValue: Double, startDate: Date, numberOfMonths: Int, paidContributions: [Int] = [], payoutMonth: Int? = nil, payoutAmount: Double? = nil, penalties: [InstallmentPenalty] = [], note: String? = nil) {
        self.id = id
        self.name = name
        self.organizer = organizer
        self.monthlyContribution = monthlyContribution
        self.chitValue = chitValue
        self.startDate = startDate
        self.numberOfMonths = numberOfMonths
        self.paidContributions = paidContributions
        self.payoutMonth = payoutMonth
        self.payoutAmount = payoutAmount
        self.penalties = penalties
        self.note = note
    }
}

struct ChitContribution: Identifiable {
    enum Status {
        case paid, pending, overdue
    }

    let id: Int
    let dueDate: Date
    let isPaid: Bool

    var status: Status {
        if isPaid { return .paid }
        return dueDate < Calendar.current.startOfDay(for: Date()) ? .overdue : .pending
    }
}

extension ChitFund {
    var contributions: [ChitContribution] {
        (1...numberOfMonths).map { number in
            let dueDate = Calendar.current.date(byAdding: .month, value: number - 1, to: startDate) ?? startDate
            return ChitContribution(id: number, dueDate: dueDate, isPaid: paidContributions.contains(number))
        }
    }

    var nextDueContribution: ChitContribution? {
        contributions.first { $0.status != .paid }
    }

    var isCompleted: Bool {
        nextDueContribution == nil
    }

    var hasReceivedPayout: Bool {
        payoutMonth != nil
    }

    var totalContributed: Double {
        Double(paidContributions.count) * monthlyContribution
    }

    var remainingContributions: Double {
        Double(numberOfMonths - paidContributions.count) * monthlyContribution
    }

    var endDate: Date {
        Calendar.current.date(byAdding: .month, value: numberOfMonths - 1, to: startDate) ?? startDate
    }

    var totalPenalties: Double {
        penalties.reduce(0) { $0 + $1.amount }
    }

    func penaltyAmount(for month: Int) -> Double? {
        penalties.first { $0.installmentNumber == month }?.amount
    }
}
