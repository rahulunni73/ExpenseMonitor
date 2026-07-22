//
//  CompletedLoansView.swift
//  ExpenseMonitor
//

import SwiftUI

struct CompletedLoansView: View {
    let loans: [Loan]
    var onChange: (() -> Void)? = nil

    @State private var loanForDetail: Loan?

    @Environment(\.dismiss) private var dismiss
    @Environment(\.themeColors) private var themeColors
    @Environment(\.typography) private var typography

    var body: some View {
        VStack(spacing: 0) {
            HStack {
                Button("Done") {
                    dismiss()
                }
                Spacer()
                Text("Completed Loans")
                    .font(typography.headline)
                Spacer()
                Color.clear
                    .frame(width: 44, height: 44)
            }
            .padding()

            if loans.isEmpty {
                VStack(spacing: 12) {
                    Image(systemName: "checkmark.circle")
                        .font(.system(size: 40))
                        .foregroundStyle(.secondary)
                    Text("No completed loans yet")
                        .font(typography.headline)
                    Text("Loans move here once every installment is paid.")
                        .font(typography.subheadline)
                        .foregroundStyle(.secondary)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 32)
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            } else {
                ScrollView {
                    VStack(spacing: 12) {
                        ForEach(loans) { loan in
                            row(loan)
                                .onTapGesture {
                                    loanForDetail = loan
                                }
                        }
                    }
                    .padding()
                }
            }
        }
        .background(themeColors.background)
        .fullScreenCover(item: $loanForDetail, onDismiss: onChange) { loan in
            LoanDetailView(loan: loan, onChange: onChange)
        }
    }

    private func row(_ loan: Loan) -> some View {
        HStack(spacing: 12) {
            Image(systemName: loan.type.icon)
                .foregroundStyle(themeColors.accent)
                .frame(width: 44, height: 44)
                .background(themeColors.accent.opacity(0.15))
                .clipShape(Circle())

            VStack(alignment: .leading, spacing: 2) {
                Text(loan.name)
                    .font(typography.subheadline)
                if let lender = loan.lender, !lender.isEmpty {
                    Text(lender)
                        .font(typography.caption)
                        .foregroundStyle(.secondary)
                }
            }

            Spacer()

            VStack(alignment: .trailing, spacing: 2) {
                Text(loan.totalPayable.currencyFormatted)
                    .font(typography.amount(size: 15))
                Text("Completed \(loan.endDate.formatted(.dateTime.day().month(.abbreviated)))")
                    .font(typography.caption2)
                    .foregroundStyle(.secondary)
            }
        }
        .padding(12)
        .background(themeColors.surface)
        .clipShape(RoundedRectangle(cornerRadius: 14))
        .overlay {
            RoundedRectangle(cornerRadius: 14)
                .strokeBorder(Color.primary.opacity(0.08), lineWidth: 1)
        }
        .contentShape(Rectangle())
    }
}

#Preview {
    CompletedLoansView(loans: [
        Loan(id: "1", name: "Bike Loan", lender: "HDFC", principalAmount: 50000, installmentAmount: 5000, startDate: Date(), numberOfInstallments: 10, paidInstallments: Array(1...10))
    ])
}
