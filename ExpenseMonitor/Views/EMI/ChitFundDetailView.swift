//
//  ChitFundDetailView.swift
//  ExpenseMonitor
//

import SwiftUI
import Charts

struct ChitFundDetailView: View {
    let chitFund: ChitFund
    var onChange: (() -> Void)? = nil

    @Environment(\.dismiss) private var dismiss
    @Environment(\.themeColors) private var themeColors
    @Environment(\.typography) private var typography
    @Environment(\.chitFundRepository) private var repository
    @Environment(\.expenseRepository) private var expenseRepository

    @State private var isDeleteConfirmationPresented = false
    @State private var isPayoutSheetPresented = false
    @State private var pendingLatePayment: PendingPayment?
    @State private var isEditPresented = false

    private let columns = Array(repeating: GridItem(.flexible()), count: 4)

    private var paidCount: Int {
        chitFund.paidContributions.count
    }

    private var durationText: String {
        let start = chitFund.startDate.formatted(.dateTime.month(.abbreviated).year())
        let end = chitFund.endDate.formatted(.dateTime.month(.abbreviated).year())
        return "\(start) – \(end)"
    }

    private var progressData: [(String, Double, Color)] {
        [
            ("paid", Double(paidCount), themeColors.accent),
            ("remaining", Double(chitFund.numberOfMonths - paidCount), themeColors.surfaceSecondary)
        ]
    }

    var body: some View {
        VStack(spacing: 0) {
            HStack {
                Button("Cancel") {
                    dismiss()
                }
                Spacer()
                Text(chitFund.name)
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
                        .foregroundStyle(Color(.systemRed))
                        .frame(width: 44, height: 44)
                }
            }
            .padding()

            ScrollView {
                VStack(spacing: 16) {
                    summaryCard
                    detailRows
                    payoutCard

                    Text("Contribution history")
                        .font(typography.subheadline)
                        .foregroundStyle(.secondary)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(.horizontal)

                    LazyVGrid(columns: columns, spacing: 12) {
                        ForEach(chitFund.contributions) { contribution in
                            contributionCell(contribution)
                        }
                    }
                    .padding(.horizontal)
                }
                .padding(.vertical, 16)
            }

            actionRow
        }
        .background(themeColors.background)
        .confirmationDialog("Delete this chit fund?", isPresented: $isDeleteConfirmationPresented, titleVisibility: .visible) {
            Button("Delete", role: .destructive) {
                repository.delete(chitFund)
                onChange?()
                dismiss()
            }
        }
        .sheet(isPresented: $isPayoutSheetPresented) {
            PayoutSheet(chitFund: chitFund) { month, amount in
                chitFund.payoutMonth = month
                chitFund.payoutAmount = amount
                repository.update(chitFund)
                onChange?()
            }
        }
        .sheet(item: $pendingLatePayment) { pending in
            ConfirmPaymentSheet(dueDate: pending.dueDate) { paidDate, penalty in
                confirmPayment(number: pending.number, paidDate: paidDate, penalty: penalty)
            }
        }
        .fullScreenCover(isPresented: $isEditPresented) {
            AddChitFundView(existingChitFund: chitFund, onSave: { onChange?() })
        }
    }

    private var summaryCard: some View {
        HStack(alignment: .top) {
            VStack(alignment: .leading, spacing: 14) {
                VStack(alignment: .leading, spacing: 2) {
                    Text("Contributed")
                        .font(typography.caption)
                        .foregroundStyle(.secondary)
                    Text(chitFund.totalContributed.currencyFormatted)
                        .font(typography.amount(size: 20))
                }
                VStack(alignment: .leading, spacing: 2) {
                    Text("Remaining")
                        .font(typography.caption)
                        .foregroundStyle(.secondary)
                    Text(chitFund.remainingContributions.currencyFormatted)
                        .font(typography.amount(size: 20))
                }
            }
            Spacer()
            progressRing
        }
        .padding()
        .background(themeColors.surface)
        .clipShape(RoundedRectangle(cornerRadius: 16))
        .overlay {
            RoundedRectangle(cornerRadius: 16)
                .strokeBorder(Color.primary.opacity(0.08), lineWidth: 1)
        }
        .padding(.horizontal)
    }

    private var progressRing: some View {
        ZStack {
            Chart(progressData, id: \.0) { item in
                SectorMark(
                    angle: .value("Count", item.1),
                    innerRadius: .ratio(0.72)
                )
                .foregroundStyle(item.2)
                .cornerRadius(3)
            }
            .frame(width: 96, height: 96)

            VStack(spacing: 0) {
                Text("\(paidCount)")
                    .font(typography.subheadlineBold)
                Text("of \(chitFund.numberOfMonths)")
                    .font(typography.caption2)
                    .foregroundStyle(.secondary)
            }
        }
    }

    private var detailRows: some View {
        VStack(spacing: 0) {
            detailRow("Duration", durationText)
            Divider().padding(.leading)
            detailRow("Chit value", chitFund.chitValue.currencyFormatted)
            Divider().padding(.leading)
            detailRow("Monthly contribution", chitFund.monthlyContribution.currencyFormatted)
            if let organizer = chitFund.organizer, !organizer.isEmpty {
                Divider().padding(.leading)
                detailRow("Organizer", organizer)
            }
            if chitFund.totalPenalties > 0 {
                Divider().padding(.leading)
                detailRow("Total penalties", chitFund.totalPenalties.currencyFormatted, valueColor: themeColors.expense)
            }
        }
        .padding(.vertical, 4)
        .background(themeColors.surface)
        .clipShape(RoundedRectangle(cornerRadius: 16))
        .overlay {
            RoundedRectangle(cornerRadius: 16)
                .strokeBorder(Color.primary.opacity(0.08), lineWidth: 1)
        }
        .padding(.horizontal)
    }

    private func detailRow(_ label: String, _ value: String, valueColor: Color = .primary) -> some View {
        HStack {
            Text(label)
                .font(typography.subheadline)
                .foregroundStyle(.secondary)
            Spacer()
            Text(value)
                .font(typography.subheadlineBold)
                .foregroundStyle(valueColor)
        }
        .padding(.horizontal)
        .padding(.vertical, 10)
    }

    private var payoutCard: some View {
        Group {
            if let month = chitFund.payoutMonth, let amount = chitFund.payoutAmount {
                HStack {
                    VStack(alignment: .leading, spacing: 2) {
                        Text("Payout received")
                            .font(typography.caption)
                            .foregroundStyle(.secondary)
                        Text("\(amount.currencyFormatted) in month \(month)")
                            .font(typography.subheadlineBold)
                    }
                    Spacer()
                    Image(systemName: "checkmark.seal.fill")
                        .foregroundStyle(themeColors.income)
                }
                .padding()
                .background(themeColors.surface)
                .clipShape(RoundedRectangle(cornerRadius: 16))
                .overlay {
                    RoundedRectangle(cornerRadius: 16)
                        .strokeBorder(Color.primary.opacity(0.08), lineWidth: 1)
                }
                .padding(.horizontal)
            } else {
                Button {
                    isPayoutSheetPresented = true
                } label: {
                    HStack {
                        Text("Mark payout received")
                            .font(typography.subheadlineBold)
                        Spacer()
                        Image(systemName: "chevron.right")
                    }
                    .foregroundStyle(themeColors.accent)
                    .padding()
                    .background(themeColors.surface)
                    .clipShape(RoundedRectangle(cornerRadius: 16))
                    .overlay {
                        RoundedRectangle(cornerRadius: 16)
                            .strokeBorder(Color.primary.opacity(0.08), lineWidth: 1)
                    }
                }
                .padding(.horizontal)
            }
        }
    }

    private func contributionCell(_ contribution: ChitContribution) -> some View {
        let (background, foreground): (Color, Color) = {
            switch contribution.status {
            case .paid: return (themeColors.accent, .white)
            case .overdue: return (themeColors.expense.opacity(0.15), themeColors.expense)
            case .pending: return (themeColors.surfaceSecondary, .primary)
            }
        }()
        let isPayoutMonth = chitFund.payoutMonth == contribution.id
        return VStack(spacing: 2) {
            Text("\(contribution.id)")
                .font(typography.subheadlineBold)
            Text(contribution.dueDate.formatted(.dateTime.day().month(.abbreviated).year(.twoDigits)))
                .font(typography.caption2)
                .minimumScaleFactor(0.8)
                .lineLimit(1)
        }
        .foregroundStyle(foreground)
        .frame(maxWidth: .infinity)
        .frame(height: 56)
        .background(background)
        .clipShape(RoundedRectangle(cornerRadius: 10))
        .overlay(alignment: .topTrailing) {
            HStack(spacing: 2) {
                if chitFund.penaltyAmount(for: contribution.id) != nil {
                    Image(systemName: "exclamationmark.triangle.fill")
                        .font(.system(size: 9))
                        .foregroundStyle(foreground)
                }
                if isPayoutMonth {
                    Image(systemName: "star.fill")
                        .font(.system(size: 9))
                        .foregroundStyle(themeColors.income)
                }
            }
            .padding(4)
        }
    }

    private var actionRow: some View {
        HStack(spacing: 12) {
            Button {
                undoLastPayment()
            } label: {
                Text("Undo last payment")
                    .font(typography.subheadlineBold)
                    .foregroundStyle(.primary)
                    .frame(maxWidth: .infinity)
                    .frame(height: 48)
                    .background(themeColors.surfaceSecondary)
                    .clipShape(RoundedRectangle(cornerRadius: 12))
            }
            .disabled(paidCount == 0)
            .opacity(paidCount == 0 ? 0.5 : 1)

            Button {
                markNextPaid()
            } label: {
                Text("Mark next month paid")
                    .font(typography.subheadlineBold)
                    .foregroundStyle(.white)
                    .frame(maxWidth: .infinity)
                    .frame(height: 48)
                    .background(chitFund.nextDueContribution == nil ? Color(.systemGray4) : themeColors.accent)
                    .clipShape(RoundedRectangle(cornerRadius: 12))
            }
            .disabled(chitFund.nextDueContribution == nil)
        }
        .padding()
    }

    private func markNextPaid() {
        guard let next = chitFund.nextDueContribution else { return }
        if next.status == .overdue {
            pendingLatePayment = PendingPayment(number: next.id, dueDate: next.dueDate)
        } else {
            chitFund.paidContributions.append(next.id)
            repository.update(chitFund)
            logExpense(contributionNumber: next.id, penalty: 0)
            onChange?()
        }
    }

    private func confirmPayment(number: Int, paidDate: Date, penalty: Double) {
        chitFund.paidContributions.append(number)
        if penalty > 0 {
            chitFund.penalties.append(InstallmentPenalty(installmentNumber: number, amount: penalty))
        }
        repository.update(chitFund)
        logExpense(contributionNumber: number, penalty: penalty, expenseDate: paidDate)
        onChange?()
    }

    private func logExpense(contributionNumber: Int, penalty: Double, expenseDate: Date = Date()) {
        let expense = Expense(
            id: UUID().uuidString,
            title: "\(chitFund.name) — Chit Contribution",
            amount: chitFund.monthlyContribution + penalty,
            category: "Financial & Legal",
            type: .expense,
            expenseDate: expenseDate,
            note: penalty > 0 ? "Month #\(contributionNumber) (includes \(penalty.currencyFormatted) late penalty)" : "Month #\(contributionNumber)",
            categoryIcon: "creditcard.fill",
            linkedChitFundID: chitFund.id,
            linkedInstallmentNumber: contributionNumber
        )
        expenseRepository.add(expense)
    }

    private func removeLinkedExpense(contributionNumber: Int) {
        if let expense = expenseRepository.fetchAll().first(where: { $0.linkedChitFundID == chitFund.id && $0.linkedInstallmentNumber == contributionNumber }) {
            expenseRepository.delete(expense)
        }
    }

    private func undoLastPayment() {
        guard let last = chitFund.paidContributions.max() else { return }
        chitFund.paidContributions.removeAll { $0 == last }
        chitFund.penalties.removeAll { $0.installmentNumber == last }
        repository.update(chitFund)
        removeLinkedExpense(contributionNumber: last)
        onChange?()
    }
}

private struct PendingPayment: Identifiable {
    let id = UUID()
    let number: Int
    let dueDate: Date
}

private struct PayoutSheet: View {
    let chitFund: ChitFund
    var onSave: (Int, Double) -> Void

    @Environment(\.dismiss) private var dismiss
    @Environment(\.themeColors) private var themeColors
    @Environment(\.typography) private var typography

    @State private var selectedMonth: Int = 1
    @State private var amountText: String = ""

    private var isValid: Bool {
        Double(amountText) != nil && Double(amountText)! > 0
    }

    var body: some View {
        VStack(spacing: 0) {
            HStack {
                Button("Cancel") {
                    dismiss()
                }
                Spacer()
                Text("Mark Payout Received")
                    .font(typography.headline)
                Spacer()
                Color.clear
                    .frame(width: 44, height: 44)
            }
            .padding()

            VStack(spacing: 16) {
                VStack(alignment: .leading, spacing: 6) {
                    Text("Month")
                        .font(typography.caption)
                        .foregroundStyle(.secondary)
                    Picker("Month", selection: $selectedMonth) {
                        ForEach(1...chitFund.numberOfMonths, id: \.self) { month in
                            Text("Month \(month)").tag(month)
                        }
                    }
                    .pickerStyle(.wheel)
                    .background(themeColors.surfaceSecondary)
                    .clipShape(RoundedRectangle(cornerRadius: 10))
                }

                VStack(alignment: .leading, spacing: 6) {
                    Text("Amount Received")
                        .font(typography.caption)
                        .foregroundStyle(.secondary)
                    TextField("0", text: $amountText)
                        .keyboardType(.decimalPad)
                        .padding(12)
                        .background(themeColors.surfaceSecondary)
                        .clipShape(RoundedRectangle(cornerRadius: 10))
                }
            }
            .padding()

            Spacer()

            Button {
                if let amount = Double(amountText) {
                    onSave(selectedMonth, amount)
                    dismiss()
                }
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
        .presentationDetents([.medium])
    }
}

private struct ConfirmPaymentSheet: View {
    let dueDate: Date
    var onConfirm: (Date, Double) -> Void

    @Environment(\.dismiss) private var dismiss
    @Environment(\.themeColors) private var themeColors
    @Environment(\.typography) private var typography

    @State private var paidDate: Date
    @State private var penaltyText: String = ""

    init(dueDate: Date, onConfirm: @escaping (Date, Double) -> Void) {
        self.dueDate = dueDate
        self.onConfirm = onConfirm
        _paidDate = State(initialValue: dueDate)
    }

    private var isLate: Bool {
        Calendar.current.startOfDay(for: paidDate) > Calendar.current.startOfDay(for: dueDate)
    }

    var body: some View {
        VStack(spacing: 0) {
            HStack {
                Button("Cancel") {
                    dismiss()
                }
                Spacer()
                Text("Confirm Payment")
                    .font(typography.headline)
                Spacer()
                Color.clear
                    .frame(width: 44, height: 44)
            }
            .padding()

            VStack(alignment: .leading, spacing: 16) {
                Text("This contribution was due on \(dueDate.formatted(date: .abbreviated, time: .omitted)). When did you actually pay it?")
                    .font(typography.subheadline)
                    .foregroundStyle(.secondary)

                DatePicker("Paid on", selection: $paidDate, in: ...Date(), displayedComponents: .date)
                    .datePickerStyle(.graphical)

                if isLate {
                    VStack(alignment: .leading, spacing: 6) {
                        Text("Penalty Amount (optional)")
                            .font(typography.caption)
                            .foregroundStyle(.secondary)
                        TextField("0", text: $penaltyText)
                            .keyboardType(.decimalPad)
                            .padding(12)
                            .background(themeColors.surfaceSecondary)
                            .clipShape(RoundedRectangle(cornerRadius: 10))
                    }
                }
            }
            .padding()

            Spacer()

            Button {
                onConfirm(paidDate, Double(penaltyText) ?? 0)
                dismiss()
            } label: {
                Text("Mark Paid")
                    .font(typography.headline)
                    .foregroundStyle(.white)
                    .frame(maxWidth: .infinity)
                    .frame(height: 52)
                    .background(themeColors.accent)
                    .clipShape(RoundedRectangle(cornerRadius: 12))
            }
            .padding()
        }
        .background(themeColors.background)
        .presentationDetents([.large])
    }
}

#Preview {
    ChitFundDetailView(
        chitFund: ChitFund(id: "preview", name: "Office Chit 2026", monthlyContribution: 5000, chitValue: 100000, startDate: Date(), numberOfMonths: 20)
    )
    .environment(\.chitFundRepository, PreviewChitFundRepository())
    .environment(\.expenseRepository, PreviewExpenseRepository())
}

private class PreviewChitFundRepository: ChitFundRepository {
    func fetchAll() -> [ChitFund] { [] }
    func add(_ chitFund: ChitFund) {}
    func update(_ chitFund: ChitFund) {}
    func delete(_ chitFund: ChitFund) {}
}

private class PreviewExpenseRepository: ExpenseRepository {
    func fetchAll() -> [Expense] { [] }
    func add(_ expense: Expense) {}
    func update(_ expense: Expense) {}
    func delete(_ expense: Expense) {}
}
