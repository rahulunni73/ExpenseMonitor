//
//  DashboardView.swift
//  ExpenseMonitor
//
//  Created by Ospyn on 15/07/26.
//

import SwiftUI

struct DashboardView : View {

    let entitlements: EntitlementsProviding

    @State private var viewModel = DashboardViewModel()
    @State private var isSettingsPresented = false

    @Environment(\.typography) private var typography

    var body: some View {
        VStack(spacing: 0) {
            HStack {
                Text("Dashboard")
                    .font(typography.title2Bold)
                Spacer()
                Button {
                    isSettingsPresented = true
                } label: {
                    Image(systemName: "gearshape.fill")
                        .font(.system(size: 20))
                        .foregroundStyle(.secondary)
                        .frame(width: 44, height: 44)
                }
            }
            .padding(.horizontal)
            .padding(.top)

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
            .scrollIndicators(.hidden, axes: .vertical)
        }
        .background(Color(.systemGroupedBackground))
        .fullScreenCover(isPresented: $isSettingsPresented) {
            SettingsView(entitlements: entitlements)
        }
    }


}


#Preview {
    DashboardView(entitlements: StubEntitlementsProvider())
}
