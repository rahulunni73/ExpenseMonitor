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
        ])
        let modelConfiguration = ModelConfiguration(schema: schema, isStoredInMemoryOnly: false)

        do {
            return try ModelContainer(for: schema, configurations: [modelConfiguration])
        } catch {
            fatalError("Could not create ModelContainer: \(error)")
        }
    }()

    var body: some Scene {
        WindowGroup {
            ContentView()
        }
        .modelContainer(sharedModelContainer)
    }
}
