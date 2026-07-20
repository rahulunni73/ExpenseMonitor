//
//  AddTransactionView.swift
//  ExpenseMonitor
//

import SwiftUI

struct AddTransactionView: View {
    var existingTransaction: Transaction? = nil
    var onSave: (() -> Void)? = nil

    @Environment(\.dismiss) private var dismiss
    @Environment(\.themeColors) private var themeColors
    @Environment(\.typography) private var typography
    @Environment(\.transactionRepository) private var repository
    @Environment(\.categoryRepository) private var categoryRepository

    @State private var title = ""
    @State private var amountText = "0"
    @State private var categories: [Category] = []
    @State private var selectedType: CategoryType = .expense
    @State private var selectedCategory: Category?
    @State private var date = Date()
    @State private var isDatePickerPresented = false
    @State private var isCreateCategoryPresented = false

    private let categoryGridColumns = Array(repeating: GridItem(.flexible()), count: 4)
    private let keypadColumns = Array(repeating: GridItem(.flexible()), count: 4)
    private let keypadKeys = [
        "7", "8", "9", "today",
        "4", "5", "6", "⌫",
        "1", "2", "3", "",
        ".", "0", "", "check"
    ]

    private var filteredCategories: [Category] {
        categories.filter { $0.type == selectedType }
    }

    private var isValid: Bool {
        guard let amount = Double(amountText) else { return false }
        return !title.isEmpty && amount > 0 && selectedCategory != nil
    }

    private var dateLabel: String {
        Calendar.current.isDateInToday(date) ? "Today" : date.formatted(date: .abbreviated, time: .omitted)
    }

    var body: some View {
        VStack(spacing: 0) {
            HStack {
                Button("Cancel") {
                    dismiss()
                }
                Spacer()
                Text(existingTransaction == nil ? "Add" : "Edit")
                    .font(typography.headline)
                Spacer()
                Image(systemName: "dollarsign.arrow.circlepath")
                    .foregroundStyle(.secondary)
            }
            .padding()

            Picker("", selection: $selectedType) {
                Text("Expense").tag(CategoryType.expense)
                Text("Income").tag(CategoryType.income)
            }
            .pickerStyle(.segmented)
            .padding(.horizontal)
            .padding(.bottom, 12)

            ScrollView {
                LazyVGrid(columns: categoryGridColumns, spacing: 16) {
                    ForEach(filteredCategories) { category in
                        categoryChip(category)
                    }
                    newCategoryTile
                }
                .padding()
            }

            if selectedCategory != nil {
                transactionFormPanel
                    .padding(.horizontal)
                    .padding(.bottom, 12)
            }
        }
        .background(themeColors.background)
        .onAppear {
            categories = categoryRepository.fetchAll()
            if let existingTransaction {
                title = existingTransaction.title
                amountText = formattedAmount(existingTransaction.amount)
                selectedType = existingTransaction.type
                date = existingTransaction.date
                selectedCategory = categories.first { $0.name == existingTransaction.category }
            }
        }
        .onChange(of: selectedType) { _, _ in
            if selectedCategory?.type != selectedType {
                selectedCategory = nil
            }
        }
        .fullScreenCover(isPresented: $isCreateCategoryPresented) {
            CreateCategoryView(initialType: selectedType) { newCategory in
                categories.append(newCategory)
                selectedCategory = newCategory
            }
        }
        .sheet(isPresented: $isDatePickerPresented) {
            DatePicker("Date", selection: $date, displayedComponents: .date)
                .datePickerStyle(.graphical)
                .padding()
                .presentationDetents([.medium])
        }
    }

    private var transactionFormPanel: some View {
        VStack(spacing: 12) {
            HStack {
                Spacer()
                HStack(alignment: .firstTextBaseline, spacing: 2) {
                    Text("₹")
                        .font(typography.title2Bold)
                        .foregroundStyle(themeColors.accent)
                    Text(amountText)
                        .font(typography.amount(size: 40))
                }
                Spacer()
            }

            TextField("Note", text: $title)
                .padding(12)
                .background(themeColors.surfaceSecondary)
                .clipShape(RoundedRectangle(cornerRadius: 10))

            LazyVGrid(columns: keypadColumns, spacing: 12) {
                ForEach(Array(keypadKeys.enumerated()), id: \.offset) { _, key in
                    keypadButton(key)
                }
            }
        }
        .padding()
        .background(themeColors.surface)
        .clipShape(RoundedRectangle(cornerRadius: 16))
        .overlay {
            RoundedRectangle(cornerRadius: 16)
                .strokeBorder(Color.primary.opacity(0.08), lineWidth: 1)
        }
    }

    @ViewBuilder
    private func keypadButton(_ key: String) -> some View {
        switch key {
        case "":
            Color.clear
                .frame(height: 48)
        case "today":
            Button {
                isDatePickerPresented = true
            } label: {
                VStack(spacing: 2) {
                    Image(systemName: "calendar")
                    Text(dateLabel)
                        .font(typography.caption2)
                }
                .frame(maxWidth: .infinity)
                .frame(height: 48)
                .background(themeColors.surfaceSecondary)
                .clipShape(RoundedRectangle(cornerRadius: 10))
            }
            .buttonStyle(.plain)
        case "check":
            Button {
                save()
            } label: {
                Image(systemName: "checkmark")
                    .font(.title3.weight(.bold))
                    .foregroundStyle(.white)
                    .frame(maxWidth: .infinity)
                    .frame(height: 48)
                    .background(isValid ? Color(.systemGreen) : Color(.systemGray4))
                    .clipShape(RoundedRectangle(cornerRadius: 10))
            }
            .buttonStyle(.plain)
            .disabled(!isValid)
        default:
            Button {
                keypadTapped(key)
            } label: {
                Text(key)
                    .font(typography.font(weight: .medium, size: 22, relativeTo: .title2))
                    .frame(maxWidth: .infinity)
                    .frame(height: 48)
                    .background(themeColors.surfaceSecondary)
                    .clipShape(RoundedRectangle(cornerRadius: 10))
            }
            .buttonStyle(.plain)
        }
    }

    private func formattedAmount(_ amount: Double) -> String {
        amount.truncatingRemainder(dividingBy: 1) == 0
            ? String(Int(amount))
            : String(amount)
    }

    private func keypadTapped(_ key: String) {
        switch key {
        case "⌫":
            if amountText.count > 1 {
                amountText.removeLast()
            } else {
                amountText = "0"
            }
        case ".":
            if !amountText.contains(".") {
                amountText += "."
            }
        default:
            if let dotIndex = amountText.firstIndex(of: ".") {
                let decimalsTyped = amountText.distance(from: amountText.index(after: dotIndex), to: amountText.endIndex)
                if decimalsTyped >= 2 { return }
            }
            amountText = (amountText == "0") ? key : amountText + key
        }
    }

    private func categoryChip(_ category: Category) -> some View {
        let isSelected = selectedCategory?.id == category.id
        return VStack(spacing: 6) {
            Image(systemName: category.icon)
                .font(.title3)
                .foregroundStyle(isSelected ? .white : themeColors.accent)
                .frame(width: 56, height: 56)
                .background(isSelected ? themeColors.accent : themeColors.accent.opacity(0.15))
                .clipShape(Circle())
            Text(category.name)
                .font(typography.caption)
                .foregroundStyle(.primary)
                .multilineTextAlignment(.center)
        }
        .contentShape(Rectangle())
        .onTapGesture {
            withAnimation {
                selectedCategory = category
            }
        }
    }

    private var newCategoryTile: some View {
        VStack(spacing: 6) {
            Image(systemName: "plus")
                .foregroundStyle(.secondary)
                .frame(width: 56, height: 56)
                .overlay(
                    Circle()
                        .strokeBorder(style: StrokeStyle(lineWidth: 1.5, dash: [4]))
                        .foregroundStyle(Color(.systemGray3))
                )
            Text("New")
                .font(typography.caption)
                .foregroundStyle(.secondary)
        }
        .contentShape(Rectangle())
        .onTapGesture {
            isCreateCategoryPresented = true
        }
    }

    private func save() {
        guard let amount = Double(amountText), let selectedCategory else { return }

        if let existingTransaction {
            existingTransaction.title = title
            existingTransaction.amount = amount
            existingTransaction.category = selectedCategory.name
            existingTransaction.type = selectedCategory.type
            existingTransaction.date = date
            existingTransaction.categoryIcon = selectedCategory.icon
            existingTransaction.lastModified = Date()
            repository.update(existingTransaction)
        } else {
            let newTransaction = Transaction(
                id: UUID().uuidString,
                title: title,
                amount: amount,
                category: selectedCategory.name,
                type: selectedCategory.type,
                date: date,
                note: nil,
                categoryIcon: selectedCategory.icon
            )
            repository.add(newTransaction)
        }

        onSave?()
        dismiss()
    }
}

#Preview {
    AddTransactionView()
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
    func fetchAll() -> [Category] {
        [
            Category(id: "cat-food", name: "Food", icon: "fork.knife", type: .expense, isSystemDefined: true),
            Category(id: "cat-transport", name: "Transport", icon: "car.fill", type: .expense, isSystemDefined: true)
        ]
    }
    func add(_ category: Category) {}
    func update(_ category: Category) {}
    func delete(_ category: Category) {}
}
