//
//  DebtDetailView.swift
//  ExpenseMonitor
//

import SwiftUI

struct DebtDetailView: View {
    let debt: Debt
    var onChange: (() -> Void)? = nil

    @Environment(\.dismiss) private var dismiss
    @Environment(\.themeColors) private var themeColors
    @Environment(\.typography) private var typography
    @Environment(\.debtRepository) private var repository

    @State private var isDeleteConfirmationPresented = false
    @State private var isEditPresented = false
    @State private var isRepaymentSheetPresented = false

    private var directionColor: Color {
        debt.direction == .owedToMe ? themeColors.income : themeColors.expense
    }

    var body: some View {
        VStack(spacing: 0) {
            HStack {
                Button("Cancel") {
                    dismiss()
                }
                Spacer()
                Text(debt.personName)
                    .font(typography.headline)
                Spacer()
                Button {
                    isEditPresented = true
                } label: {
                    Image(systemName: "pencil")
                        .foregroundStyle(themeColors.accent)
                        .frame(width: 44, height: 44)
                }
                Button {
                    isDeleteConfirmationPresented = true
                } label: {
                    Image(systemName: "trash")
                        .foregroundStyle(themeColors.expense)
                        .frame(width: 44, height: 44)
                }
            }
            .padding()

            ScrollView {
                VStack(spacing: 16) {
                    summaryCard
                    detailRows
                }
                .padding(.vertical, 16)
            }

            if !debt.isSettled {
                Button {
                    isRepaymentSheetPresented = true
                } label: {
                    Text(debt.direction == .owedToMe ? "Record Repayment Received" : "Record Repayment Made")
                        .font(typography.headline)
                        .foregroundStyle(.white)
                        .frame(maxWidth: .infinity)
                        .frame(height: 52)
                        .background(themeColors.accent)
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                }
                .padding()
            }
        }
        .background(themeColors.background)
        .confirmationDialog("Delete this debt?", isPresented: $isDeleteConfirmationPresented, titleVisibility: .visible) {
            Button("Delete", role: .destructive) {
                repository.delete(debt)
                onChange?()
                dismiss()
            }
        }
        .sheet(isPresented: $isEditPresented, onDismiss: { onChange?() }) {
            AddDebtView(existingDebt: debt, onSave: { onChange?() })
        }
        .sheet(isPresented: $isRepaymentSheetPresented) {
            RecordRepaymentSheet(debt: debt) { amount in
                recordRepayment(amount)
            }
        }
    }

    private func recordRepayment(_ amount: Double) {
        debt.amountRepaid = min(debt.amountRepaid + amount, debt.amount)
        if debt.amountRepaid >= debt.amount {
            debt.isSettled = true
            debt.settledDate = Date()
        }
        repository.update(debt)
        onChange?()
    }

    private var summaryCard: some View {
        VStack(spacing: 12) {
            HStack(spacing: 6) {
                Image(systemName: debt.direction.icon)
                Text(debt.direction.title)
            }
            .font(typography.subheadline)
            .foregroundStyle(themeColors.accent)

            Text(debt.remainingAmount.currencyFormatted)
                .font(typography.amount(size: 34))
                .foregroundStyle(directionColor)

            Text("remaining of \(debt.amount.currencyFormatted)")
                .font(typography.caption)
                .foregroundStyle(.secondary)

            ProgressView(value: debt.progress)
                .tint(directionColor)
                .padding(.horizontal)

            if debt.isSettled {
                Text("Settled")
                    .font(typography.caption2)
                    .foregroundStyle(themeColors.income)
            }
        }
        .padding()
        .frame(maxWidth: .infinity)
        .background(themeColors.surface)
        .clipShape(RoundedRectangle(cornerRadius: 16))
        .padding(.horizontal)
    }

    private var detailRows: some View {
        VStack(spacing: 0) {
            detailRow(label: debt.direction == .owedToMe ? "Given On" : "Received On", value: debt.date.formatted(date: .abbreviated, time: .omitted))
            if let settledDate = debt.settledDate {
                Divider().padding(.leading)
                detailRow(label: "Settled On", value: settledDate.formatted(date: .abbreviated, time: .omitted))
            }
            if let note = debt.note, !note.isEmpty {
                Divider().padding(.leading)
                detailRow(label: "Note", value: note)
            }
        }
        .background(themeColors.surface)
        .clipShape(RoundedRectangle(cornerRadius: 12))
        .overlay {
            RoundedRectangle(cornerRadius: 12)
                .strokeBorder(Color.primary.opacity(0.08), lineWidth: 1)
        }
        .padding(.horizontal)
    }

    private func detailRow(label: String, value: String) -> some View {
        HStack {
            Text(label)
                .font(typography.body)
                .foregroundStyle(.secondary)
            Spacer()
            Text(value)
                .font(typography.body)
                .multilineTextAlignment(.trailing)
        }
        .padding()
    }
}

private struct RecordRepaymentSheet: View {
    let debt: Debt
    var onConfirm: (Double) -> Void

    @Environment(\.dismiss) private var dismiss
    @Environment(\.themeColors) private var themeColors
    @Environment(\.typography) private var typography

    @State private var amountText: String
    @FocusState private var isAmountFieldFocused: Bool

    init(debt: Debt, onConfirm: @escaping (Double) -> Void) {
        self.debt = debt
        self.onConfirm = onConfirm
        _amountText = State(initialValue: debt.remainingAmount.truncatingRemainder(dividingBy: 1) == 0
            ? String(Int(debt.remainingAmount))
            : String(debt.remainingAmount))
    }

    private var isValid: Bool {
        guard let amount = Double(amountText) else { return false }
        return amount > 0 && amount <= debt.remainingAmount
    }

    var body: some View {
        VStack(spacing: 0) {
            HStack {
                Button("Cancel") {
                    dismiss()
                }
                Spacer()
                Text("Record Repayment")
                    .font(typography.headline)
                Spacer()
                Color.clear
                    .frame(width: 44, height: 44)
            }
            .padding()

            VStack(alignment: .leading, spacing: 16) {
                Text("Remaining balance: \(debt.remainingAmount.currencyFormatted)")
                    .font(typography.subheadline)
                    .foregroundStyle(.secondary)

                VStack(alignment: .leading, spacing: 6) {
                    Text("Amount")
                        .font(typography.caption)
                        .foregroundStyle(.secondary)
                    TextField("0", text: $amountText)
                        .keyboardType(.decimalPad)
                        .focused($isAmountFieldFocused)
                        .padding(12)
                        .background(themeColors.surfaceSecondary)
                        .clipShape(RoundedRectangle(cornerRadius: 10))
                }
            }
            .padding()

            Spacer()

            Button {
                if let amount = Double(amountText) {
                    onConfirm(amount)
                }
                dismiss()
            } label: {
                Text("Confirm")
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
        .toolbar {
            ToolbarItemGroup(placement: .keyboard) {
                Spacer()
                Button("Done") {
                    isAmountFieldFocused = false
                }
            }
        }
    }
}

#Preview {
    DebtDetailView(
        debt: Debt(id: "preview", personName: "Rahul", direction: .owedToMe, amount: 2000, amountRepaid: 500, date: Date(), note: "Lunch money")
    )
    .environment(\.debtRepository, PreviewDebtRepository())
}

private class PreviewDebtRepository: DebtRepository {
    func fetchAll() -> [Debt] { [] }
    func add(_ debt: Debt) {}
    func update(_ debt: Debt) {}
    func delete(_ debt: Debt) {}
}
