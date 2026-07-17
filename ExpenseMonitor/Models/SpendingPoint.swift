//
//  SpendingPoint.swift
//  ExpenseMonitor
//
//  Created by Ospyn on 15/07/26.
//


import Foundation

struct SpendingPoint: Identifiable {
    let id = UUID()
    let day: String
    let amount: Double
}
