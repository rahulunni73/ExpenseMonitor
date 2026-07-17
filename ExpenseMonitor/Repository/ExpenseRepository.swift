//
//  ExpenseRepository.swift
//  ExpenseMonitor
//
//  Created by Ospyn on 16/07/26.
//

import Foundation
import SwiftData



protocol ExpenseRepository {
    func fetchAll() -> [Expense]
    func add(_ expense: Expense)
    func update(_ expense: Expense)
    func delete(_ expense: Expense)
}










class DefaultExpenseRepository: ExpenseRepository {
    
    
    private let modelContext: ModelContext
    private let entitlements: EntitlementsProviding
    
    init(modelContext: ModelContext, entitlements: EntitlementsProviding) {
        self.modelContext = modelContext
        self.entitlements = entitlements
    }
    
    
    func fetchAll() -> [Expense] {
        let descriptor = FetchDescriptor<Expense>(
            sortBy: [SortDescriptor(\.lastModified, order: .reverse)]
        )
        do {
            return try modelContext.fetch(descriptor)
        } catch {
            print("Failed to fetch expenses: \(error)")
            return []
        }
    }
    
    
    
    func add(_ expense: Expense) {
        modelContext.insert(expense)
        try? modelContext.save()
        syncIfNeeded()
    }
    
    func update(_ expense: Expense) {
        try? modelContext.save()
        syncIfNeeded()
    }

    func delete(_ expense: Expense) {
        modelContext.delete(expense)
        try? modelContext.save()
        syncIfNeeded()
    }
    
    
    
    private func syncIfNeeded() {
        guard entitlements.isUnlocked(.cloudSync) else { return }
        // Phase B: push local rows where isSynced == false to the backend,
        // mark them synced + store the returned serverID, pull remote changes.
    }
    
    
}
