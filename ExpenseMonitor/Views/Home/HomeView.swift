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
    let transactionRepository: TransactionRepository
    let categoryRepository: CategoryRepository
    let loanRepository: LoanRepository
    let chitFundRepository: ChitFundRepository
    let debtRepository: DebtRepository
    let isActive: Bool
    var onViewAllTransactions: (() -> Void)? = nil

    @State private var viewModel: HomeViewModel
    @State private var isSettingsPresented = false
    @State private var isReportsPresented = false
    @AppStorage("debtsTabEnabled") private var debtsTabEnabled = false

    @Environment(\.themeColors) private var themeColors
    @Environment(\.typography) private var typography

    init(entitlements: EntitlementsProviding, transactionRepository: TransactionRepository, categoryRepository: CategoryRepository, loanRepository: LoanRepository, chitFundRepository: ChitFundRepository, debtRepository: DebtRepository, isActive: Bool, onViewAllTransactions: (() -> Void)? = nil) {
        self.entitlements = entitlements
        self.transactionRepository = transactionRepository
        self.categoryRepository = categoryRepository
        self.loanRepository = loanRepository
        self.chitFundRepository = chitFundRepository
        self.debtRepository = debtRepository
        self.isActive = isActive
        self.onViewAllTransactions = onViewAllTransactions
        _viewModel = State(initialValue: HomeViewModel(
            transactionRepository: transactionRepository,
            loanRepository: loanRepository,
            chitFundRepository: chitFundRepository,
            debtRepository: debtRepository
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
                        .foregroundStyle(themeColors.accent)
                        .frame(width: 44, height: 44)
                }
                Button {
                    isSettingsPresented = true
                } label: {
                    Image(systemName: "gearshape.fill")
                        .font(.system(size: 20))
                        .foregroundStyle(themeColors.accent)
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

                    if debtsTabEnabled {
                        DebtsSummaryCard(owedToMe: viewModel.totalOwedToMe, owedByMe: viewModel.totalOwedByMe)
                    }

                    RecentTransactionsCard(transactions: viewModel.recentTransactions, onViewAll: onViewAllTransactions)
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
        .onReceive(NotificationCenter.default.publisher(for: .transactionsDidChange)) { _ in
            viewModel.loadData()
        }
        .fullScreenCover(isPresented: $isSettingsPresented) {
            SettingsView(entitlements: entitlements)
        }
        .fullScreenCover(isPresented: $isReportsPresented) {
            ReportsView(
                transactionRepository: transactionRepository,
                categoryRepository: categoryRepository,
                loanRepository: loanRepository,
                chitFundRepository: chitFundRepository
            )
        }
    }


}


#Preview {
    let container = try! ModelContainer(
        for: Transaction.self, Category.self, Loan.self, ChitFund.self, Debt.self,
        configurations: ModelConfiguration(isStoredInMemoryOnly: true)
    )
    HomeView(
        entitlements: StubEntitlementsProvider(),
        transactionRepository: DefaultTransactionRepository(modelContext: container.mainContext, entitlements: StubEntitlementsProvider()),
        categoryRepository: DefaultCategoryRepository(modelContext: container.mainContext),
        loanRepository: DefaultLoanRepository(modelContext: container.mainContext),
        chitFundRepository: DefaultChitFundRepository(modelContext: container.mainContext),
        debtRepository: DefaultDebtRepository(modelContext: container.mainContext),
        isActive: true
    )
}
