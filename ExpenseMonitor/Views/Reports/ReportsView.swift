//
//  ReportsView.swift
//  ExpenseMonitor
//

import SwiftUI
import SwiftData

struct ReportsView: View {
    let expenseRepository: ExpenseRepository
    let categoryRepository: CategoryRepository
    let loanRepository: LoanRepository
    let chitFundRepository: ChitFundRepository

    @State private var viewModel: ReportsViewModel
    @State private var drillDown: TransactionDrillDown?
    @State private var yearInReviewToShow: YearInReview?

    @Environment(\.dismiss) private var dismiss
    @Environment(\.themeColors) private var themeColors
    @Environment(\.typography) private var typography

    init(expenseRepository: ExpenseRepository, categoryRepository: CategoryRepository, loanRepository: LoanRepository, chitFundRepository: ChitFundRepository) {
        self.expenseRepository = expenseRepository
        self.categoryRepository = categoryRepository
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

            PeriodChipStrip(granularity: $viewModel.granularity, referenceDate: $viewModel.referenceDate, customRange: $viewModel.customRange)
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

                    if let review = viewModel.yearInReview {
                        yearInReviewTeaser(review)
                    }

                    if viewModel.spendingPoints.isEmpty {
                        noExpenseDataView
                    } else {
                        SpendingTrendCard(points: viewModel.spendingPoints) { point in
                            drillDown = TransactionDrillDown(
                                title: point.day,
                                expenses: viewModel.expenses(onDate: point.date)
                            )
                        }

                        ExpenseBreakdownCard(data: viewModel.breakdownData) { category in
                            drillDown = TransactionDrillDown(
                                title: category,
                                expenses: viewModel.expenses(inCategory: category)
                            )
                        }
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
        .sheet(item: $drillDown) { drillDown in
            TransactionListSheet(
                title: drillDown.title,
                expenses: drillDown.expenses,
                onChange: { viewModel.loadData() }
            )
        }
        .sheet(item: $yearInReviewToShow) { review in
            YearInReviewView(review: review)
        }
    }

    private func yearInReviewTeaser(_ review: YearInReview) -> some View {
        Button {
            yearInReviewToShow = review
        } label: {
            HStack(spacing: 14) {
                Image(systemName: "sparkles")
                    .font(.system(size: 20))
                    .foregroundStyle(.white)
                    .frame(width: 44, height: 44)
                    .background(themeColors.accent)
                    .clipShape(Circle())

                VStack(alignment: .leading, spacing: 2) {
                    Text("\(String(review.year)) Year in Review")
                        .font(typography.subheadlineBold)
                        .foregroundStyle(.primary)
                    Text("See your year at a glance")
                        .font(typography.caption)
                        .foregroundStyle(.secondary)
                }

                Spacer()

                Image(systemName: "chevron.right")
                    .font(.system(size: 13, weight: .semibold))
                    .foregroundStyle(.secondary)
            }
            .padding()
            .background(themeColors.surface)
            .clipShape(RoundedRectangle(cornerRadius: 16))
            .overlay {
                RoundedRectangle(cornerRadius: 16)
                    .strokeBorder(Color.primary.opacity(0.08), lineWidth: 1)
            }
        }
        .buttonStyle(.plain)
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
            case .custom: return "the previous period"
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

private struct TransactionDrillDown: Identifiable {
    let id = UUID()
    let title: String
    let expenses: [Expense]
}

#Preview {
    let container = try! ModelContainer(
        for: Expense.self, Category.self, Loan.self, ChitFund.self,
        configurations: ModelConfiguration(isStoredInMemoryOnly: true)
    )
    ReportsView(
        expenseRepository: DefaultExpenseRepository(modelContext: container.mainContext, entitlements: StubEntitlementsProvider()),
        categoryRepository: DefaultCategoryRepository(modelContext: container.mainContext),
        loanRepository: DefaultLoanRepository(modelContext: container.mainContext),
        chitFundRepository: DefaultChitFundRepository(modelContext: container.mainContext)
    )
}
