//
//  EMIViewModel.swift
//  ExpenseMonitor
//

import Foundation

@Observable
class EMIViewModel {
    private let repository: LoanRepository
    var loans: [Loan] = []

    init(repository: LoanRepository) {
        self.repository = repository
        loadLoans()
    }

    var activeLoans: [Loan] {
        loans.filter { !$0.isCompleted }
    }

    var completedLoans: [Loan] {
        loans.filter(\.isCompleted).sorted { $0.endDate > $1.endDate }
    }

    func loadLoans() {
        loans = repository.fetchAll()
    }

    func addLoan(_ loan: Loan) {
        repository.add(loan)
        loadLoans()
    }

    func deleteLoan(_ loan: Loan) {
        repository.delete(loan)
        loadLoans()
    }

    func toggleInstallment(_ loan: Loan, number: Int) {
        if loan.paidInstallments.contains(number) {
            loan.paidInstallments.removeAll { $0 == number }
        } else {
            loan.paidInstallments.append(number)
        }
        repository.update(loan)
        loadLoans()
    }
}
