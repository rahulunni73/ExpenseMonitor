//
//  BackupService.swift
//  ExpenseMonitor
//

import Foundation
import UniformTypeIdentifiers
import SwiftUI

struct BackupService {
    let expenseRepository: ExpenseRepository
    let categoryRepository: CategoryRepository
    let loanRepository: LoanRepository
    let chitFundRepository: ChitFundRepository

    func exportData() -> BackupData {
        BackupData(
            schemaVersion: 1,
            exportedAt: Date(),
            expenses: expenseRepository.fetchAll().map(ExpenseDTO.init),
            categories: categoryRepository.fetchAll().map(CategoryDTO.init),
            loans: loanRepository.fetchAll().map(LoanDTO.init),
            chitFunds: chitFundRepository.fetchAll().map(ChitFundDTO.init)
        )
    }

    func importData(_ backup: BackupData) {
        expenseRepository.fetchAll().forEach { expenseRepository.delete($0) }
        categoryRepository.fetchAll().forEach { categoryRepository.delete($0) }
        loanRepository.fetchAll().forEach { loanRepository.delete($0) }
        chitFundRepository.fetchAll().forEach { chitFundRepository.delete($0) }

        backup.categories.forEach { categoryRepository.add($0.makeModel()) }
        backup.loans.forEach { loanRepository.add($0.makeModel()) }
        backup.chitFunds.forEach { chitFundRepository.add($0.makeModel()) }
        backup.expenses.forEach { expenseRepository.add($0.makeModel()) }
    }
}

struct BackupDocument: FileDocument {
    static var readableContentTypes: [UTType] { [.json] }
    static var writableContentTypes: [UTType] { [.json] }

    var data: Data

    init(data: Data) {
        self.data = data
    }

    init(configuration: ReadConfiguration) throws {
        guard let fileData = configuration.file.regularFileContents else {
            throw CocoaError(.fileReadCorruptFile)
        }
        data = fileData
    }

    func fileWrapper(configuration: WriteConfiguration) throws -> FileWrapper {
        FileWrapper(regularFileWithContents: data)
    }
}

extension BackupData {
    static let jsonEncoder: JSONEncoder = {
        let encoder = JSONEncoder()
        encoder.dateEncodingStrategy = .iso8601
        encoder.outputFormatting = .prettyPrinted
        return encoder
    }()

    static let jsonDecoder: JSONDecoder = {
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        return decoder
    }()
}
