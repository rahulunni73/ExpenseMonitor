//
//  AddChitFundView.swift
//  ExpenseMonitor
//

import SwiftUI

struct AddChitFundView: View {
    var existingChitFund: ChitFund? = nil
    var onSave: (() -> Void)? = nil

    @Environment(\.dismiss) private var dismiss
    @Environment(\.themeColors) private var themeColors
    @Environment(\.typography) private var typography
    @Environment(\.chitFundRepository) private var repository

    @State private var name = ""
    @State private var organizer = ""
    @State private var monthlyContributionText = ""
    @State private var chitValueText = ""
    @State private var startDate = Date()
    @State private var numberOfMonthsText = ""
    @State private var isDatePickerPresented = false

    private var isValid: Bool {
        guard let contribution = Double(monthlyContributionText), contribution > 0 else { return false }
        guard let value = Double(chitValueText), value > 0 else { return false }
        guard let count = Int(numberOfMonthsText), count > 0 else { return false }
        return !name.isEmpty
    }

    var body: some View {
        VStack(spacing: 0) {
            HStack {
                Button("Cancel") {
                    dismiss()
                }
                Spacer()
                Text(existingChitFund == nil ? "Add Chit Fund" : "Edit Chit Fund")
                    .font(typography.headline)
                Spacer()
                Color.clear
                    .frame(width: 44, height: 44)
            }
            .padding()

            ScrollView {
                VStack(spacing: 16) {
                    field("Name", text: $name, placeholder: "e.g. Office Chit 2026")
                    field("Organizer (optional)", text: $organizer, placeholder: "e.g. Margadarsi Chits")
                    field("Chit Value", text: $chitValueText, placeholder: "0", keyboard: .decimalPad)
                    field("Monthly Contribution", text: $monthlyContributionText, placeholder: "0", keyboard: .decimalPad)
                    field("Number of Months", text: $numberOfMonthsText, placeholder: "e.g. 20", keyboard: .numberPad)

                    VStack(alignment: .leading, spacing: 6) {
                        Button {
                            isDatePickerPresented = true
                        } label: {
                            HStack {
                                Text("First Due Date")
                                    .foregroundStyle(.primary)
                                Spacer()
                                Text(startDate.formatted(date: .abbreviated, time: .omitted))
                                    .foregroundStyle(.secondary)
                            }
                            .padding(12)
                            .background(themeColors.surfaceSecondary)
                            .clipShape(RoundedRectangle(cornerRadius: 10))
                        }
                        Text("Every contribution repeats on day \(Calendar.current.component(.day, from: startDate)) of each month after this one.")
                            .font(typography.caption)
                            .foregroundStyle(.secondary)
                    }
                }
                .padding()
            }

            Button {
                save()
            } label: {
                Text("Save")
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
        .onAppear {
            guard let existingChitFund else { return }
            name = existingChitFund.name
            organizer = existingChitFund.organizer ?? ""
            chitValueText = formattedAmount(existingChitFund.chitValue)
            monthlyContributionText = formattedAmount(existingChitFund.monthlyContribution)
            startDate = existingChitFund.startDate
            numberOfMonthsText = String(existingChitFund.numberOfMonths)
        }
        .sheet(isPresented: $isDatePickerPresented) {
            DatePicker("Start Date", selection: $startDate, displayedComponents: .date)
                .datePickerStyle(.graphical)
                .padding()
                .presentationDetents([.medium])
        }
    }

    private func formattedAmount(_ amount: Double) -> String {
        amount.truncatingRemainder(dividingBy: 1) == 0
            ? String(Int(amount))
            : String(amount)
    }

    private func field(_ label: String, text: Binding<String>, placeholder: String, keyboard: UIKeyboardType = .default) -> some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(label)
                .font(typography.caption)
                .foregroundStyle(.secondary)
            TextField(placeholder, text: text)
                .keyboardType(keyboard)
                .padding(12)
                .background(themeColors.surfaceSecondary)
                .clipShape(RoundedRectangle(cornerRadius: 10))
        }
    }

    private func save() {
        guard let value = Double(chitValueText),
              let contribution = Double(monthlyContributionText),
              let count = Int(numberOfMonthsText) else { return }

        if let existingChitFund {
            existingChitFund.name = name
            existingChitFund.organizer = organizer.isEmpty ? nil : organizer
            existingChitFund.monthlyContribution = contribution
            existingChitFund.chitValue = value
            existingChitFund.startDate = startDate
            existingChitFund.numberOfMonths = count
            existingChitFund.paidContributions.removeAll { $0 > count }
            existingChitFund.penalties.removeAll { $0.installmentNumber > count }
            if let payoutMonth = existingChitFund.payoutMonth, payoutMonth > count {
                existingChitFund.payoutMonth = nil
                existingChitFund.payoutAmount = nil
            }
            repository.update(existingChitFund)
        } else {
            let chitFund = ChitFund(
                id: UUID().uuidString,
                name: name,
                organizer: organizer.isEmpty ? nil : organizer,
                monthlyContribution: contribution,
                chitValue: value,
                startDate: startDate,
                numberOfMonths: count
            )
            repository.add(chitFund)
        }

        onSave?()
        dismiss()
    }
}

#Preview {
    AddChitFundView()
        .environment(\.chitFundRepository, PreviewChitFundRepository())
}

private class PreviewChitFundRepository: ChitFundRepository {
    func fetchAll() -> [ChitFund] { [] }
    func add(_ chitFund: ChitFund) {}
    func update(_ chitFund: ChitFund) {}
    func delete(_ chitFund: ChitFund) {}
}
