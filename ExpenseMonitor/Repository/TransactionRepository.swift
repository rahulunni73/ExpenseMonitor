//
//  TransactionRepository.swift
//  ExpenseMonitor
//
//  Created by Ospyn on 16/07/26.
//

import Foundation
import SwiftData



protocol TransactionRepository {
    func fetchAll() -> [Transaction]
    func add(_ transaction: Transaction)
    func update(_ transaction: Transaction)
    func delete(_ transaction: Transaction)
}










class DefaultTransactionRepository: TransactionRepository {
    
    
    private let modelContext: ModelContext
    private let entitlements: EntitlementsProviding
    
    init(modelContext: ModelContext, entitlements: EntitlementsProviding) {
        self.modelContext = modelContext
        self.entitlements = entitlements
    }
    
    
    func fetchAll() -> [Transaction] {
        let descriptor = FetchDescriptor<Transaction>(
            sortBy: [SortDescriptor(\.lastModified, order: .reverse)]
        )
        do {
            return try modelContext.fetch(descriptor)
        } catch {
            print("Failed to fetch transactions: \(error)")
            return []
        }
    }
    
    
    
    func add(_ transaction: Transaction) {
        modelContext.insert(transaction)
        try? modelContext.save()
        syncIfNeeded()
        NotificationCenter.default.post(name: .transactionsDidChange, object: nil)
    }

    func update(_ transaction: Transaction) {
        try? modelContext.save()
        syncIfNeeded()
        NotificationCenter.default.post(name: .transactionsDidChange, object: nil)
    }

    func delete(_ transaction: Transaction) {
        modelContext.delete(transaction)
        try? modelContext.save()
        syncIfNeeded()
        NotificationCenter.default.post(name: .transactionsDidChange, object: nil)
    }
    
    
    
    private func syncIfNeeded() {
        guard entitlements.isUnlocked(.cloudSync) else { return }
        // Phase B: push local rows where isSynced == false to the backend,
        // mark them synced + store the returned serverID, pull remote changes.
    }
    
    
}
