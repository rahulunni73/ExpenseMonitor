//
//  PeriodChipStrip.swift
//  ExpenseMonitor
//

import SwiftUI

struct PeriodChipStrip: View {
    @Binding var granularity: ReportGranularity
    @Binding var referenceDate: Date
    @Binding var customRange: DateInterval?

    @State private var isCustomRangeSheetPresented = false

    @Environment(\.themeColors) private var themeColors
    @Environment(\.typography) private var typography

    /// How many periods back the chip strip scrolls to — wide enough to feel like real history,
    /// while "This Week/Month/Year" always stays the fixed, rightmost chip.
    private var chipCount: Int {
        switch granularity {
        case .week: return 26
        case .month: return 24
        case .year: return 10
        case .custom: return 0
        }
    }

    private var chipDates: [Date] {
        let calendar = Calendar.current
        let component = granularity.calendarComponent ?? .month
        let todayStart = calendar.dateInterval(of: component, for: Date())?.start ?? Date()
        return (0..<chipCount).reversed().compactMap { offset in
            calendar.date(byAdding: component, value: -offset, to: todayStart)
        }
    }

    private var selectedRangeText: String {
        guard let component = granularity.calendarComponent,
              let interval = Calendar.current.dateInterval(of: component, for: referenceDate) else { return "" }
        switch granularity {
        case .week:
            let end = Calendar.current.date(byAdding: .day, value: -1, to: interval.end) ?? interval.end
            return "\(interval.start.formatted(.dateTime.day().month(.abbreviated))) - \(end.formatted(.dateTime.day().month(.abbreviated)))"
        case .month:
            return referenceDate.formatted(.dateTime.month(.wide).year())
        case .year:
            return referenceDate.formatted(.dateTime.year())
        case .custom:
            return ""
        }
    }

    private var customRangeText: String {
        guard let customRange else { return "Select date range" }
        let end = Calendar.current.date(byAdding: .day, value: -1, to: customRange.end) ?? customRange.end
        return "\(customRange.start.formatted(.dateTime.day().month(.abbreviated).year())) – \(end.formatted(.dateTime.day().month(.abbreviated).year()))"
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            Picker("", selection: $granularity) {
                ForEach(ReportGranularity.allCases, id: \.self) { g in
                    Text(g.rawValue).tag(g)
                }
            }
            .pickerStyle(.segmented)

            if granularity == .custom {
                customRangeTrigger
            } else {
                ScrollViewReader { proxy in
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 8) {
                            ForEach(chipDates, id: \.self) { date in
                                chip(for: date)
                                    .id(date)
                            }
                        }
                    }
                    .onAppear {
                        scrollToSelected(proxy)
                    }
                    .onChange(of: granularity) { _, _ in
                        scrollToSelected(proxy)
                    }
                    .onChange(of: referenceDate) { _, _ in
                        scrollToSelected(proxy)
                    }
                }

                Text(selectedRangeText)
                    .font(typography.caption)
                    .foregroundStyle(.secondary)
            }
        }
        .sheet(isPresented: $isCustomRangeSheetPresented) {
            CustomDateRangeSheet(initialRange: customRange) { start, end in
                let calendar = Calendar.current
                let startOfDay = calendar.startOfDay(for: start)
                let endExclusive = calendar.date(byAdding: .day, value: 1, to: calendar.startOfDay(for: end)) ?? end
                customRange = DateInterval(start: startOfDay, end: endExclusive)
            }
        }
    }

    private var customRangeTrigger: some View {
        Button {
            isCustomRangeSheetPresented = true
        } label: {
            HStack {
                Text(customRangeText)
                    .font(typography.subheadline)
                    .foregroundStyle(.primary)
                Spacer()
                Image(systemName: "calendar")
                    .foregroundStyle(.secondary)
            }
            .padding(12)
            .background(themeColors.surfaceSecondary)
            .clipShape(RoundedRectangle(cornerRadius: 10))
        }
        .buttonStyle(.plain)
    }

    private func scrollToSelected(_ proxy: ScrollViewProxy) {
        let component = granularity.calendarComponent ?? .month
        let match = chipDates.first {
            Calendar.current.isDate($0, equalTo: referenceDate, toGranularity: component)
        }
        if let match {
            proxy.scrollTo(match, anchor: .trailing)
        }
    }

    private func chip(for date: Date) -> some View {
        let component = granularity.calendarComponent ?? .month
        let isSelected = Calendar.current.isDate(date, equalTo: referenceDate, toGranularity: component)
        return Text(label(for: date))
            .font(typography.subheadline(emphasized: isSelected))
            .foregroundStyle(isSelected ? .white : .primary)
            .padding(.horizontal, 14)
            .padding(.vertical, 8)
            .background(isSelected ? themeColors.accent : themeColors.surfaceSecondary)
            .clipShape(Capsule())
            .contentShape(Rectangle())
            .onTapGesture {
                referenceDate = date
            }
    }

    private func periodsAgo(_ date: Date) -> Int {
        let calendar = Calendar.current
        let component = granularity.calendarComponent ?? .month
        guard let todayStart = calendar.dateInterval(of: component, for: Date())?.start,
              let dateStart = calendar.dateInterval(of: component, for: date)?.start else { return 0 }
        return calendar.dateComponents([component], from: dateStart, to: todayStart).value(for: component) ?? 0
    }

    private func label(for date: Date) -> String {
        let ago = periodsAgo(date)
        switch granularity {
        case .week:
            switch ago {
            case 0: return "This Week"
            case 1: return "Last Week"
            default: return "Week \(Calendar.current.component(.weekOfYear, from: date))"
            }
        case .month:
            switch ago {
            case 0: return "This Month"
            case 1: return "Last Month"
            default: return date.formatted(.dateTime.month(.abbreviated).year())
            }
        case .year:
            switch ago {
            case 0: return "This Year"
            case 1: return "Last Year"
            default: return date.formatted(.dateTime.year())
            }
        case .custom:
            return ""
        }
    }
}

#Preview {
    PeriodChipStrip(granularity: .constant(.month), referenceDate: .constant(Date()), customRange: .constant(nil))
        .padding()
}
