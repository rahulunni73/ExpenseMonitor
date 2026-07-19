//
//  ContentView.swift
//  ExpenseMonitor
//
//  Created by Ospyn on 13/07/26.
//

import SwiftUI
import SwiftData


enum AppTab {
    case expenses, emi, dashboard, reports
    
    var title: String {
        switch self {
        case .expenses: return "Expenses"
        case .emi: return "EMI"
        case .dashboard: return "Dashboard"
        case .reports: return "Reports"
        }
    }
    
    var icon: String {
        switch self {
        case .expenses: return "list.bullet"
        case .emi: return "creditcard.fill"
        case .dashboard: return "chart.pie.fill"
        case .reports: return "chart.bar.fill"
        }
    }
}




struct ContentView: View {
    
    @Environment(\.modelContext) private var modelContext
    @Environment(\.themeColors) private var themeColors
    @Environment(\.typography) private var typography
    @State private var selectedTab: AppTab = .expenses

    var body: some View {
        VStack(spacing:0){
            ZStack {
                DashboardView(entitlements: StubEntitlementsProvider())
                    .opacity(selectedTab == .dashboard ? 1 : 0)
                    .allowsHitTesting(selectedTab == .dashboard)
                
                ExpensesListView(
                    repository: DefaultExpenseRepository(
                        modelContext: modelContext,
                        entitlements: StubEntitlementsProvider()
                    ),
                    categoryRepository: DefaultCategoryRepository(modelContext: modelContext),
                    isActive: selectedTab == .expenses
                )
                .opacity(selectedTab == .expenses ? 1 : 0)
                .allowsHitTesting(selectedTab == .expenses)
                
                EMIListView(
                    repository: DefaultLoanRepository(modelContext: modelContext),
                    chitFundRepository: DefaultChitFundRepository(modelContext: modelContext),
                    expenseRepository: DefaultExpenseRepository(
                        modelContext: modelContext,
                        entitlements: StubEntitlementsProvider()
                    ),
                    isActive: selectedTab == .emi
                )
                .opacity(selectedTab == .emi ? 1 : 0)
                .allowsHitTesting(selectedTab == .emi)
                
                Text("Reports")
                    .opacity(selectedTab == .reports ? 1 : 0)
                    .allowsHitTesting(selectedTab == .reports)
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)

            customTabBar
        }
    }
    
    
    private func tabButton(_ tab: AppTab) -> some View {
        Button {
            selectedTab = tab
        } label: {
            VStack(spacing: 4) {
                Image(systemName: tab.icon)
                    .font(.system(size: 20))
                Text(tab.title)
                    .font(typography.caption2)
            }
            .foregroundStyle(selectedTab == tab ? themeColors.accent : .secondary)
            .frame(maxWidth: .infinity)
        }
        .buttonStyle(.plain)
    }

    private var customTabBar: some View {
        HStack(spacing: 0) {
            tabButton(.expenses)
            tabButton(.emi)
            tabButton(.dashboard)
            tabButton(.reports)
        }
        .padding(.top, 8)
        .background(themeColors.surface)
    }
    
}

