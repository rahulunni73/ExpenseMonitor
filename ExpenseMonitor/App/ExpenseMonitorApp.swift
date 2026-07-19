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
    
    var sharedModelContainer: ModelContainer = {
        let schema = Schema([
            Expense.self,
            Category.self,
            Loan.self,
            ChitFund.self,
        ])
        let modelConfiguration = ModelConfiguration(schema: schema, isStoredInMemoryOnly: false)

        do {
            return try ModelContainer(for: schema, configurations: [modelConfiguration])
        } catch {
            fatalError("Could not create ModelContainer: \(error)")
        }
    }()

    @State private var themeManager = ThemeManager()

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(themeManager)
                .environment(\.themeColors, themeManager.currentTheme.colors)
                .environment(\.typography, themeManager.currentTypography)
        }
        .modelContainer(sharedModelContainer)
    }
}
