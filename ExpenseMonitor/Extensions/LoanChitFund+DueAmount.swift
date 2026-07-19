//
//  LoanChitFund+DueAmount.swift
//  ExpenseMonitor
//

import Foundation

/// The first moment of next calendar month, relative to `date` — anything due before this is "due this month or overdue".
func startOfNextCalendarMonth(from date: Date = Date()) -> Date {
    let calendar = Calendar.current
    let components = calendar.dateComponents([.year, .month], from: date)
    let startOfThisMonth = calendar.date(from: components) ?? date
    return calendar.date(byAdding: .month, value: 1, to: startOfThisMonth) ?? date
}

func dueAmount(for loans: [Loan], before cutoff: Date) -> Double {
    loans.compactMap { loan -> Double? in
        guard let next = loan.nextDueInstallment, next.dueDate < cutoff else { return nil }
        return loan.installmentAmount
    }.reduce(0, +)
}

func dueAmount(for chitFunds: [ChitFund], before cutoff: Date) -> Double {
    chitFunds.compactMap { chitFund -> Double? in
        guard let next = chitFund.nextDueContribution, next.dueDate < cutoff else { return nil }
        return chitFund.monthlyContribution
    }.reduce(0, +)
}
