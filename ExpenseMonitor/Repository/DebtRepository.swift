//
//  DebtRepository.swift
//  ExpenseMonitor
//

import Foundation
import SwiftData

protocol DebtRepository {
    func fetchAll() -> [Debt]
    func add(_ debt: Debt)
    func update(_ debt: Debt)
    func delete(_ debt: Debt)
}

class DefaultDebtRepository: DebtRepository {
    private let modelContext: ModelContext

    init(modelContext: ModelContext) {
        self.modelContext = modelContext
    }

    func fetchAll() -> [Debt] {
        let descriptor = FetchDescriptor<Debt>(sortBy: [SortDescriptor(\.date, order: .reverse)])
        do {
            return try modelContext.fetch(descriptor)
        } catch {
            print("Failed to fetch debts: \(error)")
            return []
        }
    }

    func add(_ debt: Debt) {
        modelContext.insert(debt)
        try? modelContext.save()
    }

    func update(_ debt: Debt) {
        try? modelContext.save()
    }

    func delete(_ debt: Debt) {
        modelContext.delete(debt)
        try? modelContext.save()
    }
}
