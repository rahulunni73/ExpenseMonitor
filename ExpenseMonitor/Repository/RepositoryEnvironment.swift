//
//  RepositoryEnvironment.swift
//  ExpenseMonitor
//

import SwiftUI

/// Environment-based dependency injection for the four repositories — mirrors the pattern
/// `Theming/ThemeEnvironment.swift` already established for `themeColors`/`typography`. Each
/// repository is constructed exactly once, in `ExpenseMonitorApp`, and injected at the root —
/// no view constructs its own repository instance anymore, and none of these need to be threaded
/// through every intermediate view's `init`.
///
/// `defaultValue` must be a genuinely harmless, always-safe-to-construct value — NOT a
/// `fatalError()`. These four properties are implemented as computed `get`/`set` (not plain
/// stored properties), and Swift's `WritableKeyPath` machinery for a computed property is a
/// read-modify-write: even the very first `.environment(\.chitFundRepository, ...)` call reads
/// the "current" value before writing the new one, which falls through to `defaultValue`. A
/// `fatalError` default crashes on that very first injection, every launch, before the real
/// value is ever set — not on some later "injection missed" case as intended. (`themeColors`/
/// `typography` never hit this because their defaults already return real, harmless values.)

private struct EmptyTransactionRepository: TransactionRepository {
    func fetchAll() -> [Transaction] { [] }
    func add(_ transaction: Transaction) {}
    func update(_ transaction: Transaction) {}
    func delete(_ transaction: Transaction) {}
}

private struct EmptyCategoryRepository: CategoryRepository {
    func fetchAll() -> [Category] { [] }
    func add(_ category: Category) {}
    func update(_ category: Category) {}
    func delete(_ category: Category) {}
}

private struct EmptyLoanRepository: LoanRepository {
    func fetchAll() -> [Loan] { [] }
    func add(_ loan: Loan) {}
    func update(_ loan: Loan) {}
    func delete(_ loan: Loan) {}
}

private struct EmptyChitFundRepository: ChitFundRepository {
    func fetchAll() -> [ChitFund] { [] }
    func add(_ chitFund: ChitFund) {}
    func update(_ chitFund: ChitFund) {}
    func delete(_ chitFund: ChitFund) {}
}

private struct EmptyDebtRepository: DebtRepository {
    func fetchAll() -> [Debt] { [] }
    func add(_ debt: Debt) {}
    func update(_ debt: Debt) {}
    func delete(_ debt: Debt) {}
}

private struct TransactionRepositoryKey: EnvironmentKey {
    static let defaultValue: TransactionRepository = EmptyTransactionRepository()
}

private struct CategoryRepositoryKey: EnvironmentKey {
    static let defaultValue: CategoryRepository = EmptyCategoryRepository()
}

private struct LoanRepositoryKey: EnvironmentKey {
    static let defaultValue: LoanRepository = EmptyLoanRepository()
}

private struct ChitFundRepositoryKey: EnvironmentKey {
    static let defaultValue: ChitFundRepository = EmptyChitFundRepository()
}

private struct DebtRepositoryKey: EnvironmentKey {
    static let defaultValue: DebtRepository = EmptyDebtRepository()
}

extension EnvironmentValues {
    var transactionRepository: TransactionRepository {
        get { self[TransactionRepositoryKey.self] }
        set { self[TransactionRepositoryKey.self] = newValue }
    }

    var categoryRepository: CategoryRepository {
        get { self[CategoryRepositoryKey.self] }
        set { self[CategoryRepositoryKey.self] = newValue }
    }

    var loanRepository: LoanRepository {
        get { self[LoanRepositoryKey.self] }
        set { self[LoanRepositoryKey.self] = newValue }
    }

    var chitFundRepository: ChitFundRepository {
        get { self[ChitFundRepositoryKey.self] }
        set { self[ChitFundRepositoryKey.self] = newValue }
    }

    var debtRepository: DebtRepository {
        get { self[DebtRepositoryKey.self] }
        set { self[DebtRepositoryKey.self] = newValue }
    }
}
