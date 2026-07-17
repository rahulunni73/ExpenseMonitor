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
    @State private var selectedTab: AppTab = .expenses
    @State private var isAddExpensePresented = false
    
    var body: some View {
        VStack(spacing:0){
            ZStack {
                DashboardView()
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
                
                Text("EMI")
                    .opacity(selectedTab == .emi ? 1 : 0)
                    .allowsHitTesting(selectedTab == .emi)
                
                Text("Reports")
                    .opacity(selectedTab == .reports ? 1 : 0)
                    .allowsHitTesting(selectedTab == .reports)
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            
            customTabBar
            
            
        } .fullScreenCover(isPresented: $isAddExpensePresented) {
            AddExpenseView(
                repository: DefaultExpenseRepository(
                    modelContext: modelContext,
                    entitlements: StubEntitlementsProvider()
                ),
                categoryRepository: DefaultCategoryRepository(modelContext: modelContext)
            )
        }
        
        
        
        
        
        /*
         ZStack(alignment: .bottom) {
         TabView(selection: $selectedTab) {
         DashboardView()
         .tabItem {
         Label("Dashboard", systemImage: "chart.pie.fill")
         }.tag(0)
         
         ExpensesListView(repository: DefaultExpenseRepository(
         modelContext: modelContext,
         entitlements: StubEntitlementsProvider()
         )).tabItem {
         Label("Expenses", systemImage: "list.bullet")
         }.tag(1)
         Color.clear
         .tabItem { Text("") }.tag(2)
         Text("EMI")
         .tabItem {
         Label("EMI", systemImage: "creditcard.fill")
         }.tag(3)
         Text("Reports")
         .tabItem {
         Label("Reports", systemImage: "chart.bar.fill")
         }.tag(4)
         }
         .onChange(of:selectedTab){ oldValue, newValue in
         if newValue == 2 {
         selectedTab = oldValue   // snap back — don't let the blank tab "win"
         }
         }
         Button {
         isAddExpensePresented = true
         } label: {
         Image(systemName: "plus")
         .font(.title2.bold())
         .foregroundStyle(.white)
         .frame(width: 56, height: 56)
         .background(Color(.systemBlue))
         .clipShape(Circle())
         .shadow(radius: 4, y: 2)
         }
         
         }
         .fullScreenCover(isPresented: $isAddExpensePresented) {
         AddExpenseView(
         repository: DefaultExpenseRepository(
         modelContext: modelContext,
         entitlements: StubEntitlementsProvider()
         ),
         categoryRepository: DefaultCategoryRepository(modelContext: modelContext)
         )
         }
         */
        
    }
    
    
    private func tabButton(_ tab: AppTab) -> some View {
        Button {
            selectedTab = tab
        } label: {
            VStack(spacing: 4) {
                Image(systemName: tab.icon)
                    .font(.system(size: 20))
                Text(tab.title)
                    .font(.caption2)
            }
            .foregroundStyle(selectedTab == tab ? Color(.systemBlue) : .secondary)
            .frame(maxWidth: .infinity)
        }
        .buttonStyle(.plain)
    }

    private var fabButton: some View {
        Button {
            isAddExpensePresented = true
        } label: {
            Image(systemName: "plus")
                .font(.title2.bold())
                .foregroundStyle(.white)
                .frame(width: 56, height: 56)
                .background(Color(.systemBlue))
                .clipShape(Circle())
                .shadow(radius: 4, y: 2)
        }
        .offset(y: -20)
    }

    private var customTabBar: some View {
        HStack(spacing: 0) {
            tabButton(.expenses)
            tabButton(.emi)
            fabButton
            tabButton(.dashboard)
            tabButton(.reports)
        }
        .padding(.top, 8)
        .background(Color(.secondarySystemGroupedBackground))
    }
    
}

