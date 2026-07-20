//
//  DebtsViewModel.swift
//  ExpenseMonitor
//

import Foundation

@Observable
class DebtsViewModel {
    private let repository: DebtRepository
    var debts: [Debt] = []
    var searchText: String = ""

    init(repository: DebtRepository) {
        self.repository = repository
        loadDebts()
    }

    private func matchesSearch(_ debt: Debt) -> Bool {
        searchText.isEmpty || debt.personName.localizedCaseInsensitiveContains(searchText)
    }

    var owedToMe: [Debt] {
        debts.filter { $0.direction == .owedToMe && !$0.isSettled && matchesSearch($0) }
    }

    var owedByMe: [Debt] {
        debts.filter { $0.direction == .owedByMe && !$0.isSettled && matchesSearch($0) }
    }

    /// Both directions merged into one list, distinguished per-row by color and icon rather
    /// than a separate filter toggle — the two are visually clear enough on their own.
    var activeDebts: [Debt] {
        (owedToMe + owedByMe).sorted { $0.date > $1.date }
    }

    var completedDebts: [Debt] {
        debts.filter { $0.isSettled && matchesSearch($0) }
            .sorted { ($0.settledDate ?? $0.date) > ($1.settledDate ?? $1.date) }
    }

    var totalOwedToMe: Double {
        owedToMe.reduce(0) { $0 + $1.remainingAmount }
    }

    var totalOwedByMe: Double {
        owedByMe.reduce(0) { $0 + $1.remainingAmount }
    }

    func loadDebts() {
        debts = repository.fetchAll()
    }

    func addDebt(_ debt: Debt) {
        repository.add(debt)
        loadDebts()
    }

    func deleteDebt(_ debt: Debt) {
        repository.delete(debt)
        loadDebts()
    }
}
