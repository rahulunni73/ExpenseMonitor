//
//  ChitFundViewModel.swift
//  ExpenseMonitor
//

import Foundation

@Observable
class ChitFundViewModel {
    private let repository: ChitFundRepository
    var chitFunds: [ChitFund] = []

    init(repository: ChitFundRepository) {
        self.repository = repository
        loadChitFunds()
    }

    var activeChitFunds: [ChitFund] {
        chitFunds.filter { !$0.isCompleted }
    }

    var completedChitFunds: [ChitFund] {
        chitFunds.filter(\.isCompleted).sorted { $0.endDate > $1.endDate }
    }

    func loadChitFunds() {
        chitFunds = repository.fetchAll()
    }

    func addChitFund(_ chitFund: ChitFund) {
        repository.add(chitFund)
        loadChitFunds()
    }

    func deleteChitFund(_ chitFund: ChitFund) {
        repository.delete(chitFund)
        loadChitFunds()
    }
}
