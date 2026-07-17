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
    let categoryRepository: CategoryRepository
    @State private var viewModel: ExpensesViewModel
    let isActive: Bool
    @State private var expenseToEdit: Expense?

    init(repository: ExpenseRepository, categoryRepository: CategoryRepository,isActive: Bool) {
        self.repository = repository
        self.categoryRepository = categoryRepository
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
                categoryRepository: categoryRepository,
                totalExpense: viewModel.totalExpense,
                totalIncome: viewModel.totalIncome,
                balance: viewModel.balance
            )

            // TEMPORARY — dev-only seed button, remove this whole Button once no longer needed.
            Button("Seed Sample Data (Debug)") {
                viewModel.seedSampleData()
            }
            .font(.caption)
            .padding(.vertical, 4)

            List {
                ForEach(viewModel.groupedExpenses) { section in
                    Section(header: Text(section.title)) {
                        ForEach(section.expenses) { expense in
                            ExpenseRow(expense: expense) {
                                expenseToEdit = expense
                            }
                            .listRowInsets(EdgeInsets(top: 10, leading: 16, bottom: 10, trailing: 16))
                        }
                        .onDelete { offsets in
                            viewModel.deleteItems(from: section.expenses, at: offsets)
                        }
                    }
                }
            }
            .listStyle(.plain)
        }
        .onAppear {
            viewModel.loadExpenses()
        }
        .onChange(of: isActive) { _, newValue in
            if newValue {
                viewModel.loadExpenses()
            }
        }
        .fullScreenCover(item: $expenseToEdit) { expense in
            AddExpenseView(
                repository: repository,
                categoryRepository: categoryRepository,
                existingExpense: expense,
                onSave: { viewModel.loadExpenses() }
            )
        }
    }
}

#Preview {
    let container = try! ModelContainer(
        for: Expense.self,
        configurations: ModelConfiguration(isStoredInMemoryOnly: true)
    )
    ExpensesListView(
        repository: DefaultExpenseRepository(
            modelContext: container.mainContext,
            entitlements: StubEntitlementsProvider()
        ),
        categoryRepository: DefaultCategoryRepository(modelContext: container.mainContext), isActive: true
    )
}
