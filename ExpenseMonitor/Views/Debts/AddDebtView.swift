//
//  AddDebtView.swift
//  ExpenseMonitor
//

import SwiftUI

struct AddDebtView: View {
    var existingDebt: Debt? = nil
    var initialDirection: DebtDirection = .owedToMe
    var onSave: (() -> Void)? = nil

    @Environment(\.dismiss) private var dismiss
    @Environment(\.themeColors) private var themeColors
    @Environment(\.typography) private var typography
    @Environment(\.debtRepository) private var repository

    @State private var personName = ""
    @State private var direction: DebtDirection = .owedToMe
    @State private var amountText = ""
    @State private var date = Date()
    @State private var note = ""
    @State private var isDatePickerPresented = false
    @Namespace private var glassNamespace

    private var isValid: Bool {
        guard let amount = Double(amountText), amount > 0 else { return false }
        return !personName.isEmpty
    }

    var body: some View {
        VStack(spacing: 0) {
            HStack {
                Button("Cancel") {
                    dismiss()
                }
                Spacer()
                Text(existingDebt == nil ? "Add Debt" : "Edit Debt")
                    .font(typography.headline)
                Spacer()
                Color.clear
                    .frame(width: 44, height: 44)
            }
            .padding()

            GlassEffectContainer(spacing: 8) {
                HStack(spacing: 8) {
                    directionButton(.owedToMe)
                    directionButton(.owedByMe)
                }
            }
            .padding(.horizontal)
            .padding(.bottom, 12)

            ScrollView {
                VStack(spacing: 16) {
                    field("Person's Name", text: $personName, placeholder: "e.g. Rahul")
                    field("Amount", text: $amountText, placeholder: "0", keyboard: .decimalPad)
                    field("Note (optional)", text: $note, placeholder: "e.g. Lunch money")

                    VStack(alignment: .leading, spacing: 6) {
                        Button {
                            isDatePickerPresented = true
                        } label: {
                            HStack {
                                Text(direction == .owedToMe ? "Date Given" : "Date Received")
                                    .foregroundStyle(.primary)
                                Spacer()
                                Text(date.formatted(date: .abbreviated, time: .omitted))
                                    .foregroundStyle(.secondary)
                            }
                            .padding(12)
                            .background(themeColors.surfaceSecondary)
                            .clipShape(RoundedRectangle(cornerRadius: 10))
                        }
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
            if let existingDebt {
                personName = existingDebt.personName
                direction = existingDebt.direction
                amountText = formattedAmount(existingDebt.amount)
                date = existingDebt.date
                note = existingDebt.note ?? ""
            } else {
                direction = initialDirection
            }
        }
        .sheet(isPresented: $isDatePickerPresented) {
            DatePicker("Date", selection: $date, in: ...Date(), displayedComponents: .date)
                .datePickerStyle(.graphical)
                .padding()
                .presentationDetents([.medium])
        }
    }

    private func directionButton(_ option: DebtDirection) -> some View {
        let isSelected = direction == option
        return Button {
            withAnimation(.spring(response: 0.45, dampingFraction: 0.72)) {
                direction = option
            }
        } label: {
            HStack(spacing: 6) {
                Image(systemName: option.icon)
                Text(option.title)
            }
            .font(typography.subheadline(emphasized: isSelected))
            .foregroundStyle(isSelected ? .white : .primary)
            .frame(maxWidth: .infinity)
            .frame(height: 40)
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
        .glassEffect(
            isSelected ? .regular.tint(themeColors.accent).interactive() : .regular.interactive(),
            in: Capsule()
        )
        .matchedGeometryEffect(id: isSelected ? "debtDirectionIndicator" : "\(option.rawValue)-idle", in: glassNamespace)
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
        guard let amount = Double(amountText) else { return }

        if let existingDebt {
            existingDebt.personName = personName
            existingDebt.direction = direction
            existingDebt.amount = amount
            existingDebt.date = date
            existingDebt.note = note.isEmpty ? nil : note
            existingDebt.amountRepaid = min(existingDebt.amountRepaid, amount)
            existingDebt.isSettled = existingDebt.amountRepaid >= amount
            repository.update(existingDebt)
        } else {
            let debt = Debt(
                id: UUID().uuidString,
                personName: personName,
                direction: direction,
                amount: amount,
                date: date,
                note: note.isEmpty ? nil : note
            )
            repository.add(debt)
        }

        onSave?()
        dismiss()
    }
}

#Preview {
    AddDebtView()
        .environment(\.debtRepository, PreviewDebtRepository())
}

private class PreviewDebtRepository: DebtRepository {
    func fetchAll() -> [Debt] { [] }
    func add(_ debt: Debt) {}
    func update(_ debt: Debt) {}
    func delete(_ debt: Debt) {}
}
