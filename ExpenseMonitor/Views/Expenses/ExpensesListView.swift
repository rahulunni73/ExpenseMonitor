//
//  ExpensesListView.swift
//  ExpenseMonitor
//
//  Created by Ospyn on 14/07/26.
//

import SwiftUI
import SwiftData

struct ExpensesListView: View {

    let repository: ExpenseRepository
    @State private var viewModel: ExpensesViewModel
    let isActive: Bool
    @State private var isAddExpensePresented = false
    @State private var expenseForDetail: Expense?
    @State private var expenseToEdit: Expense?
    @State private var pendingEditExpense: Expense?

    @Environment(\.themeColors) private var themeColors
    @Environment(\.typography) private var typography

    init(repository: ExpenseRepository, isActive: Bool) {
        self.repository = repository
        self.isActive = isActive
        _viewModel = State(initialValue: ExpensesViewModel(repository: repository))
    }

    var body: some View {
        @Bindable var viewModel = viewModel

        VStack(spacing: 0) {
            ExpensesHeaderView(
                selectedMonth: $viewModel.selectedMonth,
                selectedDay: $viewModel.selectedDay,
                searchText: $viewModel.searchText,
                typeFilter: $viewModel.typeFilter,
                categoryFilters: $viewModel.categoryFilters,
                expenses: viewModel.expenses,
                totalExpense: viewModel.totalExpense,
                totalIncome: viewModel.totalIncome,
                balance: viewModel.balance,
                onAddExpense: { isAddExpensePresented = true }
            )

            if viewModel.groupedExpenses.isEmpty {
                emptyStateView
            } else {
                List {
                    ForEach(viewModel.groupedExpenses) { section in
                        Section {
                            ForEach(section.expenses) { expense in
                                ExpenseRow(expense: expense) {
                                    expenseForDetail = expense
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
                                viewModel.deleteItems(from: section.expenses, at: offsets)
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
                undoBanner(count: pendingDeletion.expenses.count)
            }
        }
        .onAppear {
            viewModel.loadExpenses()
        }
        .onChange(of: isActive) { _, newValue in
            if newValue {
                viewModel.loadExpenses()
            }
        }
        .onReceive(NotificationCenter.default.publisher(for: .expensesDidChange)) { _ in
            viewModel.loadExpenses()
        }
        .onChange(of: expenseForDetail == nil) { _, isNil in
            if isNil, let pendingEditExpense {
                expenseToEdit = pendingEditExpense
                self.pendingEditExpense = nil
            }
        }
        .fullScreenCover(item: $expenseForDetail) { expense in
            ExpenseDetailView(
                expense: expense,
                onEdit: {
                    pendingEditExpense = expense
                    expenseForDetail = nil
                },
                onDelete: {
                    viewModel.deleteExpense(expense)
                    expenseForDetail = nil
                }
            )
        }
        .fullScreenCover(item: $expenseToEdit) { expense in
            AddExpenseView(
                existingExpense: expense,
                onSave: { viewModel.loadExpenses() }
            )
        }
        .fullScreenCover(isPresented: $isAddExpensePresented) {
            AddExpenseView(onSave: { viewModel.loadExpenses() })
        }
    }

    private var emptyStateView: some View {
        VStack(spacing: 12) {
            Image(systemName: viewModel.expenses.isEmpty ? "tray" : "line.3.horizontal.decrease.circle")
                .font(.system(size: 40))
                .foregroundStyle(.secondary)
            Text(viewModel.expenses.isEmpty ? "No expenses yet" : "No matching expenses")
                .font(typography.headline)
            Text(viewModel.expenses.isEmpty
                 ? "Tap the + button to add your first expense."
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
            Text(count == 1 ? "Expense deleted" : "\(count) expenses deleted")
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
        for: Expense.self, Category.self,
        configurations: ModelConfiguration(isStoredInMemoryOnly: true)
    )
    ExpensesListView(
        repository: DefaultExpenseRepository(
            modelContext: container.mainContext,
            entitlements: StubEntitlementsProvider()
        ),
        isActive: true
    )
    .environment(\.categoryRepository, DefaultCategoryRepository(modelContext: container.mainContext))
}
