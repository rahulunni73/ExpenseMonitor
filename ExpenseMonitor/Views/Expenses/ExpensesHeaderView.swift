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

    @Environment(\.themeColors) private var themeColors
    @Environment(\.typography) private var typography

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Text("Expenses")
                    .font(typography.title2Bold)
                Spacer()
                Button {
                    fullScreenDestination = .searchFilter
                } label: {
                    Image(systemName: "magnifyingglass")
                        .font(.system(size: 20))
                        .foregroundStyle(.secondary)
                        .frame(width: 44, height: 44)
                }
                Button {
                    fullScreenDestination = .calendar
                } label: {
                    Image(systemName: "calendar")
                        .font(.system(size: 20))
                        .foregroundStyle(.secondary)
                        .frame(width: 44, height: 44)
                }
            }

            HStack(alignment: .top) {
                Button {
                    isMonthYearPickerPresented = true
                } label: {
                    VStack(alignment: .leading, spacing: 2) {
                        Text(selectedMonth.formatted(.dateTime.year()))
                            .font(typography.caption)
                            .foregroundStyle(.secondary)
                        HStack(spacing: 4) {
                            if let selectedDay {
                                Text(selectedDay.formatted(.dateTime.day().month(.abbreviated)))
                                    .font(typography.title3Bold)
                            } else {
                                Text(selectedMonth.formatted(.dateTime.month(.abbreviated)))
                                    .font(typography.title3Bold)
                            }
                            Image(systemName: "chevron.down")
                                .font(.caption2)
                        }
                        .foregroundStyle(.primary)
                    }
                }
                .buttonStyle(.plain)

                Spacer()

                statColumn(title: "Expenses", amount: totalExpense, color: themeColors.expense)
                Spacer()
                statColumn(title: "Income", amount: totalIncome, color: themeColors.income)
                Spacer()
                statColumn(title: "Balance", amount: balance, color: themeColors.accent)
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
                .font(typography.caption)
                .foregroundStyle(.secondary)
            Text(amount.currencyFormatted)
                .font(typography.subheadlineBold)
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
