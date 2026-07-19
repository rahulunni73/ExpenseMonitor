//
//  Loan.swift
//  ExpenseMonitor
//

import SwiftData
import Foundation

enum LoanType: String, Codable {
    case loan = "LOAN"
    case creditCard = "CREDIT_CARD"
}

@Model
final class Loan: Identifiable {
    var id: String
    var name: String
    var type: LoanType
    var lender: String?
    var principalAmount: Double = 0
    var installmentAmount: Double
    var startDate: Date
    var numberOfInstallments: Int
    var paidInstallments: [Int] = []
    var penalties: [InstallmentPenalty] = []
    var note: String?

    init(id: String, name: String, type: LoanType = .loan, lender: String? = nil, principalAmount: Double, installmentAmount: Double, startDate: Date, numberOfInstallments: Int, paidInstallments: [Int] = [], penalties: [InstallmentPenalty] = [], note: String? = nil) {
        self.id = id
        self.name = name
        self.type = type
        self.lender = lender
        self.principalAmount = principalAmount
        self.installmentAmount = installmentAmount
        self.startDate = startDate
        self.numberOfInstallments = numberOfInstallments
        self.paidInstallments = paidInstallments
        self.penalties = penalties
        self.note = note
    }
}

struct InstallmentPenalty: Codable {
    let installmentNumber: Int
    let amount: Double
}

struct LoanInstallment: Identifiable {
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

extension Loan {
    var installments: [LoanInstallment] {
        (1...numberOfInstallments).map { number in
            let dueDate = Calendar.current.date(byAdding: .month, value: number - 1, to: startDate) ?? startDate
            return LoanInstallment(id: number, dueDate: dueDate, isPaid: paidInstallments.contains(number))
        }
    }

    var nextDueInstallment: LoanInstallment? {
        installments.first { $0.status != .paid }
    }

    var totalPayable: Double {
        installmentAmount * Double(numberOfInstallments)
    }

    var totalInterest: Double {
        max(totalPayable - principalAmount, 0)
    }

    var remainingBalance: Double {
        Double(numberOfInstallments - paidInstallments.count) * installmentAmount
    }

    var endDate: Date {
        Calendar.current.date(byAdding: .month, value: numberOfInstallments - 1, to: startDate) ?? startDate
    }

    var totalPenalties: Double {
        penalties.reduce(0) { $0 + $1.amount }
    }

    func penaltyAmount(for installmentNumber: Int) -> Double? {
        penalties.first { $0.installmentNumber == installmentNumber }?.amount
    }
}
