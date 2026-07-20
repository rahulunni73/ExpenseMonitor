//
//  TransactionsListView.swift
//  ExpenseMonitor
//
//  Created by Ospyn on 14/07/26.
//

import SwiftUI
import SwiftData

struct TransactionsListView: View {

    let repository: TransactionRepository
    @State private var viewModel: TransactionsViewModel
    let isActive: Bool
    @State private var isAddTransactionPresented = false
    @State private var transactionForDetail: Transaction?
    @State private var transactionToEdit: Transaction?
    @State private var pendingEditTransaction: Transaction?

    @Environment(\.themeColors) private var themeColors
    @Environment(\.typography) private var typography

    init(repository: TransactionRepository, isActive: Bool) {
        self.repository = repository
        self.isActive = isActive
        _viewModel = State(initialValue: TransactionsViewModel(repository: repository))
    }

    var body: some View {
        @Bindable var viewModel = viewModel

        VStack(spacing: 0) {
            TransactionsHeaderView(
                selectedMonth: $viewModel.selectedMonth,
                selectedDay: $viewModel.selectedDay,
                searchText: $viewModel.searchText,
                typeFilter: $viewModel.typeFilter,
                categoryFilters: $viewModel.categoryFilters,
                transactions: viewModel.transactions,
                totalExpense: viewModel.totalExpense,
                totalIncome: viewModel.totalIncome,
                balance: viewModel.balance,
                onAddTransaction: { isAddTransactionPresented = true }
            )

            if viewModel.groupedTransactions.isEmpty {
                emptyStateView
            } else {
                List {
                    ForEach(viewModel.groupedTransactions) { section in
                        Section {
                            ForEach(section.transactions) { transaction in
                                TransactionRow(transaction: transaction) {
                                    transactionForDetail = transaction
                                }
                                .padding(12)
                                .background(themeColors.surface)
                                .clipShape(RoundedRectangle(cornerRadius: 14))
                                .overlay {
                                    RoundedRectangle(cornerRadius: 14)
                                        .strokeBorder(Color.primary.opacity(0.08), lineWidth: 1)
                                }
                                .listRowInsets(EdgeInsets(top: 4, leading: 16, bottom: 4, trailing: 16))
                                .listRowBackground(Color.clear)
                                .listRowSeparator(.hidden)
                            }
                            .onDelete { offsets in
                                viewModel.deleteItems(from: section.transactions, at: offsets)
                            }
                        } header: {
                            Text(section.title)
                                .font(typography.subheadlineBold)
                                .foregroundStyle(.primary)
                        }
                        .listSectionSeparator(.hidden)
                    }
                }
                .listStyle(.plain)
                .scrollContentBackground(.hidden)
            }
        }
        .background(themeColors.backgroundGradient)
        .overlay(alignment: .bottom) {
            if let pendingDeletion = viewModel.pendingDeletion {
                undoBanner(count: pendingDeletion.transactions.count)
            }
        }
        .onAppear {
            viewModel.loadTransactions()
        }
        .onChange(of: isActive) { _, newValue in
            if newValue {
                viewModel.loadTransactions()
            }
        }
        .onReceive(NotificationCenter.default.publisher(for: .transactionsDidChange)) { _ in
            viewModel.loadTransactions()
        }
        .onChange(of: transactionForDetail == nil) { _, isNil in
            if isNil, let pendingEditTransaction {
                transactionToEdit = pendingEditTransaction
                self.pendingEditTransaction = nil
            }
        }
        .fullScreenCover(item: $transactionForDetail) { transaction in
            TransactionDetailView(
                transaction: transaction,
                onEdit: {
                    pendingEditTransaction = transaction
                    transactionForDetail = nil
                },
                onDelete: {
                    viewModel.deleteTransaction(transaction)
                    transactionForDetail = nil
                }
            )
        }
        .fullScreenCover(item: $transactionToEdit) { transaction in
            AddTransactionView(
                existingTransaction: transaction,
                onSave: { viewModel.loadTransactions() }
            )
        }
        .fullScreenCover(isPresented: $isAddTransactionPresented) {
            AddTransactionView(onSave: { viewModel.loadTransactions() })
        }
    }

    private var emptyStateView: some View {
        VStack(spacing: 12) {
            Image(systemName: viewModel.transactions.isEmpty ? "tray" : "line.3.horizontal.decrease.circle")
                .font(.system(size: 40))
                .foregroundStyle(.secondary)
            Text(viewModel.transactions.isEmpty ? "No transactions yet" : "No matching transactions")
                .font(typography.headline)
            Text(viewModel.transactions.isEmpty
                 ? "Tap the + button to add your first transaction."
                 : "Try adjusting your filters or search.")
                .font(typography.subheadline)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 32)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }

    private func undoBanner(count: Int) -> some View {
        HStack {
            Text(count == 1 ? "Transaction deleted" : "\(count) transactions deleted")
                .font(typography.subheadline)
                .foregroundStyle(.white)
            Spacer()
            Button("Undo") {
                viewModel.undoDelete()
            }
            .font(typography.subheadlineBold)
            .foregroundStyle(Color(.systemYellow))
        }
        .padding()
        .background(Color.black.opacity(0.85))
        .clipShape(RoundedRectangle(cornerRadius: 12))
        .padding(.horizontal)
        .padding(.bottom, 8)
        .transition(.move(edge: .bottom).combined(with: .opacity))
    }
}

#Preview {
    let container = try! ModelContainer(
        for: Transaction.self, Category.self,
        configurations: ModelConfiguration(isStoredInMemoryOnly: true)
    )
    TransactionsListView(
        repository: DefaultTransactionRepository(
            modelContext: container.mainContext,
            entitlements: StubEntitlementsProvider()
        ),
        isActive: true
    )
    .environment(\.categoryRepository, DefaultCategoryRepository(modelContext: container.mainContext))
}
