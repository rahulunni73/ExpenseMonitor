//
//  Double+Currency.swift
//  ExpenseMonitor
//

import Foundation

extension Double {
    private static let currencyFormatter: NumberFormatter = {
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        formatter.minimumFractionDigits = 2
        formatter.maximumFractionDigits = 2
        formatter.usesGroupingSeparator = true
        formatter.groupingSeparator = ","
        formatter.decimalSeparator = "."
        return formatter
    }()

    /// Formats as "₹4,200.00" — the one currency format used across the app.
    var currencyFormatted: String {
        let number = Double.currencyFormatter.string(from: NSNumber(value: self)) ?? String(format: "%.2f", self)
        return "₹\(number)"
    }
}
