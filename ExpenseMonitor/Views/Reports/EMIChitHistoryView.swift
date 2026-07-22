//
//  EMIChitHistoryView.swift
//  ExpenseMonitor
//

import SwiftUI
import SwiftData

struct EMIChitHistoryView: View {
    let transactionRepository: TransactionRepository
    let loanRepository: LoanRepository
    let chitFundRepository: ChitFundRepository

    @State private var viewModel: EMIChitHistoryViewModel
    @State private var monthForDrillDown: EMIMonthGroup?

    @Environment(\.dismiss) private var dismiss
    @Environment(\.themeColors) private var themeColors
    @Environment(\.typography) private var typography

    init(transactionRepository: TransactionRepository, loanRepository: LoanRepository, chitFundRepository: ChitFundRepository) {
        self.transactionRepository = transactionRepository
        self.loanRepository = loanRepository
        self.chitFundRepository = chitFundRepository
        _viewModel = State(initialValue: EMIChitHistoryViewModel(
            transactionRepository: transactionRepository,
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
                Text("EMI & Chit History")
                    .font(typography.headline)
                Spacer()
                Color.clear
                    .frame(width: 44, height: 44)
            }
            .padding()

            if viewModel.yearGroups.isEmpty && viewModel.upcomingYearGroups.isEmpty {
                VStack(spacing: 12) {
                    Image(systemName: "calendar.badge.clock")
                        .font(.system(size: 40))
                        .foregroundStyle(.secondary)
                    Text("No EMI or Chit payments recorded yet")
                        .font(typography.headline)
                    Text("Once you mark an EMI or chit contribution as paid, it'll show up here grouped by month and year.")
                        .font(typography.subheadline)
                        .foregroundStyle(.secondary)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 32)
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            } else {
                List {
                    if !viewModel.yearGroups.isEmpty {
                        ForEach(viewModel.yearGroups) { yearGroup in
                            Section {
                                ForEach(yearGroup.months) { month in
                                    monthRow(month)
                                        .onTapGesture {
                                            monthForDrillDown = month
                                        }
                                }
                            } header: {
                                yearHeader(yearGroup)
                            }
                        }
                    }

                    if !viewModel.upcomingYearGroups.isEmpty {
                        ForEach(viewModel.upcomingYearGroups) { yearGroup in
                            Section {
                                ForEach(yearGroup.months) { month in
                                    upcomingMonthRow(month)
                                }
                            } header: {
                                upcomingYearHeader(yearGroup)
                            }
                        }
                    }
                }
                .listStyle(.insetGrouped)
            }
        }
        .background(themeColors.background)
        .onAppear {
            viewModel.loadData()
        }
        .sheet(item: $monthForDrillDown) { month in
            TransactionListSheet(
                title: month.date.formatted(.dateTime.month(.wide).year()),
                transactions: month.transactions,
                onChange: { viewModel.loadData() }
            )
        }
    }

    private func upcomingYearHeader(_ yearGroup: UpcomingYearGroup) -> some View {
        HStack(spacing: 6) {
            Image(systemName: "clock.fill")
                .font(.system(size: 12))
                .foregroundStyle(themeColors.expense)
            Text("\(String(yearGroup.year)) · Upcoming")
                .font(typography.subheadlineBold)
                .foregroundStyle(.primary)
            Spacer()
            Text(yearGroup.total.currencyFormatted)
                .font(typography.subheadlineBold)
                .foregroundStyle(themeColors.expense)
        }
    }

    private func upcomingMonthRow(_ month: UpcomingMonthGroup) -> some View {
        HStack {
            Text(month.date.formatted(.dateTime.month(.wide)))
                .font(typography.body)
            Spacer()
            Text(month.total.currencyFormatted)
                .font(typography.amount(size: 15))
                .foregroundStyle(themeColors.expense)
        }
    }

    private func yearHeader(_ yearGroup: EMIYearGroup) -> some View {
        HStack(spacing: 6) {
            Image(systemName: "checkmark.circle.fill")
                .font(.system(size: 12))
                .foregroundStyle(themeColors.income)
            Text(String(yearGroup.year))
                .font(typography.subheadlineBold)
                .foregroundStyle(.primary)
            Spacer()
            Text(yearGroup.total.currencyFormatted)
                .font(typography.subheadlineBold)
                .foregroundStyle(themeColors.accent)
        }
    }

    private func monthRow(_ month: EMIMonthGroup) -> some View {
        HStack {
            Text(month.date.formatted(.dateTime.month(.wide)))
                .font(typography.body)
            Spacer()
            Text(month.total.currencyFormatted)
                .font(typography.amount(size: 15))
        }
        .contentShape(Rectangle())
    }
}

#Preview {
    let container = try! ModelContainer(
        for: Transaction.self, Loan.self, ChitFund.self,
        configurations: ModelConfiguration(isStoredInMemoryOnly: true)
    )
    EMIChitHistoryView(
        transactionRepository: DefaultTransactionRepository(modelContext: container.mainContext, entitlements: StubEntitlementsProvider()),
        loanRepository: DefaultLoanRepository(modelContext: container.mainContext),
        chitFundRepository: DefaultChitFundRepository(modelContext: container.mainContext)
    )
}
