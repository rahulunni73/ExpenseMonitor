//
//  TransactionListSheet.swift
//  ExpenseMonitor
//

import SwiftUI

struct TransactionListSheet: View {
    let title: String
    let transactions: [Transaction]
    var onChange: (() -> Void)? = nil

    @State private var currentTransactions: [Transaction]
    @State private var transactionForDetail: Transaction?
    @State private var transactionToEdit: Transaction?
    @State private var pendingEditTransaction: Transaction?

    @Environment(\.dismiss) private var dismiss
    @Environment(\.themeColors) private var themeColors
    @Environment(\.typography) private var typography
    @Environment(\.transactionRepository) private var transactionRepository

    init(title: String, transactions: [Transaction], onChange: (() -> Void)? = nil) {
        self.title = title
        self.transactions = transactions
        self.onChange = onChange
        _currentTransactions = State(initialValue: transactions)
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

            if currentTransactions.isEmpty {
                emptyView
            } else {
                ScrollView {
                    VStack(spacing: 8) {
                        ForEach(currentTransactions) { transaction in
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
                        }
                    }
                    .padding()
                }
            }
        }
        .background(themeColors.background)
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
                    transactionRepository.delete(transaction)
                    currentTransactions.removeAll { $0.id == transaction.id }
                    transactionForDetail = nil
                    onChange?()
                }
            )
        }
        .fullScreenCover(item: $transactionToEdit) { transaction in
            AddTransactionView(
                existingTransaction: transaction,
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
        transactions: [
            Transaction(id: "1", title: "Groceries", amount: 450, category: "Food & Dining", categoryIcon: "fork.knife")
        ]
    )
    .environment(\.transactionRepository, PreviewTransactionRepository())
    .environment(\.categoryRepository, PreviewCategoryRepository())
}

private class PreviewTransactionRepository: TransactionRepository {
    func fetchAll() -> [Transaction] { [] }
    func add(_ transaction: Transaction) {}
    func update(_ transaction: Transaction) {}
    func delete(_ transaction: Transaction) {}
}

private class PreviewCategoryRepository: CategoryRepository {
    func fetchAll() -> [Category] { [] }
    func add(_ category: Category) {}
    func update(_ category: Category) {}
    func delete(_ category: Category) {}
}
