//
//  CalendarDayPickerView.swift
//  ExpenseMonitor
//

import SwiftUI

struct CalendarDayPickerView: View {
    @Binding var selectedMonth: Date
    @Binding var selectedDay: Date?
    @Environment(\.dismiss) private var dismiss

    @State private var displayedMonth: Date
    @State private var isMonthYearPickerPresented = false
    @State private var internalPickerDay: Date? = nil

    private let columns = Array(repeating: GridItem(.flexible()), count: 7)

    init(selectedMonth: Binding<Date>, selectedDay: Binding<Date?>) {
        self._selectedMonth = selectedMonth
        self._selectedDay = selectedDay
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
                }

                Spacer()

                Text("Calendar")
                    .font(.headline)

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
                                .font(.caption)
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

    private func dayCell(_ day: Int) -> some View {
        Text("\(day)")
            .font(.subheadline)
            .frame(maxWidth: .infinity)
            .frame(height: 44)
            .background(Color(.systemGray6))
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
    CalendarDayPickerView(selectedMonth: .constant(Date()), selectedDay: .constant(nil))
}
