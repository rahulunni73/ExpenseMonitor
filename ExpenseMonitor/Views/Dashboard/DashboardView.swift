//
//  DashboardView.swift
//  ExpenseMonitor
//
//  Created by Ospyn on 15/07/26.
//

import SwiftUI

struct DashboardView : View {
    
    @State private var viewModel = DashboardViewModel()
    
    
    var body: some View {
        ScrollView {
            VStack(alignment:.leading,spacing: 16) {
                
                NetBalanceCard(
                    balance: viewModel.netBalance,
                    income: viewModel.income,
                    expense: viewModel.expense
                )

                PeriodSelector()

                SpendingTrendCard(points: viewModel.spendingPoints)

                ExpenseBreakdownCard(data: viewModel.breakdownData)

                RecentTransactionsCard(transactions: viewModel.recentTransactions)

                EMIReminderCard(
                    title: viewModel.emiReminderTitle,
                    subtitle: viewModel.emiReminderSubtitle
                )
            }
            
        }
        .padding(.horizontal)
        .background(Color(.systemGroupedBackground))
        .scrollIndicators(.hidden, axes: .vertical)
    }
    
    
}


//#Preview {
//    DashboardView()
//}
