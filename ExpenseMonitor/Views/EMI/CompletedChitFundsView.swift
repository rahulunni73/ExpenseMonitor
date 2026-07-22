//
//  CompletedChitFundsView.swift
//  ExpenseMonitor
//

import SwiftUI

struct CompletedChitFundsView: View {
    let chitFunds: [ChitFund]
    var onChange: (() -> Void)? = nil

    @State private var chitFundForDetail: ChitFund?

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
                Text("Completed Chit Funds")
                    .font(typography.headline)
                Spacer()
                Color.clear
                    .frame(width: 44, height: 44)
            }
            .padding()

            if chitFunds.isEmpty {
                VStack(spacing: 12) {
                    Image(systemName: "checkmark.circle")
                        .font(.system(size: 40))
                        .foregroundStyle(.secondary)
                    Text("No completed chit funds yet")
                        .font(typography.headline)
                    Text("Chit funds move here once every contribution is paid.")
                        .font(typography.subheadline)
                        .foregroundStyle(.secondary)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 32)
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            } else {
                ScrollView {
                    VStack(spacing: 12) {
                        ForEach(chitFunds) { chitFund in
                            row(chitFund)
                                .onTapGesture {
                                    chitFundForDetail = chitFund
                                }
                        }
                    }
                    .padding()
                }
            }
        }
        .background(themeColors.background)
        .fullScreenCover(item: $chitFundForDetail, onDismiss: onChange) { chitFund in
            ChitFundDetailView(chitFund: chitFund, onChange: onChange)
        }
    }

    private func row(_ chitFund: ChitFund) -> some View {
        HStack(spacing: 12) {
            Image(systemName: "person.3.fill")
                .foregroundStyle(themeColors.accent)
                .frame(width: 44, height: 44)
                .background(themeColors.accent.opacity(0.15))
                .clipShape(Circle())

            VStack(alignment: .leading, spacing: 2) {
                Text(chitFund.name)
                    .font(typography.subheadline)
                if let organizer = chitFund.organizer, !organizer.isEmpty {
                    Text(organizer)
                        .font(typography.caption)
                        .foregroundStyle(.secondary)
                }
            }

            Spacer()

            VStack(alignment: .trailing, spacing: 2) {
                Text(chitFund.totalContributed.currencyFormatted)
                    .font(typography.amount(size: 15))
                Text("Completed \(chitFund.endDate.formatted(.dateTime.day().month(.abbreviated)))")
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
    CompletedChitFundsView(chitFunds: [
        ChitFund(id: "1", name: "Office Chit", organizer: "Priya", monthlyContribution: 2000, chitValue: 24000, startDate: Date(), numberOfMonths: 12, paidContributions: Array(1...12))
    ])
}
