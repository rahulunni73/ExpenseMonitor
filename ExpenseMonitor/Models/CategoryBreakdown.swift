//
//  CategoryBreakdown.swift
//  ExpenseMonitor
//
//  Created by Ospyn on 15/07/26.
//

import SwiftUI

struct CategoryBreakdown: Identifiable {
    let id = UUID()
    let category: String
    let percent: Double
    let color: Color
}
