//
//  CategoryFilterPickerView.swift
//  ExpenseMonitor
//

import SwiftUI

struct CategoryFilterPickerView: View {
    let categoryRepository: CategoryRepository
    @Binding var selectedCategories: Set<String>

    @Environment(\.dismiss) private var dismiss

    @State private var categories: [Category] = []
    @State private var selectedType: CategoryType = .expense
    @State private var pendingSelection: Set<String> = []

    private let columns = Array(repeating: GridItem(.flexible()), count: 4)

    private var filteredCategories: [Category] {
        categories.filter { $0.type == selectedType }
    }

    var body: some View {
        VStack(spacing: 0) {
            HStack {
                Button {
                    dismiss()
                } label: {
                    Image(systemName: "arrow.left")
                }
                Spacer()
                Text("Select Categories")
                    .font(.headline)
                Spacer()
                Button {
                    selectedCategories = pendingSelection
                    dismiss()
                } label: {
                    Image(systemName: "checkmark")
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

            ScrollView {
                LazyVGrid(columns: columns, spacing: 16) {
                    ForEach(filteredCategories) { category in
                        categoryChip(category)
                    }
                }
                .padding()
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
        .onAppear {
            categories = categoryRepository.fetchAll()
            pendingSelection = selectedCategories
        }
    }

    private func categoryChip(_ category: Category) -> some View {
        let isSelected = pendingSelection.contains(category.name)
        return VStack(spacing: 6) {
            Image(systemName: category.icon)
                .font(.title3)
                .foregroundStyle(isSelected ? .white : category.swiftUIColor)
                .frame(width: 56, height: 56)
                .background(isSelected ? category.swiftUIColor : category.swiftUIColor.opacity(0.15))
                .clipShape(Circle())
            Text(category.name)
                .font(.caption)
                .foregroundStyle(.primary)
                .multilineTextAlignment(.center)
        }
        .contentShape(Rectangle())
        .onTapGesture {
            if pendingSelection.contains(category.name) {
                pendingSelection.remove(category.name)
            } else {
                pendingSelection.insert(category.name)
            }
        }
    }
}

#Preview {
    CategoryFilterPickerView(categoryRepository: PreviewCategoryRepository(), selectedCategories: .constant([]))
}

private class PreviewCategoryRepository: CategoryRepository {
    func fetchAll() -> [Category] {
        [
            Category(id: "cat-food", name: "Food", icon: "fork.knife", colorName: "systemGreen", type: .expense, isSystemDefined: true),
            Category(id: "cat-transport", name: "Transport", icon: "car.fill", colorName: "systemBlue", type: .expense, isSystemDefined: true)
        ]
    }
    func add(_ category: Category) {}
}
