//
//  CreateCategoryView.swift
//  ExpenseMonitor
//

import SwiftUI

struct CreateCategoryView: View {
    let categoryRepository: CategoryRepository
    var onCreate: ((Category) -> Void)? = nil

    @Environment(\.dismiss) private var dismiss

    @State private var name = ""
    @State private var selectedIcon = "tag.fill"
    @State private var selectedColorName = "systemBlue"
    @State private var type: CategoryType

    init(categoryRepository: CategoryRepository, initialType: CategoryType = .expense, onCreate: ((Category) -> Void)? = nil) {
        self.categoryRepository = categoryRepository
        self.onCreate = onCreate
        _type = State(initialValue: initialType)
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

    private let colorOptions = [
        "systemBlue", "systemGreen", "systemRed", "systemOrange",
        "systemPurple", "systemTeal", "systemPink", "systemIndigo"
    ]

    private let gridColumns = Array(repeating: GridItem(.flexible()), count: 5)

    var body: some View {
        VStack(spacing: 0) {
            HStack {
                Button("Cancel") {
                    dismiss()
                }
                Spacer()
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
                    .foregroundStyle(Category.color(for: selectedColorName))
                    .frame(width: 72, height: 72)
                    .background(Category.color(for: selectedColorName).opacity(0.15))
                    .clipShape(Circle())
                Text(name.isEmpty ? "New Category" : name)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }
            .padding(.bottom, 12)

            ScrollView {
                VStack(spacing: 20) {
                    LazyVGrid(columns: gridColumns, spacing: 16) {
                        ForEach(iconOptions, id: \.self) { icon in
                            iconSwatch(icon)
                        }
                    }

                    LazyVGrid(columns: gridColumns, spacing: 16) {
                        ForEach(colorOptions, id: \.self) { colorName in
                            colorSwatch(colorName)
                        }
                    }
                }
                .padding()
            }

            HStack(spacing: 12) {
                TextField("Category name", text: $name)
                    .padding(12)
                    .background(Color(.systemGray6))
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
        .background(Color(.systemGroupedBackground))
    }

    private func iconSwatch(_ icon: String) -> some View {
        let isSelected = icon == selectedIcon
        return Image(systemName: icon)
            .font(.title3)
            .foregroundStyle(isSelected ? .white : .primary)
            .frame(width: 44, height: 44)
            .background(isSelected ? Color(.systemBlue) : Color(.systemGray5))
            .clipShape(Circle())
            .contentShape(Rectangle())
            .onTapGesture {
                selectedIcon = icon
            }
    }

    private func colorSwatch(_ colorName: String) -> some View {
        let isSelected = colorName == selectedColorName
        return Circle()
            .fill(Category.color(for: colorName))
            .frame(width: 36, height: 36)
            .overlay(
                Circle().stroke(.primary, lineWidth: isSelected ? 2 : 0)
            )
            .contentShape(Rectangle())
            .onTapGesture {
                selectedColorName = colorName
            }
    }

    private func save() {
        guard !name.isEmpty else { return }
        let newCategory = Category(
            id: UUID().uuidString,
            name: name,
            icon: selectedIcon,
            colorName: selectedColorName,
            type: type,
            isSystemDefined: false
        )
        categoryRepository.add(newCategory)
        onCreate?(newCategory)
        dismiss()
    }
}

#Preview {
    CreateCategoryView(categoryRepository: PreviewCategoryRepository())
}

private class PreviewCategoryRepository: CategoryRepository {
    func fetchAll() -> [Category] { [] }
    func add(_ category: Category) {}
}
