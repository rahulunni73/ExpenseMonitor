//
//  SearchFilterView.swift
//  ExpenseMonitor
//

import SwiftUI

struct SearchFilterView: View {
    @Binding var searchText: String
    @Binding var typeFilter: CategoryType?
    @Binding var categoryFilters: Set<String>
    let categoryRepository: CategoryRepository

    @Environment(\.dismiss) private var dismiss
    @Environment(\.themeColors) private var themeColors
    @Environment(\.typography) private var typography

    @State private var pendingSearchText: String = ""
    @State private var pendingType: CategoryType? = nil
    @State private var pendingCategoryFilters: Set<String> = []
    @State private var isCategoryPickerPresented = false

    var body: some View {
        VStack(alignment: .leading) {
            HStack {
                Button {
                    dismiss()
                } label: {
                    Image(systemName: "arrow.left")
                        .frame(width: 44, height: 44)
                }
                Spacer()
                Text("Search")
                    .font(typography.headline)
                Spacer()
            }
            .padding()

            ScrollView {
                VStack(alignment: .leading, spacing: 24) {
                    HStack(spacing: 10) {
                        Image(systemName: "magnifyingglass")
                            .foregroundStyle(.secondary)
                        TextField("Search by title", text: $pendingSearchText)
                    }
                    .padding(12)
                    .background(Color(.systemGray6))
                    .clipShape(RoundedRectangle(cornerRadius: 10))

                    VStack(alignment: .leading, spacing: 12) {
                        Text("Type")
                            .font(typography.subheadlineBold)
                        HStack(spacing: 8) {
                            filterPill("All", isSelected: pendingType == nil) {
                                pendingType = nil
                            }
                            filterPill("Expense", isSelected: pendingType == .expense) {
                                pendingType = .expense
                            }
                            filterPill("Income", isSelected: pendingType == .income) {
                                pendingType = .income
                            }
                        }
                    }

                    VStack(alignment: .leading, spacing: 12) {
                        Text("Category")
                            .font(typography.subheadlineBold)
                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack(spacing: 8) {
                                filterPill("All", isSelected: pendingCategoryFilters.isEmpty) {
                                    pendingCategoryFilters.removeAll()
                                }
                                ForEach(Array(pendingCategoryFilters).sorted(), id: \.self) { categoryName in
                                    filterPill(categoryName, isSelected: true) {
                                        pendingCategoryFilters.remove(categoryName)
                                    }
                                }
                                Button {
                                    isCategoryPickerPresented = true
                                } label: {
                                    Image(systemName: "plus")
                                        .font(.subheadline.weight(.semibold))
                                        .foregroundStyle(.primary)
                                        .frame(width: 44, height: 44)
                                        .background(Color(.systemGray6))
                                        .clipShape(Circle())
                                }
                            }
                        }
                    }
                }
                .padding(.horizontal)
            }

            HStack(spacing: 12) {
                Button {
                    pendingSearchText = ""
                    pendingType = nil
                    pendingCategoryFilters.removeAll()
                } label: {
                    Image(systemName: "arrow.counterclockwise")
                        .frame(maxWidth: .infinity)
                        .frame(height: 52)
                        .background(Color(.systemGray5))
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                }
                .foregroundStyle(.primary)

                Button {
                    searchText = pendingSearchText
                    typeFilter = pendingType
                    categoryFilters = pendingCategoryFilters
                    dismiss()
                } label: {
                    Image(systemName: "checkmark")
                        .foregroundStyle(.white)
                        .frame(maxWidth: .infinity)
                        .frame(height: 52)
                        .background(themeColors.accent)
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                }
            }
            .padding()
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
        .onAppear {
            pendingSearchText = searchText
            pendingType = typeFilter
            pendingCategoryFilters = categoryFilters
        }
        .fullScreenCover(isPresented: $isCategoryPickerPresented) {
            CategoryFilterPickerView(categoryRepository: categoryRepository, selectedCategories: $pendingCategoryFilters)
        }
    }

    private func filterPill(_ label: String, isSelected: Bool, action: @escaping () -> Void) -> some View {
        Text(label)
            .font(typography.subheadline(emphasized: isSelected))
            .foregroundStyle(isSelected ? .white : .primary)
            .padding(.horizontal, 16)
            .padding(.vertical, 8)
            .background(isSelected ? themeColors.accent : Color(.systemGray6))
            .clipShape(Capsule())
            .contentShape(Rectangle())
            .onTapGesture(perform: action)
    }
}

#Preview {
    SearchFilterView(
        searchText: .constant(""),
        typeFilter: .constant(nil),
        categoryFilters: .constant([]),
        categoryRepository: PreviewCategoryRepository()
    )
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
