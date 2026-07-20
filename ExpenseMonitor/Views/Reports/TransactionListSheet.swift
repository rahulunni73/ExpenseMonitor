//
//  TransactionListSheet.swift
//  ExpenseMonitor
//

import SwiftUI

struct TransactionListSheet: View {
    let title: String
    let expenses: [Expense]
    var onChange: (() -> Void)? = nil

    @State private var currentExpenses: [Expense]
    @State private var expenseForDetail: Expense?
    @State private var expenseToEdit: Expense?
    @State private var pendingEditExpense: Expense?

    @Environment(\.dismiss) private var dismiss
    @Environment(\.themeColors) private var themeColors
    @Environment(\.typography) private var typography
    @Environment(\.expenseRepository) private var expenseRepository

    init(title: String, expenses: [Expense], onChange: (() -> Void)? = nil) {
        self.title = title
        self.expenses = expenses
        self.onChange = onChange
        _currentExpenses = State(initialValue: expenses)
    }

    var body: some View {
        VStack(spacing: 0) {
            HStack {
                Button("Done") {
                    dismiss()
                }
                Spacer()
                Text(title)
                    .font(typography.headline)
                Spacer()
                Color.clear
                    .frame(width: 44, height: 44)
            }
            .padding()

            if currentExpenses.isEmpty {
                emptyView
            } else {
                ScrollView {
                    VStack(spacing: 8) {
                        ForEach(currentExpenses) { expense in
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
                        }
                    }
                    .padding()
                }
            }
        }
        .background(themeColors.background)
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
                    expenseRepository.delete(expense)
                    currentExpenses.removeAll { $0.id == expense.id }
                    expenseForDetail = nil
                    onChange?()
                }
            )
        }
        .fullScreenCover(item: $expenseToEdit) { expense in
            AddExpenseView(
                existingExpense: expense,
                onSave: { onChange?() }
            )
        }
    }

    private var emptyView: some View {
        VStack(spacing: 12) {
            Image(systemName: "tray")
                .font(.system(size: 36))
                .foregroundStyle(.secondary)
            Text("No transactions")
                .font(typography.headline)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}

#Preview {
    TransactionListSheet(
        title: "Food & Dining",
        expenses: [
            Expense(id: "1", title: "Groceries", amount: 450, category: "Food & Dining", categoryIcon: "fork.knife")
        ]
    )
    .environment(\.expenseRepository, PreviewExpenseRepository())
    .environment(\.categoryRepository, PreviewCategoryRepository())
}

private class PreviewExpenseRepository: ExpenseRepository {
    func fetchAll() -> [Expense] { [] }
    func add(_ expense: Expense) {}
    func update(_ expense: Expense) {}
    func delete(_ expense: Expense) {}
}

private class PreviewCategoryRepository: CategoryRepository {
    func fetchAll() -> [Category] { [] }
    func add(_ category: Category) {}
    func update(_ category: Category) {}
    func delete(_ category: Category) {}
}
