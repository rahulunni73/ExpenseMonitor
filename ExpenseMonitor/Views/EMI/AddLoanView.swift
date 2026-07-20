//
//  AddLoanView.swift
//  ExpenseMonitor
//

import SwiftUI

struct AddLoanView: View {
    var existingLoan: Loan? = nil
    var onSave: (() -> Void)? = nil

    @Environment(\.dismiss) private var dismiss
    @Environment(\.themeColors) private var themeColors
    @Environment(\.typography) private var typography
    @Environment(\.loanRepository) private var repository

    @State private var name = ""
    @State private var type: LoanType = .loan
    @State private var lender = ""
    @State private var principalAmountText = ""
    @State private var installmentAmountText = ""
    @State private var startDate = Date()
    @State private var numberOfInstallmentsText = ""
    @State private var isDatePickerPresented = false

    private var isValid: Bool {
        guard let principal = Double(principalAmountText), principal > 0 else { return false }
        guard let amount = Double(installmentAmountText), amount > 0 else { return false }
        guard let count = Int(numberOfInstallmentsText), count > 0 else { return false }
        return !name.isEmpty
    }

    var body: some View {
        VStack(spacing: 0) {
            HStack {
                Button("Cancel") {
                    dismiss()
                }
                Spacer()
                Text(existingLoan == nil ? "Add Loan" : "Edit Loan")
                    .font(typography.headline)
                Spacer()
                Color.clear
                    .frame(width: 44, height: 44)
            }
            .padding()

            Picker("", selection: $type) {
                Text("Loan").tag(LoanType.loan)
                Text("Credit Card").tag(LoanType.creditCard)
            }
            .pickerStyle(.segmented)
            .padding(.horizontal)
            .padding(.bottom, 12)

            ScrollView {
                VStack(spacing: 16) {
                    field("Name", text: $name, placeholder: "e.g. Home Loan")
                    field("Lender (optional)", text: $lender, placeholder: "e.g. HDFC Bank")
                    field("Loan Amount", text: $principalAmountText, placeholder: "0", keyboard: .decimalPad)
                    field("Installment Amount", text: $installmentAmountText, placeholder: "0", keyboard: .decimalPad)
                    field("Number of Installments", text: $numberOfInstallmentsText, placeholder: "e.g. 24", keyboard: .numberPad)

                    VStack(alignment: .leading, spacing: 6) {
                        Button {
                            isDatePickerPresented = true
                        } label: {
                            HStack {
                                Text("First EMI Due Date")
                                    .foregroundStyle(.primary)
                                Spacer()
                                Text(startDate.formatted(date: .abbreviated, time: .omitted))
                                    .foregroundStyle(.secondary)
                            }
                            .padding(12)
                            .background(themeColors.surfaceSecondary)
                            .clipShape(RoundedRectangle(cornerRadius: 10))
                        }
                        Text("Every installment repeats on day \(Calendar.current.component(.day, from: startDate)) of each month after this one.")
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
                    .background(isValid ? Color(.systemGreen) : Color(.systemGray4))
                    .clipShape(RoundedRectangle(cornerRadius: 12))
            }
            .disabled(!isValid)
            .padding()
        }
        .background(themeColors.background)
        .onAppear {
            guard let existingLoan else { return }
            name = existingLoan.name
            type = existingLoan.type
            lender = existingLoan.lender ?? ""
            principalAmountText = formattedAmount(existingLoan.principalAmount)
            installmentAmountText = formattedAmount(existingLoan.installmentAmount)
            startDate = existingLoan.startDate
            numberOfInstallmentsText = String(existingLoan.numberOfInstallments)
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
        guard let principal = Double(principalAmountText),
              let amount = Double(installmentAmountText),
              let count = Int(numberOfInstallmentsText) else { return }

        if let existingLoan {
            existingLoan.name = name
            existingLoan.type = type
            existingLoan.lender = lender.isEmpty ? nil : lender
            existingLoan.principalAmount = principal
            existingLoan.installmentAmount = amount
            existingLoan.startDate = startDate
            existingLoan.numberOfInstallments = count
            existingLoan.paidInstallments.removeAll { $0 > count }
            existingLoan.penalties.removeAll { $0.installmentNumber > count }
            repository.update(existingLoan)
        } else {
            let loan = Loan(
                id: UUID().uuidString,
                name: name,
                type: type,
                lender: lender.isEmpty ? nil : lender,
                principalAmount: principal,
                installmentAmount: amount,
                startDate: startDate,
                numberOfInstallments: count
            )
            repository.add(loan)
        }

        onSave?()
        dismiss()
    }
}

#Preview {
    AddLoanView()
        .environment(\.loanRepository, PreviewLoanRepository())
}

private class PreviewLoanRepository: LoanRepository {
    func fetchAll() -> [Loan] { [] }
    func add(_ loan: Loan) {}
    func update(_ loan: Loan) {}
    func delete(_ loan: Loan) {}
}
