//
//  CalendarDayPickerView.swift
//  ExpenseMonitor
//

import SwiftUI

struct CalendarDayPickerView: View {
    @Binding var selectedMonth: Date
    @Binding var selectedDay: Date?
    let expenses: [Expense]
    @Environment(\.dismiss) private var dismiss
    @Environment(\.themeColors) private var themeColors
    @Environment(\.typography) private var typography

    @State private var displayedMonth: Date
    @State private var isMonthYearPickerPresented = false
    @State private var internalPickerDay: Date? = nil

    private let columns = Array(repeating: GridItem(.flexible()), count: 7)

    init(selectedMonth: Binding<Date>, selectedDay: Binding<Date?>, expenses: [Expense]) {
        self._selectedMonth = selectedMonth
        self._selectedDay = selectedDay
        self.expenses = expenses
        _displayedMonth = State(initialValue: selectedMonth.wrappedValue)
    }

    private var firstOfDisplayedMonth: Date {
        let components = Calendar.current.dateComponents([.year, .month], from: displayedMonth)
        return Calendar.current.date(from: DateComponents(year: components.year, month: components.month, day: 1)) ?? displayedMonth
    }

    private var daysInMonth: [Int] {
        let range = Calendar.current.range(of: .day, in: .month, for: firstOfDisplayedMonth) ?? 1..<1
        return Array(range)
    }

    private var leadingEmptyDays: Int {
        let weekday = Calendar.current.component(.weekday, from: firstOfDisplayedMonth)
        return weekday - 1
    }

    var body: some View {
        VStack(spacing: 0) {
            HStack {
                Button {
                    dismiss()
                } label: {
                    Image(systemName: "arrow.left")
                        .frame(width: 44, height: 44)
                }

                Spacer()

                Text("Calendar")
                    .font(typography.headline)

                Spacer()

                Button {
                    isMonthYearPickerPresented = true
                } label: {
                    HStack(spacing: 4) {
                        Text(displayedMonth.formatted(.dateTime.month(.abbreviated).year()))
                        Image(systemName: "chevron.down")
                            .font(.caption2)
                    }
                }
            }
            .padding()

            ScrollView {
                VStack(spacing: 20) {
                    LazyVGrid(columns: columns, spacing: 8) {
                        ForEach(Calendar.current.shortWeekdaySymbols, id: \.self) { symbol in
                            Text(symbol)
                                .font(typography.caption)
                                .foregroundStyle(.secondary)
                        }
                    }

                    LazyVGrid(columns: columns, spacing: 8) {
                        ForEach(Array(-leadingEmptyDays..<0), id: \.self) { _ in
                            Color.clear
                        }
                        ForEach(daysInMonth, id: \.self) { day in
                            dayCell(day)
                        }
                    }
                }
                .padding(.horizontal)
            }
        }
        .sheet(isPresented: $isMonthYearPickerPresented) {
            MonthYearPickerView(selectedMonth: $displayedMonth, selectedDay: $internalPickerDay)
        }
        .onAppear {
            displayedMonth = selectedMonth
        }
    }

    private func netAmount(for day: Int) -> Double? {
        guard let date = Calendar.current.date(byAdding: .day, value: day - 1, to: firstOfDisplayedMonth) else { return nil }
        let dayExpenses = expenses.filter { Calendar.current.isDate($0.expenseDate, inSameDayAs: date) }
        guard !dayExpenses.isEmpty else { return nil }
        return dayExpenses.reduce(0) { partial, expense in
            partial + (expense.type == .income ? expense.amount : -expense.amount)
        }
    }

    private func compactAmount(_ value: Double) -> String {
        let magnitude = abs(value)
        let sign = value < 0 ? "-" : "+"
        if magnitude >= 1000 {
            return "\(sign)\(String(format: "%.1fk", magnitude / 1000))"
        } else {
            return "\(sign)\(Int(magnitude))"
        }
    }

    private func dayCell(_ day: Int) -> some View {
        let net = netAmount(for: day)
        return VStack(spacing: 2) {
            Text("\(day)")
                .font(typography.subheadline)
            if let net {
                Text(compactAmount(net))
                    .font(typography.caption2)
                    .foregroundStyle(net >= 0 ? themeColors.income : themeColors.expense)
                    .lineLimit(1)
                    .minimumScaleFactor(0.7)
            }
        }
        .frame(maxWidth: .infinity)
        .frame(height: 60)
        .background(themeColors.surfaceSecondary)
        .clipShape(RoundedRectangle(cornerRadius: 8))
        .contentShape(Rectangle())
        .onTapGesture {
            if let pickedDate = Calendar.current.date(byAdding: .day, value: day - 1, to: firstOfDisplayedMonth) {
                selectedMonth = pickedDate
                selectedDay = pickedDate
            }
            dismiss()
        }
    }
}

#Preview {
    CalendarDayPickerView(
        selectedMonth: .constant(Date()),
        selectedDay: .constant(nil),
        expenses: [
            Expense(id: "1", title: "Groceries", amount: 450, category: "Food & Dining", expenseDate: Date(), categoryIcon: "fork.knife", categoryColorName: "systemGreen"),
            Expense(id: "2", title: "Salary", amount: 55000, category: "Salary", type: .income, expenseDate: Date(), categoryIcon: "banknote.fill", categoryColorName: "systemGreen")
        ]
    )
}
