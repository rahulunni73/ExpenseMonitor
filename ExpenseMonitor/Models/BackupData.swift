//
//  BackupData.swift
//  ExpenseMonitor
//

import Foundation

struct BackupData: Codable {
    var schemaVersion: Int
    var exportedAt: Date
    var expenses: [ExpenseDTO]
    var categories: [CategoryDTO]
    var loans: [LoanDTO]
    var chitFunds: [ChitFundDTO]
}

struct ExpenseDTO: Codable {
    var id: String
    var title: String
    var amount: Double
    var category: String
    var type: CategoryType
    var expenseDate: Date
    var note: String?
    var categoryIcon: String
    var linkedLoanID: String?
    var linkedChitFundID: String?
    var linkedInstallmentNumber: Int?

    init(from expense: Expense) {
        id = expense.id
        title = expense.title
        amount = expense.amount
        category = expense.category
        type = expense.type
        expenseDate = expense.expenseDate
        note = expense.note
        categoryIcon = expense.categoryIcon
        linkedLoanID = expense.linkedLoanID
        linkedChitFundID = expense.linkedChitFundID
        linkedInstallmentNumber = expense.linkedInstallmentNumber
    }

    func makeModel() -> Expense {
        Expense(
            id: id,
            title: title,
            amount: amount,
            category: category,
            type: type,
            expenseDate: expenseDate,
            note: note,
            categoryIcon: categoryIcon,
            linkedLoanID: linkedLoanID,
            linkedChitFundID: linkedChitFundID,
            linkedInstallmentNumber: linkedInstallmentNumber
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
