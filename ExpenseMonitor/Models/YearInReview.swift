//
//  YearInReview.swift
//  ExpenseMonitor
//

import Foundation

struct YearInReview: Identifiable {
    var id: Int { year }

    let year: Int
    let income: Double
    let expense: Double
    let netSavings: Double
    let transactionCount: Int
    let topCategory: CategoryBreakdown?
    let busiestMonth: (label: String, amount: Double)?
    let biggestExpense: Transaction?
    let totalEMIChitPaid: Double
}
