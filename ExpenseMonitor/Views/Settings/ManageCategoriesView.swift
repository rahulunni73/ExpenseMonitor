//
//  ManageCategoriesView.swift
//  ExpenseMonitor
//

import SwiftUI
import SwiftData

struct ManageCategoriesView: View {
    let categoryRepository: CategoryRepository
    let expenseRepository: ExpenseRepository

    @Environment(\.dismiss) private var dismiss
    @Environment(\.themeColors) private var themeColors
    @Environment(\.typography) private var typography

    @State private var categories: [Category] = []
    @State private var selectedType: CategoryType = .expense
    @State private var isCreatePresented = false
    @State private var categoryForEdit: Category?
    @State private var isDeleteConfirmationPresented = false
    @State private var categoryPendingDelete: Category?

    private var filteredCategories: [Category] {
        categories.filter { $0.type == selectedType }.sorted { $0.name < $1.name }
    }

    var body: some View {
        VStack(spacing: 0) {
            HStack {
                Button("Done") {
                    dismiss()
                }
                Spacer()
                Text("Manage Categories")
                    .font(typography.headline)
                Spacer()
                Button {
                    isCreatePresented = true
                } label: {
                    Image(systemName: "plus")
                        .font(.system(size: 18, weight: .semibold))
                        .frame(width: 44, height: 44)
                }
            }
            .padding()

            Picker("", selection: $selectedType) {
                Text("Expense").tag(CategoryType.expense)
                Text("Income").tag(CategoryType.income)
            }
            .pickerStyle(.segmented)
            .padding(.horizontal)
            .padding(.bottom, 12)

            List {
                ForEach(filteredCategories) { category in
                    row(for: category)
                }
            }
            .listStyle(.insetGrouped)
        }
        .background(themeColors.background)
        .onAppear {
            reload()
        }
        .sheet(isPresented: $isCreatePresented) {
            CreateCategoryView(categoryRepository: categoryRepository, initialType: selectedType) { _ in
                reload()
            }
        }
        .sheet(item: $categoryForEdit) { category in
            CreateCategoryView(categoryRepository: categoryRepository, expenseRepository: expenseRepository, existingCategory: category) { _ in
                reload()
            }
        }
        .confirmationDialog(
            "Delete this category?",
            isPresented: $isDeleteConfirmationPresented,
            titleVisibility: .visible,
            presenting: categoryPendingDelete
        ) { category in
            Button("Delete", role: .destructive) {
                categoryRepository.delete(category)
                reload()
            }
        } message: { category in
            Text("Expenses already using \"\(category.name)\" will keep their existing name and icon, but you won't be able to pick it for new ones.")
        }
    }

    private func reload() {
        categories = categoryRepository.fetchAll()
    }

    private func row(for category: Category) -> some View {
        HStack {
            Image(systemName: category.icon)
                .foregroundStyle(.white)
                .frame(width: 28, height: 28)
                .background(themeColors.accent)
                .clipShape(RoundedRectangle(cornerRadius: 7))
            Text(category.name)
                .font(typography.body)
            Spacer()
            if category.isSystemDefined {
                Image(systemName: "lock.fill")
                    .font(.system(size: 13))
                    .foregroundStyle(.secondary)
            } else {
                Image(systemName: "chevron.right")
                    .font(.system(size: 13, weight: .semibold))
                    .foregroundStyle(.secondary)
            }
        }
        .padding(.vertical, 4)
        .contentShape(Rectangle())
        .onTapGesture {
            guard !category.isSystemDefined else { return }
            categoryForEdit = category
        }
        .swipeActions(edge: .trailing) {
            if !category.isSystemDefined {
                Button(role: .destructive) {
                    categoryPendingDelete = category
                    isDeleteConfirmationPresented = true
                } label: {
                    Label("Delete", systemImage: "trash")
                }
            }
        }
    }
}

#Preview {
    let container = try! ModelContainer(
        for: Expense.self, Category.self, Loan.self, ChitFund.self,
        configurations: ModelConfiguration(isStoredInMemoryOnly: true)
    )
    ManageCategoriesView(
        categoryRepository: DefaultCategoryRepository(modelContext: container.mainContext),
        expenseRepository: DefaultExpenseRepository(modelContext: container.mainContext, entitlements: StubEntitlementsProvider())
    )
}
