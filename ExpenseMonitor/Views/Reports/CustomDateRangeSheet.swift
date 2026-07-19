//
//  CustomDateRangeSheet.swift
//  ExpenseMonitor
//

import SwiftUI

struct CustomDateRangeSheet: View {
    let initialRange: DateInterval?
    var onConfirm: (Date, Date) -> Void

    @Environment(\.dismiss) private var dismiss
    @Environment(\.themeColors) private var themeColors
    @Environment(\.typography) private var typography

    @State private var startDate: Date
    @State private var endDate: Date

    init(initialRange: DateInterval?, onConfirm: @escaping (Date, Date) -> Void) {
        self.initialRange = initialRange
        self.onConfirm = onConfirm
        let calendar = Calendar.current
        if let initialRange {
            _startDate = State(initialValue: initialRange.start)
            _endDate = State(initialValue: calendar.date(byAdding: .day, value: -1, to: initialRange.end) ?? initialRange.end)
        } else {
            _startDate = State(initialValue: calendar.date(byAdding: .day, value: -6, to: Date()) ?? Date())
            _endDate = State(initialValue: Date())
        }
    }

    private var isValid: Bool {
        startDate <= endDate
    }

    var body: some View {
        VStack(spacing: 0) {
            HStack {
                Button("Cancel") {
                    dismiss()
                }
                Spacer()
                Text("Custom Range")
                    .font(typography.headline)
                Spacer()
                Color.clear
                    .frame(width: 44, height: 44)
            }
            .padding()

            VStack(spacing: 16) {
                DatePicker("Start Date", selection: $startDate, in: ...Date(), displayedComponents: .date)
                DatePicker("End Date", selection: $endDate, in: ...Date(), displayedComponents: .date)

                if !isValid {
                    Text("End date must be on or after the start date.")
                        .font(typography.caption)
                        .foregroundStyle(themeColors.expense)
                }
            }
            .padding()

            Spacer()

            Button {
                onConfirm(startDate, endDate)
                dismiss()
            } label: {
                Text("Apply")
                    .font(typography.headline)
                    .foregroundStyle(.white)
                    .frame(maxWidth: .infinity)
                    .frame(height: 52)
                    .background(isValid ? themeColors.accent : Color(.systemGray4))
                    .clipShape(RoundedRectangle(cornerRadius: 12))
            }
            .disabled(!isValid)
            .padding()
        }
        .background(themeColors.background)
        .presentationDetents([.medium])
    }
}

#Preview {
    CustomDateRangeSheet(initialRange: nil) { _, _ in }
}
