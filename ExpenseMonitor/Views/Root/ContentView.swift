//
//  ContentView.swift
//  ExpenseMonitor
//
//  Created by Ospyn on 13/07/26.
//

import SwiftUI
import SwiftData


enum AppTab {
    case home, transactions, emi

    var title: String {
        switch self {
        case .home: return "Home"
        case .transactions: return "Transactions"
        case .emi: return "EMI"
        }
    }

    var icon: String {
        switch self {
        case .home: return "house.fill"
        case .transactions: return "arrow.up.arrow.down"
        case .emi: return "creditcard.fill"
        }
    }
}




struct ContentView: View {

    @Environment(\.themeColors) private var themeColors
    @Environment(\.transactionRepository) private var transactionRepository
    @Environment(\.categoryRepository) private var categoryRepository
    @Environment(\.loanRepository) private var loanRepository
    @Environment(\.chitFundRepository) private var chitFundRepository
    @State private var selectedTab: AppTab = .home

    var body: some View {
        TabView(selection: $selectedTab) {
            HomeView(
                entitlements: StubEntitlementsProvider(),
                transactionRepository: transactionRepository,
                categoryRepository: categoryRepository,
                loanRepository: loanRepository,
                chitFundRepository: chitFundRepository,
                isActive: selectedTab == .home,
                onViewAllTransactions: { selectedTab = .transactions }
            )
            .tabItem {
                Label(AppTab.home.title, systemImage: AppTab.home.icon)
            }
            .tag(AppTab.home)

            TransactionsListView(
                repository: transactionRepository,
                isActive: selectedTab == .transactions
            )
            .tabItem {
                Label(AppTab.transactions.title, systemImage: AppTab.transactions.icon)
            }
            .tag(AppTab.transactions)

            EMIListView(
                repository: loanRepository,
                chitFundRepository: chitFundRepository,
                isActive: selectedTab == .emi
            )
            .tabItem {
                Label(AppTab.emi.title, systemImage: AppTab.emi.icon)
            }
            .tag(AppTab.emi)
        }
        .tint(themeColors.accent)
        .onAppear {
            NotificationService.rescheduleReminders(loans: loanRepository.fetchAll(), chitFunds: chitFundRepository.fetchAll())
        }
    }
}

