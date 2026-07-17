//
//  ExpensesHeaderView.swift
//  ExpenseMonitor
//

import SwiftUI

struct ExpensesHeaderView: View {
    @Binding var selectedMonth: Date
    @Binding var selectedDay: Date?
    @Binding var searchText: String
    @Binding var typeFilter: CategoryType?
    @Binding var categoryFilters: Set<String>
    let categoryRepository: CategoryRepository
    let totalExpense: Double
    let totalIncome: Double
    let balance: Double

    private enum FullScreenDestination: Identifiable {
        case calendar
        case searchFilter

        var id: Self { self }
    }

    @State private var isMonthYearPickerPresented = false
    @State private var fullScreenDestination: FullScreenDestination?

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Text("Expenses")
                    .font(.title2.bold())
                Spacer()
                Button {
                    fullScreenDestination = .searchFilter
                } label: {
                    Image(systemName: "magnifyingglass")
                        .foregroundStyle(.secondary)
                }
                Button {
                    fullScreenDestination = .calendar
                } label: {
                    Image(systemName: "calendar")
                        .foregroundStyle(.secondary)
                }
            }

            HStack(alignment: .top) {
                Button {
                    isMonthYearPickerPresented = true
                } label: {
                    VStack(alignment: .leading, spacing: 2) {
                        Text(selectedMonth.formatted(.dateTime.year()))
                            .font(.caption)
                            .foregroundStyle(.secondary)
                        HStack(spacing: 4) {
                            if let selectedDay {
                                Text(selectedDay.formatted(.dateTime.day().month(.abbreviated)))
                                    .font(.title3.bold())
                            } else {
                                Text(selectedMonth.formatted(.dateTime.month(.abbreviated)))
                                    .font(.title3.bold())
                            }
                            Image(systemName: "chevron.down")
                                .font(.caption2)
                        }
                        .foregroundStyle(.primary)
                    }
                }
                .buttonStyle(.plain)

                Spacer()

                statColumn(title: "Expenses", amount: totalExpense, color: Color(.systemRed))
                Spacer()
                statColumn(title: "Income", amount: totalIncome, color: Color(.systemGreen))
                Spacer()
                statColumn(title: "Balance", amount: balance, color: Color(.systemBlue))
            }
        }
        .padding()
        .background(Color(.secondarySystemGroupedBackground))
        .sheet(isPresented: $isMonthYearPickerPresented) {
            MonthYearPickerView(selectedMonth: $selectedMonth, selectedDay: $selectedDay)
        }
        .fullScreenCover(item: $fullScreenDestination) { destination in
            switch destination {
            case .calendar:
                CalendarDayPickerView(selectedMonth: $selectedMonth, selectedDay: $selectedDay)
            case .searchFilter:
                SearchFilterView(
                    searchText: $searchText,
                    typeFilter: $typeFilter,
                    categoryFilters: $categoryFilters,
                    categoryRepository: categoryRepository
                )
            }
        }
    }

    private func statColumn(title: String, amount: Double, color: Color) -> some View {
        VStack(alignment: .leading, spacing: 2) {
            Text(title)
                .font(.caption)
                .foregroundStyle(.secondary)
            Text("₹\(amount, specifier: "%.0f")")
                .font(.subheadline.bold())
                .foregroundStyle(color)
        }
    }
}

#Preview {
    ExpensesHeaderView(
        selectedMonth: .constant(Date()),
        selectedDay: .constant(nil),
        searchText: .constant(""),
        typeFilter: .constant(nil),
        categoryFilters: .constant([]),
        categoryRepository: PreviewCategoryRepository(),
        totalExpense: 4200,
        totalIncome: 50000,
        balance: 45800
    )
}

private class PreviewCategoryRepository: CategoryRepository {
    func fetchAll() -> [Category] { [] }
    func add(_ category: Category) {}
}
