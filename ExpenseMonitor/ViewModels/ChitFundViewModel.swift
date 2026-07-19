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
