//
//  MonthYearPickerView.swift
//  ExpenseMonitor
//

import SwiftUI

struct MonthYearPickerView: View {
    @Binding var selectedMonth: Date
    @Binding var selectedDay: Date?
    @Environment(\.dismiss) private var dismiss
    @Environment(\.themeColors) private var themeColors
    @Environment(\.typography) private var typography

    @State private var pendingYear: Int
    @State private var pendingMonthIndex: Int

    private let monthSymbols = Calendar.current.shortMonthSymbols
    private let columns = Array(repeating: GridItem(.flexible()), count: 4)

    init(selectedMonth: Binding<Date>, selectedDay: Binding<Date?>) {
        self._selectedMonth = selectedMonth
        self._selectedDay = selectedDay
        let components = Calendar.current.dateComponents([.year, .month], from: selectedMonth.wrappedValue)
        _pendingYear = State(initialValue: components.year ?? Calendar.current.component(.year, from: Date()))
        _pendingMonthIndex = State(initialValue: components.month ?? 1)
    }

    private var pendingDate: Date {
        Calendar.current.date(from: DateComponents(year: pendingYear, month: pendingMonthIndex, day: 1)) ?? Date()
    }

    var body: some View {
        VStack(spacing: 20) {
            Text(pendingDate.formatted(.dateTime.month(.wide).year()))
                .font(typography.title3Bold)

            HStack {
                Button {
                    pendingYear -= 1
                } label: {
                    Image(systemName: "chevron.left")
                        .frame(width: 44, height: 44)
                }

                Spacer()

                Text(String(pendingYear))
                    .font(typography.headline)

                Spacer()

                Button {
                    pendingYear += 1
                } label: {
                    Image(systemName: "chevron.right")
                        .frame(width: 44, height: 44)
                }
            }
            .padding(.horizontal, 40)

            LazyVGrid(columns: columns, spacing: 16) {
                ForEach(1...12, id: \.self) { monthIndex in
                    monthButton(monthIndex)
                }
            }
            .padding(.horizontal)

            HStack(spacing: 40) {
                Button("Cancel") {
                    dismiss()
                }
                .foregroundStyle(.secondary)

                Button("Confirm") {
                    selectedMonth = pendingDate
                    selectedDay = nil
                    dismiss()
                }
                .foregroundStyle(themeColors.accent)
                .fontWeight(.semibold)
            }
            .padding(.top, 8)
        }
        .padding()
        .presentationDetents([.medium])
    }

    private func monthButton(_ monthIndex: Int) -> some View {
        let isSelected = monthIndex == pendingMonthIndex
        return Text(monthSymbols[monthIndex - 1])
            .font(typography.subheadline(emphasized: isSelected))
            .foregroundStyle(isSelected ? .white : .primary)
            .frame(maxWidth: .infinity)
            .padding(.vertical, 12)
            .background(isSelected ? themeColors.accent : themeColors.surfaceSecondary)
            .clipShape(Capsule())
            .contentShape(Rectangle())
            .onTapGesture {
                pendingMonthIndex = monthIndex
            }
    }
}

#Preview {
    MonthYearPickerView(selectedMonth: .constant(Date()), selectedDay: .constant(nil))
}
