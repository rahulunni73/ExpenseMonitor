//
//  ReportsView.swift
//  ExpenseMonitor
//

import SwiftUI
import SwiftData

struct ReportsView: View {
    let expenseRepository: ExpenseRepository
    let loanRepository: LoanRepository
    let chitFundRepository: ChitFundRepository

    @State private var viewModel: ReportsViewModel

    @Environment(\.dismiss) private var dismiss
    @Environment(\.themeColors) private var themeColors
    @Environment(\.typography) private var typography

    init(expenseRepository: ExpenseRepository, loanRepository: LoanRepository, chitFundRepository: ChitFundRepository) {
        self.expenseRepository = expenseRepository
        self.loanRepository = loanRepository
        self.chitFundRepository = chitFundRepository
        _viewModel = State(initialValue: ReportsViewModel(
            expenseRepository: expenseRepository,
            loanRepository: loanRepository,
            chitFundRepository: chitFundRepository
        ))
    }

    var body: some View {
        VStack(spacing: 0) {
            HStack {
                Button("Done") {
                    dismiss()
                }
                Spacer()
                Text("Reports")
                    .font(typography.headline)
                Spacer()
                Color.clear
                    .frame(width: 44, height: 44)
            }
            .padding()

            PeriodChipStrip(granularity: $viewModel.granularity, referenceDate: $viewModel.referenceDate)
                .padding(.horizontal)

            ScrollView {
                VStack(alignment: .leading, spacing: 16) {
                    VStack(alignment: .leading, spacing: 8) {
                        NetBalanceCard(
                            balance: viewModel.netBalance,
                            income: viewModel.income,
                            expense: viewModel.expense
                        )

                        if let delta = viewModel.expenseDelta {
                            comparisonLine(delta: delta)
                        }
                    }

                    if viewModel.spendingPoints.isEmpty {
                        noExpenseDataView
                    } else {
                        SpendingTrendCard(points: viewModel.spendingPoints)

                        ExpenseBreakdownCard(data: viewModel.breakdownData)
                    }

                    if let burden = viewModel.burdenPercent {
                        BurdenRatioCard(percent: burden)
                    }
                }
                .padding(.horizontal)
                .padding(.top, 12)
            }
            .scrollIndicators(.hidden, axes: .vertical)
        }
        .background(themeColors.background)
        .onAppear {
            viewModel.loadData()
        }
    }

    private var noExpenseDataView: some View {
        VStack(spacing: 10) {
            Image(systemName: "chart.bar.xaxis")
                .font(.system(size: 30))
                .foregroundStyle(.secondary)
            Text("No expenses for this period")
                .font(typography.headline)
            Text("Spending trend and category breakdown will show up here once you add expenses in this period.")
                .font(typography.subheadline)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 24)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 20)
        .background(themeColors.surface)
        .clipShape(RoundedRectangle(cornerRadius: 16))
        .overlay {
            RoundedRectangle(cornerRadius: 16)
                .strokeBorder(Color.primary.opacity(0.08), lineWidth: 1)
        }
    }

    private func comparisonLine(delta: Double) -> some View {
        let increased = delta > 0
        let periodLabel: String = {
            switch viewModel.granularity {
            case .week: return "last week"
            case .month: return "last month"
            case .year: return "last year"
            }
        }()
        return HStack(spacing: 4) {
            Image(systemName: increased ? "arrow.up.right" : "arrow.down.right")
            Text("\(abs(delta).currencyFormatted) \(increased ? "more" : "less") than \(periodLabel)")
        }
        .font(typography.caption)
        .foregroundStyle(increased ? themeColors.expense : themeColors.income)
        .padding(.horizontal)
    }
}

#Preview {
    let container = try! ModelContainer(
        for: Expense.self, Loan.self, ChitFund.self,
        configurations: ModelConfiguration(isStoredInMemoryOnly: true)
    )
    ReportsView(
        expenseRepository: DefaultExpenseRepository(modelContext: container.mainContext, entitlements: StubEntitlementsProvider()),
        loanRepository: DefaultLoanRepository(modelContext: container.mainContext),
        chitFundRepository: DefaultChitFundRepository(modelContext: container.mainContext)
    )
}
