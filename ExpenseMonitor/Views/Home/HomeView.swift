//
//  HomeView.swift
//  ExpenseMonitor
//
//  Created by Ospyn on 15/07/26.
//

import SwiftUI
import SwiftData

struct HomeView : View {

    let entitlements: EntitlementsProviding
    let expenseRepository: ExpenseRepository
    let loanRepository: LoanRepository
    let chitFundRepository: ChitFundRepository
    let isActive: Bool

    @State private var viewModel: HomeViewModel
    @State private var isSettingsPresented = false
    @State private var isReportsPresented = false

    @Environment(\.themeColors) private var themeColors
    @Environment(\.typography) private var typography

    init(entitlements: EntitlementsProviding, expenseRepository: ExpenseRepository, loanRepository: LoanRepository, chitFundRepository: ChitFundRepository, isActive: Bool) {
        self.entitlements = entitlements
        self.expenseRepository = expenseRepository
        self.loanRepository = loanRepository
        self.chitFundRepository = chitFundRepository
        self.isActive = isActive
        _viewModel = State(initialValue: HomeViewModel(
            expenseRepository: expenseRepository,
            loanRepository: loanRepository,
            chitFundRepository: chitFundRepository
        ))
    }

    var body: some View {
        VStack(spacing: 0) {
            HStack {
                Text("Home")
                    .font(typography.title2Bold)
                Spacer()
                Button {
                    isReportsPresented = true
                } label: {
                    Image(systemName: "chart.bar.fill")
                        .font(.system(size: 20))
                        .foregroundStyle(.secondary)
                        .frame(width: 44, height: 44)
                }
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

                    if viewModel.hasLoans || viewModel.hasCreditCards || viewModel.hasChitFunds {
                        LoanChitSummaryCard(
                            showLoans: viewModel.hasLoans,
                            loanDue: viewModel.loanDueAmount,
                            loanPaid: viewModel.loanPaidAmount,
                            showCreditCards: viewModel.hasCreditCards,
                            creditCardDue: viewModel.creditCardDueAmount,
                            creditCardPaid: viewModel.creditCardPaidAmount,
                            showChitFunds: viewModel.hasChitFunds,
                            chitDue: viewModel.chitDueAmount,
                            chitPaid: viewModel.chitPaidAmount
                        )
                    }

                    RecentTransactionsCard(transactions: viewModel.recentTransactions)
                }

            }
            .padding(.horizontal)
            .scrollIndicators(.hidden, axes: .vertical)
        }
        .background(themeColors.background)
        .onAppear {
            viewModel.loadData()
        }
        .onChange(of: isActive) { _, newValue in
            if newValue {
                viewModel.loadData()
            }
        }
        .fullScreenCover(isPresented: $isSettingsPresented) {
            SettingsView(entitlements: entitlements)
        }
        .fullScreenCover(isPresented: $isReportsPresented) {
            ReportsView(
                expenseRepository: expenseRepository,
                loanRepository: loanRepository,
                chitFundRepository: chitFundRepository
            )
        }
    }


}


#Preview {
    let container = try! ModelContainer(
        for: Expense.self, Category.self, Loan.self, ChitFund.self,
        configurations: ModelConfiguration(isStoredInMemoryOnly: true)
    )
    HomeView(
        entitlements: StubEntitlementsProvider(),
        expenseRepository: DefaultExpenseRepository(modelContext: container.mainContext, entitlements: StubEntitlementsProvider()),
        loanRepository: DefaultLoanRepository(modelContext: container.mainContext),
        chitFundRepository: DefaultChitFundRepository(modelContext: container.mainContext),
        isActive: true
    )
}
