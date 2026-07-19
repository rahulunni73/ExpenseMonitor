//
//  CreateCategoryView.swift
//  ExpenseMonitor
//

import SwiftUI

struct CreateCategoryView: View {
    let categoryRepository: CategoryRepository
    var expenseRepository: ExpenseRepository? = nil
    var existingCategory: Category? = nil
    var onCreate: ((Category) -> Void)? = nil

    @Environment(\.dismiss) private var dismiss
    @Environment(\.themeColors) private var themeColors
    @Environment(\.typography) private var typography

    @State private var name: String
    @State private var selectedIcon: String
    @State private var type: CategoryType

    init(categoryRepository: CategoryRepository, expenseRepository: ExpenseRepository? = nil, existingCategory: Category? = nil, initialType: CategoryType = .expense, onCreate: ((Category) -> Void)? = nil) {
        self.categoryRepository = categoryRepository
        self.expenseRepository = expenseRepository
        self.existingCategory = existingCategory
        self.onCreate = onCreate
        _type = State(initialValue: existingCategory?.type ?? initialType)
        _name = State(initialValue: existingCategory?.name ?? "")
        _selectedIcon = State(initialValue: existingCategory?.icon ?? "tag.fill")
    }

    private let iconOptions = [
        // Food & Dining
        "fork.knife", "cup.and.saucer.fill", "takeoutbag.and.cup.and.straw.fill", "birthday.cake.fill",
        // Shopping
        "bag.fill", "cart.fill", "basket.fill", "tshirt.fill",
        // Home & Utilities
        "house.fill", "lightbulb.fill", "drop.fill", "wifi", "flame.fill",
        // Transport
        "car.fill", "fuelpump.fill", "bus.fill", "tram.fill", "bicycle", "airplane",
        // Entertainment
        "film.fill", "gamecontroller.fill", "music.note", "tv.fill", "theatermasks.fill", "ticket.fill",
        // Health & Fitness
        "heart.fill", "cross.case.fill", "pills.fill", "stethoscope", "dumbbell.fill", "figure.run",
        // Finance
        "creditcard.fill", "banknote.fill", "building.columns.fill", "chart.line.uptrend.xyaxis",
        "chart.pie.fill", "wallet.pass.fill", "dollarsign.circle.fill", "percent",
        // Education & Work
        "book.fill", "graduationcap.fill", "briefcase.fill", "laptopcomputer", "pencil", "printer.fill",
        // Travel
        "suitcase.fill", "beach.umbrella.fill", "globe", "map.fill",
        // Personal & Misc
        "gift.fill", "pawprint.fill", "leaf.fill", "wrench.fill", "hammer.fill",
        "paintbrush.fill", "bell.fill", "tag.fill", "envelope.fill", "calendar"
    ]

    private let gridColumns = Array(repeating: GridItem(.flexible()), count: 5)

    var body: some View {
        VStack(spacing: 0) {
            HStack {
                Button("Cancel") {
                    dismiss()
                }
                Spacer()
                Text(existingCategory == nil ? "New Category" : "Edit Category")
                    .font(typography.headline)
                Spacer()
                Color.clear
                    .frame(width: 44, height: 44)
            }
            .padding()

            Picker("", selection: $type) {
                Text("Expense").tag(CategoryType.expense)
                Text("Income").tag(CategoryType.income)
            }
            .pickerStyle(.segmented)
            .padding(.horizontal)
            .padding(.bottom, 12)

            VStack(spacing: 8) {
                Image(systemName: selectedIcon)
                    .font(.title)
                    .foregroundStyle(themeColors.accent)
                    .frame(width: 72, height: 72)
                    .background(themeColors.accent.opacity(0.15))
                    .clipShape(Circle())
                Text(name.isEmpty ? "New Category" : name)
                    .font(typography.subheadline)
                    .foregroundStyle(.secondary)
            }
            .padding(.bottom, 12)

            ScrollView {
                LazyVGrid(columns: gridColumns, spacing: 16) {
                    ForEach(iconOptions, id: \.self) { icon in
                        iconSwatch(icon)
                    }
                }
                .padding()
            }

            HStack(spacing: 12) {
                TextField("Category name", text: $name)
                    .padding(12)
                    .background(themeColors.surfaceSecondary)
                    .clipShape(RoundedRectangle(cornerRadius: 10))

                Button {
                    save()
                } label: {
                    Image(systemName: "checkmark")
                        .foregroundStyle(.white)
                        .frame(width: 48, height: 48)
                        .background(name.isEmpty ? Color(.systemGray4) : Color(.systemGreen))
                        .clipShape(RoundedRectangle(cornerRadius: 10))
                }
                .disabled(name.isEmpty)
            }
            .padding()
        }
        .background(themeColors.background)
    }

    private func iconSwatch(_ icon: String) -> some View {
        let isSelected = icon == selectedIcon
        return Image(systemName: icon)
            .font(.title3)
            .foregroundStyle(isSelected ? .white : .primary)
            .frame(width: 44, height: 44)
            .background(isSelected ? themeColors.accent : themeColors.surfaceSecondary)
            .clipShape(Circle())
            .contentShape(Rectangle())
            .onTapGesture {
                selectedIcon = icon
            }
    }

    private func save() {
        guard !name.isEmpty else { return }
        if let existingCategory {
            let oldName = existingCategory.name
            existingCategory.name = name
            existingCategory.icon = selectedIcon
            existingCategory.type = type
            categoryRepository.update(existingCategory)

            if let expenseRepository {
                for expense in expenseRepository.fetchAll() where expense.category == oldName {
                    expense.category = name
                    expense.categoryIcon = selectedIcon
                    expenseRepository.update(expense)
                }
            }
            onCreate?(existingCategory)
        } else {
            let newCategory = Category(
                id: UUID().uuidString,
                name: name,
                icon: selectedIcon,
                type: type,
                isSystemDefined: false
            )
            categoryRepository.add(newCategory)
            onCreate?(newCategory)
        }
        dismiss()
    }
}

#Preview {
    CreateCategoryView(categoryRepository: PreviewCategoryRepository())
}

private class PreviewCategoryRepository: CategoryRepository {
    func fetchAll() -> [Category] { [] }
    func add(_ category: Category) {}
    func update(_ category: Category) {}
    func delete(_ category: Category) {}
}
