//
//  YearInReviewView.swift
//  ExpenseMonitor
//

import SwiftUI

struct YearInReviewView: View {
    let review: YearInReview

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
                Text("\(String(review.year)) Year in Review")
                    .font(typography.headline)
                Spacer()
                Color.clear
                    .frame(width: 44, height: 44)
            }
            .padding()

            ScrollView {
                VStack(spacing: 16) {
                    heroCard

                    statCard(icon: "arrow.down.circle.fill", iconColor: themeColors.income, title: "Total Income", value: review.income.currencyFormatted)
                    statCard(icon: "arrow.up.circle.fill", iconColor: themeColors.expense, title: "Total Expenses", value: review.expense.currencyFormatted)
                    statCard(icon: "number", iconColor: themeColors.accent, title: "Transactions Logged", value: "\(review.transactionCount)")

                    if let topCategory = review.topCategory {
                        statCard(
                            icon: "tag.fill",
                            iconColor: themeColors.accent,
                            title: "Top Spending Category",
                            value: topCategory.category,
                            detail: "\(Int(topCategory.percent))% of your spending"
                        )
                    }

                    if let busiestMonth = review.busiestMonth {
                        statCard(
                            icon: "calendar",
                            iconColor: themeColors.accent,
                            title: "Busiest Spending Month",
                            value: busiestMonth.label,
                            detail: busiestMonth.amount.currencyFormatted
                        )
                    }

                    if let biggestExpense = review.biggestExpense {
                        statCard(
                            icon: "flame.fill",
                            iconColor: themeColors.expense,
                            title: "Biggest Single Expense",
                            value: biggestExpense.title,
                            detail: biggestExpense.amount.currencyFormatted
                        )
                    }

                    if review.totalEMIChitPaid > 0 {
                        statCard(
                            icon: "creditcard.fill",
                            iconColor: themeColors.accent,
                            title: "Paid Toward EMIs & Chit Funds",
                            value: review.totalEMIChitPaid.currencyFormatted
                        )
                    }
                }
                .padding()
            }
            .scrollIndicators(.hidden, axes: .vertical)
        }
        .background(themeColors.background)
    }

    private var heroCard: some View {
        VStack(spacing: 8) {
            Text(String(review.year))
                .font(typography.subheadline)
                .foregroundStyle(.secondary)
            Text("Net Savings")
                .font(typography.subheadline)
                .foregroundStyle(.secondary)
            Text(review.netSavings.currencyFormatted)
                .font(typography.amount(size: 40))
                .foregroundStyle(review.netSavings >= 0 ? themeColors.income : themeColors.expense)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 32)
        .background(themeColors.surface)
        .clipShape(RoundedRectangle(cornerRadius: 20))
        .overlay {
            RoundedRectangle(cornerRadius: 20)
                .strokeBorder(Color.primary.opacity(0.08), lineWidth: 1)
        }
    }

    private func statCard(icon: String, iconColor: Color, title: String, value: String, detail: String? = nil) -> some View {
        HStack(spacing: 14) {
            Image(systemName: icon)
                .font(.system(size: 20))
                .foregroundStyle(iconColor)
                .frame(width: 44, height: 44)
                .background(iconColor.opacity(0.15))
                .clipShape(Circle())

            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(typography.caption)
                    .foregroundStyle(.secondary)
                Text(value)
                    .font(typography.subheadlineBold)
                    .lineLimit(1)
                if let detail {
                    Text(detail)
                        .font(typography.caption)
                        .foregroundStyle(.secondary)
                }
            }

            Spacer()
        }
        .padding()
        .background(themeColors.surface)
        .clipShape(RoundedRectangle(cornerRadius: 16))
        .overlay {
            RoundedRectangle(cornerRadius: 16)
                .strokeBorder(Color.primary.opacity(0.08), lineWidth: 1)
        }
    }
}

#Preview {
    YearInReviewView(
        review: YearInReview(
            year: 2026,
            income: 660000,
            expense: 412500,
            netSavings: 247500,
            transactionCount: 214,
            topCategory: CategoryBreakdown(category: "Food & Dining", percent: 28, color: .orange),
            busiestMonth: ("December", 58200),
            biggestExpense: Expense(id: "preview", title: "Flight Booking", amount: 24500, category: "Shopping & Personal Care"),
            totalEMIChitPaid: 96000
        )
    )
}
