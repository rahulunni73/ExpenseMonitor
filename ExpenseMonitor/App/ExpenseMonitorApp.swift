//
//  ExpenseMonitorApp.swift
//  ExpenseMonitor
//
//  Created by Ospyn on 13/07/26.
//

import SwiftUI
import SwiftData

@main
struct ExpenseMonitorApp: App {

    let sharedModelContainer: ModelContainer
    let transactionRepository: TransactionRepository
    let categoryRepository: CategoryRepository
    let loanRepository: LoanRepository
    let chitFundRepository: ChitFundRepository
    let debtRepository: DebtRepository

    @State private var themeManager = ThemeManager()

    init() {
        let schema = Schema([
            Transaction.self,
            Category.self,
            Loan.self,
            ChitFund.self,
            Debt.self,
        ])
        let modelConfiguration = ModelConfiguration(schema: schema, isStoredInMemoryOnly: false)

        let container: ModelContainer
        do {
            container = try ModelContainer(for: schema, configurations: [modelConfiguration])
        } catch {
            fatalError("Could not create ModelContainer: \(error)")
        }
        sharedModelContainer = container

        // Constructed exactly once, here, rather than fresh on every ContentView re-render —
        // every screen in the app pulls these from the environment instead of taking them as
        // init params.
        let context = container.mainContext
        transactionRepository = DefaultTransactionRepository(modelContext: context, entitlements: StubEntitlementsProvider())
        categoryRepository = DefaultCategoryRepository(modelContext: context)
        loanRepository = DefaultLoanRepository(modelContext: context)
        chitFundRepository = DefaultChitFundRepository(modelContext: context)
        debtRepository = DefaultDebtRepository(modelContext: context)
    }

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(themeManager)
                .environment(\.themeColors, themeManager.currentTheme.colors)
                .environment(\.typography, themeManager.currentTypography)
                .environment(\.transactionRepository, transactionRepository)
                .environment(\.categoryRepository, categoryRepository)
                .environment(\.loanRepository, loanRepository)
                .environment(\.chitFundRepository, chitFundRepository)
                .environment(\.debtRepository, debtRepository)
        }
        .modelContainer(sharedModelContainer)
    }
}
