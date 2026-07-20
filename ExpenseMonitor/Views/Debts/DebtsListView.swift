//
//  DebtsListView.swift
//  ExpenseMonitor
//

import SwiftUI
import SwiftData

struct DebtsListView: View {
    let repository: DebtRepository
    let isActive: Bool

    @State private var viewModel: DebtsViewModel
    @State private var isAddDebtPresented = false
    @State private var isCompletedDebtsPresented = false
    @State private var debtForDetail: Debt?
    @State private var filterDirection: DebtDirection?

    @Environment(\.themeColors) private var themeColors
    @Environment(\.typography) private var typography

    init(repository: DebtRepository, isActive: Bool) {
        self.repository = repository
        self.isActive = isActive
        _viewModel = State(initialValue: DebtsViewModel(repository: repository))
    }

    private var filteredDebts: [Debt] {
        guard let filterDirection else { return viewModel.activeDebts }
        return viewModel.activeDebts.filter { $0.direction == filterDirection }
    }

    var body: some View {
        VStack(spacing: 0) {
            HStack {
                Text("Debts")
                    .font(typography.title2Bold)
                Spacer()
                Button {
                    isCompletedDebtsPresented = true
                } label: {
                    Image(systemName: "clock.arrow.circlepath")
                        .font(.system(size: 20))
                        .foregroundStyle(themeColors.accent)
                        .frame(width: 44, height: 44)
                }
                Button {
                    isAddDebtPresented = true
                } label: {
                    Image(systemName: "plus")
                        .font(.system(size: 20))
                        .foregroundStyle(themeColors.accent)
                        .frame(width: 44, height: 44)
                }
            }
            .padding(.horizontal)
            .padding(.top)

            summaryRow

            HStack(spacing: 10) {
                Image(systemName: "magnifyingglass")
                    .foregroundStyle(.secondary)
                TextField("Search by name", text: $viewModel.searchText)
            }
            .padding(12)
            .background(themeColors.surfaceSecondary)
            .clipShape(RoundedRectangle(cornerRadius: 10))
            .padding(.horizontal)
            .padding(.bottom, 12)

            if filteredDebts.isEmpty {
                emptyStateView
            } else {
                ScrollView {
                    VStack(spacing: 12) {
                        ForEach(filteredDebts) { debt in
                            debtCard(debt) {
                                debtForDetail = debt
                            }
                        }
                    }
                    .padding()
                }
            }
        }
        .background(themeColors.background)
        .onAppear {
            viewModel.loadDebts()
        }
        .onChange(of: isActive) { _, newValue in
            if newValue {
                viewModel.loadDebts()
            }
        }
        .fullScreenCover(isPresented: $isAddDebtPresented) {
            AddDebtView(onSave: { viewModel.loadDebts() })
        }
        .fullScreenCover(item: $debtForDetail, onDismiss: { viewModel.loadDebts() }) { debt in
            DebtDetailView(debt: debt, onChange: { viewModel.loadDebts() })
        }
        .fullScreenCover(isPresented: $isCompletedDebtsPresented, onDismiss: { viewModel.loadDebts() }) {
            CompletedDebtsView(debts: viewModel.completedDebts, onChange: { viewModel.loadDebts() })
        }
    }

    private var summaryRow: some View {
        HStack(spacing: 12) {
            summaryPill(direction: .owedToMe, title: "OWED TO ME", total: viewModel.totalOwedToMe, color: themeColors.income)
            summaryPill(direction: .owedByMe, title: "OWED BY ME", total: viewModel.totalOwedByMe, color: themeColors.expense)
        }
        .padding(.horizontal)
        .padding(.bottom, 12)
    }

    private func summaryPill(direction: DebtDirection, title: String, total: Double, color: Color) -> some View {
        let isSelected = filterDirection == direction
        let isDimmed = filterDirection != nil && !isSelected
        return Button {
            withAnimation(.spring(response: 0.35, dampingFraction: 0.75)) {
                filterDirection = isSelected ? nil : direction
            }
        } label: {
            VStack(alignment: .leading, spacing: 4) {
                HStack {
                    HStack(spacing: 4) {
                        Image(systemName: direction.icon)
                            .foregroundStyle(color)
                            .font(.caption)
                        Text(title)
                            .font(typography.caption)
                    }
                    Spacer()
                    Image(systemName: "line.3.horizontal.decrease")
                        .font(.system(size: 10))
                        .foregroundStyle(.secondary)
                }
                Text(total.currencyFormatted)
                    .font(typography.headline)
            }
            .padding()
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(color.opacity(0.15))
            .clipShape(RoundedRectangle(cornerRadius: 12))
            .overlay {
                RoundedRectangle(cornerRadius: 12)
                    .strokeBorder(isSelected ? themeColors.accent : Color.clear, lineWidth: 2)
            }
            .opacity(isDimmed ? 0.5 : 1)
        }
        .buttonStyle(PressScaleButtonStyle())
    }

    private var emptyStateView: some View {
        VStack(spacing: 12) {
            Image(systemName: "person.2")
                .font(.system(size: 40))
                .foregroundStyle(.secondary)
            Text(filterDirection == nil ? "No debts yet" : "No debts here")
                .font(typography.headline)
            Text(filterDirection == nil ? "Tap the + button to add a debt you owe or are owed." : "Tap the pill again to see everything.")
                .font(typography.subheadline)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 32)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }

    private func debtCard(_ debt: Debt, onTap: @escaping () -> Void) -> some View {
        let color = debt.direction == .owedToMe ? themeColors.income : themeColors.expense
        return HStack(spacing: 12) {
            Image(systemName: debt.direction.icon)
                .foregroundStyle(themeColors.accent)
                .frame(width: 44, height: 44)
                .background(themeColors.accent.opacity(0.15))
                .clipShape(Circle())

            VStack(alignment: .leading, spacing: 2) {
                Text(debt.personName)
                    .font(typography.subheadline)
                if let note = debt.note, !note.isEmpty {
                    Text(note)
                        .font(typography.caption)
                        .foregroundStyle(.secondary)
                }
            }

            Spacer()

            VStack(alignment: .trailing, spacing: 2) {
                Text(debt.remainingAmount.currencyFormatted)
                    .font(typography.amount(size: 15))
                    .foregroundStyle(color)
                if debt.amountRepaid > 0 {
                    Text("of \(debt.amount.currencyFormatted)")
                        .font(typography.caption2)
                        .foregroundStyle(.secondary)
                }
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
        .onTapGesture(perform: onTap)
    }
}

private struct PressScaleButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .scaleEffect(configuration.isPressed ? 0.96 : 1.0)
            .animation(.spring(response: 0.3, dampingFraction: 0.6), value: configuration.isPressed)
    }
}

#Preview {
    let container = try! ModelContainer(
        for: Debt.self,
        configurations: ModelConfiguration(isStoredInMemoryOnly: true)
    )
    DebtsListView(
        repository: DefaultDebtRepository(modelContext: container.mainContext),
        isActive: true
    )
}
