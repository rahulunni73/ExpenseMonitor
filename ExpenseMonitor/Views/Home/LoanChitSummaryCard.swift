//
//  LoanChitSummaryCard.swift
//  ExpenseMonitor
//

import SwiftUI

struct LoanChitSummaryCard: View {
    let showLoans: Bool
    let loanDue: Double
    let loanPaid: Double

    let showCreditCards: Bool
    let creditCardDue: Double
    let creditCardPaid: Double

    let showChitFunds: Bool
    let chitDue: Double
    let chitPaid: Double

    @Environment(\.themeColors) private var themeColors
    @Environment(\.typography) private var typography

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Loans & Chit Funds")
                .font(typography.headline)

            VStack(spacing: 0) {
                if showLoans {
                    row(icon: "banknote.fill", label: "EMI", due: loanDue, paid: loanPaid)
                }
                if showCreditCards {
                    if showLoans { Divider() }
                    row(icon: "creditcard.fill", label: "Credit Card", due: creditCardDue, paid: creditCardPaid)
                }
                if showChitFunds {
                    if showLoans || showCreditCards { Divider() }
                    row(icon: "person.3.fill", label: "Chit Funds", due: chitDue, paid: chitPaid)
                }
            }
        }
        .padding()
        .background(themeColors.surface)
        .clipShape(RoundedRectangle(cornerRadius: 16))
        .overlay {
            RoundedRectangle(cornerRadius: 16)
                .strokeBorder(Color.primary.opacity(0.08), lineWidth: 1)
        }
    }

    private func row(icon: String, label: String, due: Double, paid: Double) -> some View {
        HStack {
            Image(systemName: icon)
                .font(.system(size: 14))
                .foregroundStyle(themeColors.accent)
                .frame(width: 28, height: 28)
                .background(themeColors.accent.opacity(0.15))
                .clipShape(Circle())

            Text(label)
                .font(typography.subheadline)
                .padding(.leading, 4)

            Spacer()

            VStack(alignment: .trailing, spacing: 2) {
                Text("Due \(due.currencyFormatted)")
                    .font(typography.caption)
                    .foregroundStyle(themeColors.expense)
                Text("Paid \(paid.currencyFormatted)")
                    .font(typography.caption)
                    .foregroundStyle(themeColors.income)
            }
        }
        .padding(.vertical, 8)
    }
}

#Preview {
    LoanChitSummaryCard(
        showLoans: true, loanDue: 12500, loanPaid: 12500,
        showCreditCards: true, creditCardDue: 4500, creditCardPaid: 0,
        showChitFunds: true, chitDue: 5000, chitPaid: 5000
    )
}
