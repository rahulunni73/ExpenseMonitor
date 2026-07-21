//
//  BackupData.swift
//  ExpenseMonitor
//

import Foundation

struct BackupData: Codable {
    var schemaVersion: Int
    var exportedAt: Date
    var transactions: [TransactionDTO]
    var categories: [CategoryDTO]
    var loans: [LoanDTO]
    var chitFunds: [ChitFundDTO]
    var debts: [DebtDTO]

    enum CodingKeys: String, CodingKey {
        case schemaVersion, exportedAt, transactions, categories, loans, chitFunds, debts
    }

    init(schemaVersion: Int, exportedAt: Date, transactions: [TransactionDTO], categories: [CategoryDTO], loans: [LoanDTO], chitFunds: [ChitFundDTO], debts: [DebtDTO]) {
        self.schemaVersion = schemaVersion
        self.exportedAt = exportedAt
        self.transactions = transactions
        self.categories = categories
        self.loans = loans
        self.chitFunds = chitFunds
        self.debts = debts
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        schemaVersion = try container.decode(Int.self, forKey: .schemaVersion)
        exportedAt = try container.decode(Date.self, forKey: .exportedAt)
        transactions = try container.decode([TransactionDTO].self, forKey: .transactions)
        categories = try container.decode([CategoryDTO].self, forKey: .categories)
        loans = try container.decode([LoanDTO].self, forKey: .loans)
        chitFunds = try container.decode([ChitFundDTO].self, forKey: .chitFunds)
        // Backups exported before Debt support existed won't have this key —
        // treat that as "no debts" instead of failing the whole restore.
        debts = try container.decodeIfPresent([DebtDTO].self, forKey: .debts) ?? []
    }
}

extension BackupData {
    /// The earliest-to-latest span of every dated record in the backup (transaction dates,
    /// loan/chit-fund start dates, debt dates) — nil only when the backup is entirely empty.
    var dateRange: ClosedRange<Date>? {
        var dates = transactions.map(\.date)
        dates += loans.map(\.startDate)
        dates += chitFunds.map(\.startDate)
        dates += debts.map(\.date)

        guard let earliest = dates.min(), let latest = dates.max() else { return nil }
        return earliest...latest
    }
}

struct TransactionDTO: Codable {
    var id: String
    var title: String
    var amount: Double
    var category: String
    var type: CategoryType
    var date: Date
    var note: String?
    var categoryIcon: String
    var linkedLoanID: String?
    var linkedChitFundID: String?
    var linkedInstallmentNumber: Int?

    init(from transaction: Transaction) {
        id = transaction.id
        title = transaction.title
        amount = transaction.amount
        category = transaction.category
        type = transaction.type
        date = transaction.date
        note = transaction.note
        categoryIcon = transaction.categoryIcon
        linkedLoanID = transaction.linkedLoanID
        linkedChitFundID = transaction.linkedChitFundID
        linkedInstallmentNumber = transaction.linkedInstallmentNumber
    }

    func makeModel() -> Transaction {
        Transaction(
            id: id,
            title: title,
            amount: amount,
            category: category,
            type: type,
            date: date,
            note: note,
            categoryIcon: categoryIcon,
            linkedLoanID: linkedLoanID,
            linkedChitFundID: linkedChitFundID,
            linkedInstallmentNumber: linkedInstallmentNumber
        )
    }
}

struct DebtDTO: Codable {
    var id: String
    var personName: String
    var direction: DebtDirection
    var amount: Double
    var amountRepaid: Double
    var date: Date
    var note: String?
    var isSettled: Bool
    var settledDate: Date?

    init(from debt: Debt) {
        id = debt.id
        personName = debt.personName
        direction = debt.direction
        amount = debt.amount
        amountRepaid = debt.amountRepaid
        date = debt.date
        note = debt.note
        isSettled = debt.isSettled
        settledDate = debt.settledDate
    }

    func makeModel() -> Debt {
        Debt(
            id: id,
            personName: personName,
            direction: direction,
            amount: amount,
            amountRepaid: amountRepaid,
            date: date,
            note: note,
            isSettled: isSettled,
            settledDate: settledDate
        )
    }
}

struct CategoryDTO: Codable {
    var id: String
    var name: String
    var icon: String
    var type: CategoryType
    var isSystemDefined: Bool

    init(from category: Category) {
        id = category.id
        name = category.name
        icon = category.icon
        type = category.type
        isSystemDefined = category.isSystemDefined
    }

    func makeModel() -> Category {
        Category(id: id, name: name, icon: icon, type: type, isSystemDefined: isSystemDefined)
    }
}

struct LoanDTO: Codable {
    var id: String
    var name: String
    var type: LoanType
    var lender: String?
    var principalAmount: Double
    var installmentAmount: Double
    var startDate: Date
    var numberOfInstallments: Int
    var paidInstallments: [Int]
    var penalties: [InstallmentPenalty]
    var note: String?

    init(from loan: Loan) {
        id = loan.id
        name = loan.name
        type = loan.type
        lender = loan.lender
        principalAmount = loan.principalAmount
        installmentAmount = loan.installmentAmount
        startDate = loan.startDate
        numberOfInstallments = loan.numberOfInstallments
        paidInstallments = loan.paidInstallments
        penalties = loan.penalties
        note = loan.note
    }

    func makeModel() -> Loan {
        Loan(
            id: id,
            name: name,
            type: type,
            lender: lender,
            principalAmount: principalAmount,
            installmentAmount: installmentAmount,
            startDate: startDate,
            numberOfInstallments: numberOfInstallments,
            paidInstallments: paidInstallments,
            penalties: penalties,
            note: note
        )
    }
}

struct ChitFundDTO: Codable {
    var id: String
    var name: String
    var organizer: String?
    var monthlyContribution: Double
    var chitValue: Double
    var startDate: Date
    var numberOfMonths: Int
    var paidContributions: [Int]
    var payoutMonth: Int?
    var payoutAmount: Double?
    var penalties: [InstallmentPenalty]
    var note: String?

    init(from chitFund: ChitFund) {
        id = chitFund.id
        name = chitFund.name
        organizer = chitFund.organizer
        monthlyContribution = chitFund.monthlyContribution
        chitValue = chitFund.chitValue
        startDate = chitFund.startDate
        numberOfMonths = chitFund.numberOfMonths
        paidContributions = chitFund.paidContributions
        payoutMonth = chitFund.payoutMonth
        payoutAmount = chitFund.payoutAmount
        penalties = chitFund.penalties
        note = chitFund.note
    }

    func makeModel() -> ChitFund {
        ChitFund(
            id: id,
            name: name,
            organizer: organizer,
            monthlyContribution: monthlyContribution,
            chitValue: chitValue,
            startDate: startDate,
            numberOfMonths: numberOfMonths,
            paidContributions: paidContributions,
            payoutMonth: payoutMonth,
            payoutAmount: payoutAmount,
            penalties: penalties,
            note: note
        )
    }
}
