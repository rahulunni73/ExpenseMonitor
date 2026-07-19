//
//  ContentView.swift
//  ExpenseMonitor
//
//  Created by Ospyn on 13/07/26.
//

import SwiftUI
import SwiftData


enum AppTab {
    case home, expenses, emi

    var title: String {
        switch self {
        case .home: return "Home"
        case .expenses: return "Expenses"
        case .emi: return "EMI"
        }
    }

    var icon: String {
        switch self {
        case .home: return "house.fill"
        case .expenses: return "list.bullet"
        case .emi: return "creditcard.fill"
        }
    }
}




struct ContentView: View {
    
    @Environment(\.modelContext) private var modelContext
    @Environment(\.themeColors) private var themeColors
    @Environment(\.typography) private var typography
    @State private var selectedTab: AppTab = .home

    var body: some View {
        VStack(spacing:0){
            ZStack {
                HomeView(
                    entitlements: StubEntitlementsProvider(),
                    expenseRepository: DefaultExpenseRepository(
                        modelContext: modelContext,
                        entitlements: StubEntitlementsProvider()
                    ),
                    categoryRepository: DefaultCategoryRepository(modelContext: modelContext),
                    loanRepository: DefaultLoanRepository(modelContext: modelContext),
                    chitFundRepository: DefaultChitFundRepository(modelContext: modelContext),
                    isActive: selectedTab == .home
                )
                    .opacity(selectedTab == .home ? 1 : 0)
                    .allowsHitTesting(selectedTab == .home)

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
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)

            customTabBar
        }
        .onAppear {
            let loanRepository = DefaultLoanRepository(modelContext: modelContext)
            let chitFundRepository = DefaultChitFundRepository(modelContext: modelContext)
            NotificationService.rescheduleReminders(loans: loanRepository.fetchAll(), chitFunds: chitFundRepository.fetchAll())
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
            tabButton(.home)
            tabButton(.expenses)
            tabButton(.emi)
        }
        .padding(.top, 8)
        .background(themeColors.surface)
        .overlay(alignment: .top) {
            Rectangle()
                .fill(Color.primary.opacity(0.08))
                .frame(height: 1)
        }
    }
    
}

