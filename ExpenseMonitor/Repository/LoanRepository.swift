//
//  LoanRepository.swift
//  ExpenseMonitor
//

import Foundation
import SwiftData

protocol LoanRepository {
    func fetchAll() -> [Loan]
    func add(_ loan: Loan)
    func update(_ loan: Loan)
    func delete(_ loan: Loan)
}

class DefaultLoanRepository: LoanRepository {
    private let modelContext: ModelContext

    init(modelContext: ModelContext) {
        self.modelContext = modelContext
    }

    func fetchAll() -> [Loan] {
        let descriptor = FetchDescriptor<Loan>(sortBy: [SortDescriptor(\.startDate, order: .reverse)])
        do {
            return try modelContext.fetch(descriptor)
        } catch {
            print("Failed to fetch loans: \(error)")
            return []
        }
    }

    func add(_ loan: Loan) {
        modelContext.insert(loan)
        try? modelContext.save()
    }

    func update(_ loan: Loan) {
        try? modelContext.save()
    }

    func delete(_ loan: Loan) {
        modelContext.delete(loan)
        try? modelContext.save()
    }
}
