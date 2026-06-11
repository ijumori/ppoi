import SwiftUI

struct CalendarView: View {
    @Environment(AppState.self) private var appState
    let visitedDates: Set<String>
    let journaledDates: Set<String>

    @State private var displayDate = Date()

    private var colors: ThemeColors {
        appState.store.selectedTheme.colors
    }
    private let columns = Array(repeating: GridItem(.flexible()), count: 7)
    private let weekdayLabels = ["月", "火", "水", "木", "金", "土", "日"]

    var body: some View {
        VStack(spacing: 8) {
            monthHeader
            weekdayHeader
            dateGrid
            legend
        }
    }

    // MARK: - Sub-views

    private var monthHeader: some View {
        HStack {
            Button {
                withAnimation(.easeInOut(duration: 0.2)) {
                    displayDate = jstCalendar.date(byAdding: .month, value: -1, to: displayDate) ?? displayDate
                }
            } label: {
                Image(systemName: "chevron.left")
                    .foregroundStyle(colors.accent)
            }

            Spacer()

            Text(monthTitle)
                .font(.subheadline.weight(.semibold))
                .foregroundStyle(colors.primaryText)
                .accessibilityAddTraits(.isHeader)

            Spacer()

            Button {
                withAnimation(.easeInOut(duration: 0.2)) {
                    let next = jstCalendar.date(byAdding: .month, value: 1, to: displayDate) ?? displayDate
                    if !isFutureMonth(next) { displayDate = next }
                }
            } label: {
                Image(systemName: "chevron.right")
                    .foregroundStyle(colors.accent)
                    .opacity(canGoForward ? 1 : 0.3)
            }
            .disabled(!canGoForward)
        }
        .padding(.horizontal)
    }

    private var weekdayHeader: some View {
        LazyVGrid(columns: columns, spacing: 4) {
            ForEach(weekdayLabels, id: \.self) { label in
                Text(label)
                    .font(.caption2)
                    .foregroundStyle(.secondary)
                    .accessibilityHidden(true)
            }
        }
        .padding(.horizontal)
    }

    private var dateGrid: some View {
        LazyVGrid(columns: columns, spacing: 4) {
            ForEach(0 ..< leadingEmptyCount, id: \.self) { _ in
                Color.clear.aspectRatio(1, contentMode: .fit)
            }
            ForEach(daysInMonth, id: \.self) { day in
                dayCell(day: day)
            }
        }
        .padding(.horizontal)
    }

    private var legend: some View {
        HStack(spacing: 16) {
            legendDot(color: colors.accent, label: "閲覧")
            legendDot(color: .yellow, label: "日記")
        }
        .font(.caption2)
        .padding(.top, 4)
        .accessibilityElement(children: .combine)
        .accessibilityLabel("凡例: 青点が閲覧済み、黄点が日記あり")
    }

    // MARK: - Day Cell

    private func dayCell(day: Int) -> some View {
        let ds = dateString(for: day)
        let isVisited = visitedDates.contains(ds)
        let isJournaled = journaledDates.contains(ds)
        let isToday = ds == todayString

        return ZStack {
            if isToday {
                Circle()
                    .fill(colors.accent.opacity(0.15))
            }
            VStack(spacing: 1) {
                Text("\(day)")
                    .font(.caption2.monospacedDigit())
                    .foregroundStyle(isToday ? colors.accent : colors.primaryText)

                HStack(spacing: 2) {
                    if isVisited {
                        Circle().fill(colors.accent).frame(width: 4, height: 4)
                    }
                    if isJournaled {
                        Circle().fill(Color.yellow).frame(width: 4, height: 4)
                    }
                }
                .frame(height: 5)
            }
        }
        .aspectRatio(1, contentMode: .fit)
        .accessibilityLabel(dayCellLabel(day: day, isVisited: isVisited, isJournaled: isJournaled))
    }

    private func legendDot(color: Color, label: String) -> some View {
        HStack(spacing: 4) {
            Circle().fill(color).frame(width: 6, height: 6)
            Text(label).foregroundStyle(.secondary)
        }
    }

    // MARK: - Calendar Helpers

    private var jstCalendar: Calendar {
        var cal = Calendar(identifier: .gregorian)
        cal.timeZone = TimeZone(identifier: "Asia/Tokyo") ?? .current
        cal.firstWeekday = 2 // Monday
        return cal
    }

    private var monthTitle: String {
        let fmt = DateFormatter()
        fmt.dateFormat = "yyyy年M月"
        fmt.locale = Locale(identifier: "ja_JP")
        fmt.timeZone = TimeZone(identifier: "Asia/Tokyo") ?? .current
        return fmt.string(from: displayDate)
    }

    private var todayString: String {
        DateFormatter.jstDate.string(from: Date())
    }

    private func isFutureMonth(_ date: Date) -> Bool {
        jstCalendar.compare(date, to: Date(), toGranularity: .month) == .orderedDescending
    }

    private var canGoForward: Bool {
        guard let nextMonth = jstCalendar.date(byAdding: .month, value: 1, to: displayDate) else { return false }
        return !isFutureMonth(nextMonth)
    }

    private var daysInMonth: [Int] {
        Array(jstCalendar.range(of: .day, in: .month, for: displayDate) ?? (1 ..< 31))
    }

    private var leadingEmptyCount: Int {
        let comps = jstCalendar.dateComponents([.year, .month], from: displayDate)
        guard let firstDay = jstCalendar.date(from: comps) else { return 0 }
        let weekday = jstCalendar.component(.weekday, from: firstDay)
        return (weekday - 2 + 7) % 7
    }

    private func dateString(for day: Int) -> String {
        var comps = jstCalendar.dateComponents([.year, .month], from: displayDate)
        comps.day = day
        guard let date = jstCalendar.date(from: comps) else { return "" }
        return DateFormatter.jstDate.string(from: date)
    }

    private func dayCellLabel(day: Int, isVisited: Bool, isJournaled: Bool) -> String {
        var parts = ["\(day)日"]
        if isVisited { parts.append("閲覧済み") }
        if isJournaled { parts.append("日記あり") }
        return parts.joined(separator: "、")
    }
}

#Preview {
    CalendarView(
        visitedDates: ["2026-06-05", "2026-06-07", "2026-06-10", "2026-06-11"],
        journaledDates: ["2026-06-07", "2026-06-11"]
    )
    .environment(AppState())
    .padding()
}
