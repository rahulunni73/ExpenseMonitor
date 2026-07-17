//
//  CategoryRepository.swift
//  ExpenseMonitor
//

import Foundation
import SwiftData

protocol CategoryRepository {
    func fetchAll() -> [Category]
    func add(_ category: Category)
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

    private func seedDefaultsIfNeeded() {
        guard fetchAll().isEmpty else { return }

        let defaults: [Category] = [
            // Expense categories
            Category(id: "cat-housing", name: "Housing & Utilities", icon: "house.fill", colorName: "systemBlue", type: .expense, isSystemDefined: true),
            Category(id: "cat-food", name: "Food & Dining", icon: "fork.knife", colorName: "systemGreen", type: .expense, isSystemDefined: true),
            Category(id: "cat-transport", name: "Transportation", icon: "car.fill", colorName: "systemOrange", type: .expense, isSystemDefined: true),
            Category(id: "cat-entertainment", name: "Entertainment & Leisure", icon: "film.fill", colorName: "systemPurple", type: .expense, isSystemDefined: true),
            Category(id: "cat-shopping", name: "Shopping & Personal Care", icon: "bag.fill", colorName: "systemPink", type: .expense, isSystemDefined: true),
            Category(id: "cat-health", name: "Health & Fitness", icon: "heart.fill", colorName: "systemRed", type: .expense, isSystemDefined: true),
            Category(id: "cat-finance", name: "Financial & Legal", icon: "creditcard.fill", colorName: "systemIndigo", type: .expense, isSystemDefined: true),
            Category(id: "cat-education", name: "Education & Work", icon: "book.fill", colorName: "systemTeal", type: .expense, isSystemDefined: true),

            // Income categories — all systemGreen, matching the app-wide income=green semantic
            Category(id: "cat-salary", name: "Salary", icon: "banknote.fill", colorName: "systemGreen", type: .income, isSystemDefined: true),
            Category(id: "cat-freelance", name: "Freelance & Business", icon: "briefcase.fill", colorName: "systemGreen", type: .income, isSystemDefined: true),
            Category(id: "cat-investments", name: "Investments", icon: "chart.line.uptrend.xyaxis", colorName: "systemGreen", type: .income, isSystemDefined: true),
            Category(id: "cat-gifts", name: "Gifts & Other", icon: "gift.fill", colorName: "systemGreen", type: .income, isSystemDefined: true)
        ]
        defaults.forEach { modelContext.insert($0) }
        try? modelContext.save()
    }
}
