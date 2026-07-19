//
//  ChitFundRepository.swift
//  ExpenseMonitor
//

import Foundation
import SwiftData

protocol ChitFundRepository {
    func fetchAll() -> [ChitFund]
    func add(_ chitFund: ChitFund)
    func update(_ chitFund: ChitFund)
    func delete(_ chitFund: ChitFund)
}

class DefaultChitFundRepository: ChitFundRepository {
    private let modelContext: ModelContext

    init(modelContext: ModelContext) {
        self.modelContext = modelContext
    }

    func fetchAll() -> [ChitFund] {
        let descriptor = FetchDescriptor<ChitFund>(sortBy: [SortDescriptor(\.startDate, order: .reverse)])
        do {
            return try modelContext.fetch(descriptor)
        } catch {
            print("Failed to fetch chit funds: \(error)")
            return []
        }
    }

    func add(_ chitFund: ChitFund) {
        modelContext.insert(chitFund)
        try? modelContext.save()
    }

    func update(_ chitFund: ChitFund) {
        try? modelContext.save()
    }

    func delete(_ chitFund: ChitFund) {
        modelContext.delete(chitFund)
        try? modelContext.save()
    }
}
