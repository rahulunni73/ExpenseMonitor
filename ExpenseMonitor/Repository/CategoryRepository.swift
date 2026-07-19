//
//  CategoryRepository.swift
//  ExpenseMonitor
//

import Foundation
import SwiftData

protocol CategoryRepository {
    func fetchAll() -> [Category]
    func add(_ category: Category)
    func update(_ category: Category)
    func delete(_ category: Category)
}

class DefaultCategoryRepository: CategoryRepository {

    private let modelContext: ModelContext

    init(modelContext: ModelContext) {
        self.modelContext = modelContext
        seedDefaultsIfNeeded()
    }

    func fetchAll() -> [Category] {
        let descriptor = FetchDescriptor<Category>(sortBy: [SortDescriptor(\.name)])
        do {
            return try modelContext.fetch(descriptor)
        } catch {
            print("Failed to fetch categories: \(error)")
            return []
        }
    }

    func add(_ category: Category) {
        modelContext.insert(category)
        try? modelContext.save()
    }

    func update(_ category: Category) {
        try? modelContext.save()
    }

    func delete(_ category: Category) {
        modelContext.delete(category)
        try? modelContext.save()
    }

    private func seedDefaultsIfNeeded() {
        guard fetchAll().isEmpty else { return }

        let defaults: [Category] = [
            // Expense categories
            Category(id: "cat-housing", name: "Housing & Utilities", icon: "house.fill", type: .expense, isSystemDefined: true),
            Category(id: "cat-food", name: "Food & Dining", icon: "fork.knife", type: .expense, isSystemDefined: true),
            Category(id: "cat-transport", name: "Transportation", icon: "car.fill", type: .expense, isSystemDefined: true),
            Category(id: "cat-entertainment", name: "Entertainment & Leisure", icon: "film.fill", type: .expense, isSystemDefined: true),
            Category(id: "cat-shopping", name: "Shopping & Personal Care", icon: "bag.fill", type: .expense, isSystemDefined: true),
            Category(id: "cat-health", name: "Health & Fitness", icon: "heart.fill", type: .expense, isSystemDefined: true),
            Category(id: "cat-finance", name: "Financial & Legal", icon: "creditcard.fill", type: .expense, isSystemDefined: true),
            Category(id: "cat-education", name: "Education & Work", icon: "book.fill", type: .expense, isSystemDefined: true),

            // Income categories
            Category(id: "cat-salary", name: "Salary", icon: "banknote.fill", type: .income, isSystemDefined: true),
            Category(id: "cat-freelance", name: "Freelance & Business", icon: "briefcase.fill", type: .income, isSystemDefined: true),
            Category(id: "cat-investments", name: "Investments", icon: "chart.line.uptrend.xyaxis", type: .income, isSystemDefined: true),
            Category(id: "cat-gifts", name: "Gifts & Other", icon: "gift.fill", type: .income, isSystemDefined: true)
        ]
        defaults.forEach { modelContext.insert($0) }
        try? modelContext.save()
    }
}
