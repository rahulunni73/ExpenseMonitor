//
//  EMIListView.swift
//  ExpenseMonitor
//

import SwiftUI
import SwiftData

private enum EMISegment: String, CaseIterable {
    case loans = "Loans"
    case chitFunds = "Chit Funds"
}

struct EMIListView: View {
    let repository: LoanRepository
    let chitFundRepository: ChitFundRepository
    let isActive: Bool

    @State private var viewModel: EMIViewModel
    @State private var chitFundViewModel: ChitFundViewModel
    @State private var segment: EMISegment = .loans
    @State private var isAddLoanPresented = false
    @State private var isAddChitFundPresented = false
    @State private var loanForDetail: Loan?
    @State private var chitFundForDetail: ChitFund?

    @Environment(\.themeColors) private var themeColors
    @Environment(\.typography) private var typography

    init(repository: LoanRepository, chitFundRepository: ChitFundRepository, isActive: Bool) {
        self.repository = repository
        self.chitFundRepository = chitFundRepository
        self.isActive = isActive
        _viewModel = State(initialValue: EMIViewModel(repository: repository))
        _chitFundViewModel = State(initialValue: ChitFundViewModel(repository: chitFundRepository))
    }

    var body: some View {
        VStack(spacing: 0) {
            HStack {
                Text("EMI")
                    .font(typography.title2Bold)
                Spacer()
                Button {
                    if segment == .loans {
                        isAddLoanPresented = true
                    } else {
                        isAddChitFundPresented = true
                    }
                } label: {
                    Image(systemName: "plus")
                        .font(.system(size: 20))
                        .foregroundStyle(themeColors.accent)
                        .frame(width: 44, height: 44)
                }
            }
            .padding(.horizontal)
            .padding(.top)

            Picker("", selection: $segment) {
                ForEach(EMISegment.allCases, id: \.self) { segment in
                    Text(segment.rawValue).tag(segment)
                }
            }
            .pickerStyle(.segmented)
            .padding(.horizontal)
            .padding(.bottom, 8)

            if segment == .loans {
                loanList
            } else {
                chitFundList
            }
        }
        .background(themeColors.background)
        .onAppear {
            viewModel.loadLoans()
            chitFundViewModel.loadChitFunds()
        }
        .onChange(of: isActive) { _, newValue in
            if newValue {
                viewModel.loadLoans()
                chitFundViewModel.loadChitFunds()
            }
        }
        .fullScreenCover(isPresented: $isAddLoanPresented) {
            AddLoanView(onSave: { viewModel.loadLoans(); rescheduleReminders() })
        }
        .fullScreenCover(item: $loanForDetail, onDismiss: { viewModel.loadLoans(); rescheduleReminders() }) { loan in
            LoanDetailView(loan: loan, onChange: { viewModel.loadLoans(); rescheduleReminders() })
        }
        .fullScreenCover(isPresented: $isAddChitFundPresented) {
            AddChitFundView(onSave: { chitFundViewModel.loadChitFunds(); rescheduleReminders() })
        }
        .fullScreenCover(item: $chitFundForDetail, onDismiss: { chitFundViewModel.loadChitFunds(); rescheduleReminders() }) { chitFund in
            ChitFundDetailView(chitFund: chitFund, onChange: { chitFundViewModel.loadChitFunds(); rescheduleReminders() })
        }
    }

    private func rescheduleReminders() {
        NotificationService.rescheduleReminders(loans: repository.fetchAll(), chitFunds: chitFundRepository.fetchAll())
    }

    private var loanList: some View {
        Group {
            if viewModel.loans.isEmpty {
                emptyStateView(icon: "creditcard", title: "No loans tracked yet", message: "Tap the + button to add a loan or credit card EMI.")
            } else {
                ScrollView {
                    VStack(spacing: 12) {
                        ForEach(viewModel.loans) { loan in
                            loanCard(loan) {
                                loanForDetail = loan
                            }
                        }
                    }
                    .padding()
                }
            }
        }
    }

    private var chitFundList: some View {
        Group {
            if chitFundViewModel.chitFunds.isEmpty {
                emptyStateView(icon: "person.3", title: "No chit funds tracked yet", message: "Tap the + button to add a chit fund you're contributing to.")
            } else {
                ScrollView {
                    VStack(spacing: 12) {
                        ForEach(chitFundViewModel.chitFunds) { chitFund in
                            chitFundCard(chitFund) {
                                chitFundForDetail = chitFund
                            }
                        }
                    }
                    .padding()
                }
            }
        }
    }

    private func emptyStateView(icon: String, title: String, message: String) -> some View {
        VStack(spacing: 12) {
            Image(systemName: icon)
                .font(.system(size: 40))
                .foregroundStyle(.secondary)
            Text(title)
                .font(typography.headline)
            Text(message)
                .font(typography.subheadline)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 32)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }

    private func loanCard(_ loan: Loan, onTap: @escaping () -> Void) -> some View {
        let next = loan.nextDueInstallment
        return HStack(spacing: 12) {
            Image(systemName: loan.type == .creditCard ? "creditcard.fill" : "banknote.fill")
                .foregroundStyle(themeColors.accent)
                .frame(width: 44, height: 44)
                .background(themeColors.accent.opacity(0.15))
                .clipShape(Circle())

            VStack(alignment: .leading, spacing: 2) {
                Text(loan.name)
                    .font(typography.subheadline)
                if let lender = loan.lender, !lender.isEmpty {
                    Text(lender)
                        .font(typography.caption)
                        .foregroundStyle(.secondary)
                }
            }

            Spacer()

            VStack(alignment: .trailing, spacing: 2) {
                Text(loan.installmentAmount.currencyFormatted)
                    .font(typography.amount(size: 15))
                statusBadge(next?.status ?? .paid)
            }
        }
        .padding(12)
        .background(themeColors.surface)
        .clipShape(RoundedRectangle(cornerRadius: 14))
        .overlay {
            RoundedRectangle(cornerRadius: 14)
                .strokeBorder(Color.primary.opacity(0.08), lineWidth: 1)
        }
        .contentShape(Rectangle())
        .onTapGesture(perform: onTap)
    }

    private func chitFundCard(_ chitFund: ChitFund, onTap: @escaping () -> Void) -> some View {
        let next = chitFund.nextDueContribution
        return HStack(spacing: 12) {
            Image(systemName: "person.3.fill")
                .foregroundStyle(themeColors.accent)
                .frame(width: 44, height: 44)
                .background(themeColors.accent.opacity(0.15))
                .clipShape(Circle())

            VStack(alignment: .leading, spacing: 2) {
                Text(chitFund.name)
                    .font(typography.subheadline)
                if let organizer = chitFund.organizer, !organizer.isEmpty {
                    Text(organizer)
                        .font(typography.caption)
                        .foregroundStyle(.secondary)
                }
            }

            Spacer()

            VStack(alignment: .trailing, spacing: 2) {
                Text(chitFund.monthlyContribution.currencyFormatted)
                    .font(typography.amount(size: 15))
                if chitFund.hasReceivedPayout {
                    Text("Payout received")
                        .font(typography.caption2)
                        .foregroundStyle(themeColors.income)
                } else {
                    statusBadge(next?.status ?? .paid)
                }
            }
        }
        .padding(12)
        .background(themeColors.surface)
        .clipShape(RoundedRectangle(cornerRadius: 14))
        .overlay {
            RoundedRectangle(cornerRadius: 14)
                .strokeBorder(Color.primary.opacity(0.08), lineWidth: 1)
        }
        .contentShape(Rectangle())
        .onTapGesture(perform: onTap)
    }

    private func statusBadge(_ status: LoanInstallment.Status) -> some View {
        let (label, color): (String, Color) = {
            switch status {
            case .paid: return ("All Paid", themeColors.income)
            case .pending: return ("Upcoming", .secondary)
            case .overdue: return ("Overdue", themeColors.expense)
            }
        }()
        return Text(label)
            .font(typography.caption2)
            .foregroundStyle(color)
    }

    private func statusBadge(_ status: ChitContribution.Status) -> some View {
        let (label, color): (String, Color) = {
            switch status {
            case .paid: return ("All Paid", themeColors.income)
            case .pending: return ("Upcoming", .secondary)
            case .overdue: return ("Overdue", themeColors.expense)
            }
        }()
        return Text(label)
            .font(typography.caption2)
            .foregroundStyle(color)
    }
}

#Preview {
    let container = try! ModelContainer(
        for: Loan.self, ChitFund.self, Expense.self,
        configurations: ModelConfiguration(isStoredInMemoryOnly: true)
    )
    EMIListView(
        repository: DefaultLoanRepository(modelContext: container.mainContext),
        chitFundRepository: DefaultChitFundRepository(modelContext: container.mainContext),
        isActive: true
    )
    .environment(\.expenseRepository, DefaultExpenseRepository(modelContext: container.mainContext, entitlements: StubEntitlementsProvider()))
}
