//
//  Notification+TransactionsDidChange.swift
//  ExpenseMonitor
//

import Foundation

/// In-app broadcast — unrelated to `Services/NotificationService.swift`, which handles real
/// system notifications. This is plain NotificationCenter used as a lightweight signal so every
/// long-lived tab (Home, Transactions) can refresh its cached Transaction array whenever any other part
/// of the app (EMI payments, Reports drill-down, etc.) adds, edits, or deletes a transaction —
/// without it, a stale cached array can hold a reference to an object SwiftData has already
/// deleted, and touching any property on it crashes.
extension Notification.Name {
    static let transactionsDidChange = Notification.Name("transactionsDidChange")
}
