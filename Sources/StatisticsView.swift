import SwiftUI
import CoreData
import Charts

struct StatisticsView: View {
    @FetchRequest(sortDescriptors: []) private var allHabits: FetchedResults<Habit>
    @State private var showArchived: Bool = false
    
    private var habits: [Habit] {
        if showArchived {
            return Array(allHabits)
        } else {
            return allHabits.filter { !$0.isArchived }
        }
    }
    @FetchRequest(
        sortDescriptors: []
    ) private var checkins: FetchedResults<Checkin>
    @EnvironmentObject private var appSettings: AppSettings
    
    @State private var weekOffset: Int = 0
    @State private var selectedTab: String = "Weekly"
    @Namespace private var animationNamespace
    private var calendar: Calendar { appSettings.customCalendar }
    
    @State private var currentMonthDate = Date()
    @State private var currentYear = Calendar.current.component(.year, from: Date())
    
    // Computed properties for date range
    private var targetDate: Date {
        calendar.date(byAdding: .weekOfYear, value: weekOffset, to: Date()) ?? Date()
    }
    
    private var weekInterval: DateInterval {
        calendar.dateInterval(of: .weekOfYear, for: targetDate)!
    }
    
    private var weekDays: [Date] {
        var days: [Date] = []
        let startDate = weekInterval.start
        for i in 0..<7 {
            if let date = calendar.date(byAdding: .day, value: i, to: startDate) {
                days.append(date)
            }
        }
        return days
    }
    
    private var dateRangeString: String {
        let df = DateFormatter()
        df.locale = Locale(identifier: appSettings.resolvedLanguage.localeIdentifier)
        df.setLocalizedDateFormatFromTemplate("MMMd")
        let start = df.string(from: weekDays.first ?? Date())
        let end = df.string(from: weekDays.last ?? Date())
        return "\(start) - \(end)"
    }
    
    private var monthYearString: String {
        let df = DateFormatter()
        df.locale = Locale(identifier: appSettings.resolvedLanguage.localeIdentifier)
        df.setLocalizedDateFormatFromTemplate("yMMMM")
        return df.string(from: currentMonthDate)
    }
    
    // Calculations for the 4 stat cards (based on current week)
    private var allTimeCheckins: [Checkin] {
        return Array(checkins)
    }
    
    private var currentWeekCheckins: [Checkin] {
        let df = DateFormatter()
        df.dateFormat = "yyyy-MM-dd"
        let weekDateStrings = Set(weekDays.map { df.string(from: $0) })
        return checkins.filter { checkin in
            weekDateStrings.contains(checkin.dateString)
        }
    }
    
    private var currentPeriodCheckins: [Checkin] {
        switch selectedTab {
        case "Weekly":
            return currentWeekCheckins
        case "Monthly":
            let df = DateFormatter()
            df.dateFormat = "yyyy-MM"
            let prefix = df.string(from: currentMonthDate)
            return checkins.filter { $0.dateString.hasPrefix(prefix) }
        case "Yearly":
            return checkins.filter { $0.dateString.hasPrefix("\(currentYear)") }
        case "All":
            return Array(checkins)
        default:
            return []
        }
    }
    
    private var metPercentage: Int {
        if habits.isEmpty { return 0 }
        let totalPossible = habits.count * 7
        
        var completed = 0
        for habit in habits {
            for day in weekDays {
                if isHabitChecked(habit: habit, date: day) {
                    completed += 1
                }
            }
        }
        return Int((Double(completed) / Double(totalPossible)) * 100)
    }
    
    private var bestDay: String {
        var dayCounts: [Int: Int] = [:] // day index (0-6) to count
        for habit in habits {
            for (index, day) in weekDays.enumerated() {
                if isHabitChecked(habit: habit, date: day) {
                    dayCounts[index, default: 0] += 1
                }
            }
        }
        if let max = dayCounts.max(by: { $0.value < $1.value }) {
            let df = DateFormatter()
            df.dateFormat = "EEE"
            return String(df.string(from: weekDays[max.key]).prefix(3))
        }
        return "-"
    }
    
    private var totalDone: Int {
        var completed = 0
        for habit in habits {
            for day in weekDays {
                if isHabitChecked(habit: habit, date: day) {
                    completed += 1
                }
            }
        }
        return completed
    }
    
    private var currentStreak: Int {
        var maxS = 0
        for habit in habits {
            let s = calculateStreak(for: habit)
            if s > maxS { maxS = s }
        }
        return maxS
    }
    
    private func calculateStreak(for habit: Habit) -> Int {
        return habit.currentStreak
    }
    
    private func isHabitChecked(habit: Habit, date: Date) -> Bool {
        let dateString = SharedFormatters.dateString(from: date)
        return habit.checkinDates.contains(dateString)
    }
    
    private func getNarrowDayString(for date: Date) -> String {
        let df = DateFormatter()
        df.locale = Locale(identifier: appSettings.resolvedLanguage.localeIdentifier)
        df.dateFormat = "EEEEE"
        return df.string(from: date)
    }
    
    var body: some View {
        ScrollView(showsIndicators: false) {
            let _ = appSettings.firstWeekday // Force dependency
            VStack(spacing: 10) {
                    
                    // Title
                    HStack(alignment: .bottom) {
                        VStack(alignment: .leading, spacing: 4) {
                            Text(L10n.stats.tr(appSettings.resolvedLanguage))
                                .display()
                                .foregroundColor(DS.primary)
                            Text(L10n.aDetailedLookAtYourJourney.tr(appSettings.resolvedLanguage))
                                .bodyLg()
                                .foregroundColor(DS.onSurfaceVariant)
                        }
                        
                        Spacer()
                        
                        Button(action: { showArchived.toggle() }) {
                            Text(showArchived ? L10n.hideArchived.tr(appSettings.resolvedLanguage) : L10n.showArchived.tr(appSettings.resolvedLanguage))
                                .font(.system(size: 12, weight: .bold))
                                .foregroundColor(showArchived ? DS.onPrimary : DS.primary)
                                .padding(.horizontal, 12)
                                .padding(.vertical, 6)
                                .background(showArchived ? DS.primary : Color.clear)
                                .overlay(
                                    Capsule()
                                        .stroke(DS.primary, lineWidth: showArchived ? 0 : 1)
                                )
                                .clipShape(Capsule())
                        }
                        .padding(.bottom, 2)
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.top, DS.spacingS)
                    .padding(.bottom, 0)
                    .padding(.horizontal, 16)
                    
                    // Tabs
                    HStack(spacing: 24) {
                        ForEach(["Weekly", "Monthly", "Yearly", "All"], id: \.self) { tab in
                            Button(action: {
                                withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                                    selectedTab = tab
                                }
                            }) {
                                VStack(spacing: 6) {
                                    Text(tab.tr(appSettings.resolvedLanguage))
                                        .font(.system(size: 18, weight: selectedTab == tab ? .bold : .medium))
                                        .lineLimit(1)
                                        .minimumScaleFactor(0.5)
                                        .foregroundColor(selectedTab == tab ? DS.onSurface : DS.onSurfaceVariant)
                                    
                                    if selectedTab == tab {
                                        Capsule()
                                            .fill(DS.primary)
                                            .frame(height: 3)
                                            .matchedGeometryEffect(id: "tab_underline", in: animationNamespace)
                                    } else {
                                        Capsule()
                                            .fill(Color.clear)
                                            .frame(height: 3)
                                    }
                                }
                                .padding(.vertical, 8)
                            }
                        }
                        Spacer()
                    }
                    .padding(.horizontal, 16)
                    .padding(.top, 4)
                    
                    if selectedTab == "Weekly" {
                        // Date Selector
                        HStack {
                            Button(action: { withAnimation { weekOffset -= 1 } }) {
                                Image(systemName: "chevron.left")
                                    .frame(width: 44, height: 44)
                                    .background(DS.surface.opacity(0.8))
                                    .clipShape(Circle())
                                    .foregroundColor(DS.onSurface)
                            }
                            
                            Spacer()
                            
                            HStack(spacing: 8) {
                                Image(systemName: "calendar")
                                    .foregroundColor(DS.primary)
                                Text(dateRangeString)
                                    .font(.system(size: 16, weight: .bold))
                                    .foregroundColor(DS.onSurface)
                            }
                            .padding(.horizontal, 20)
                            .padding(.vertical, 12)
                            .background(DS.surface.opacity(0.8))
                            .clipShape(Capsule())
                            
                            Spacer()
                            
                            Button(action: { withAnimation { weekOffset += 1 } }) {
                                Image(systemName: "chevron.right")
                                    .frame(width: 44, height: 44)
                                    .background(DS.surface.opacity(0.8))
                                    .clipShape(Circle())
                                    .foregroundColor(DS.onSurface)
                            }
                        }
                        .padding(.horizontal, 16)
                        

                        // Donut Chart Card
                        DonutChartCard(
                            habits: habits,
                            periodCheckins: currentPeriodCheckins,
                            appSettings: appSettings
                        )
                        
                        // Weekly Grid Card
                        VStack(alignment: .leading, spacing: 10) {
                            Label {
                                Text(L10n.weeklyView.tr(appSettings.resolvedLanguage))
                                    .foregroundColor(DS.onSurface)
                            } icon: {
                                Image(systemName: "square.grid.2x2.fill")
                                    .foregroundColor(DS.primary)
                            }
                            .font(.system(size: 16, weight: .semibold))
                            
                            Spacer()
                            
                            if habits.isEmpty {
                                Text(L10n.noHabitsFound.tr(appSettings.resolvedLanguage))
                                    .foregroundColor(DS.onSurfaceVariant)
                                    .frame(maxWidth: .infinity, alignment: .center)
                                    .padding(.vertical, DS.spacingL)
                            } else {
                                VStack(spacing: 8) {
                                    // Day headers
                                    HStack(spacing: 6) {
                                        Spacer()
                                            .frame(maxWidth: .infinity, alignment: .leading)
                                        
                                        ForEach(weekDays, id: \.self) { date in
                                            Text(getNarrowDayString(for: date))
                                                .font(.system(size: 12, weight: .bold))
                                                .foregroundColor(DS.onSurfaceVariant)
                                                .frame(width: 22)
                                        }
                                    }
                                    
                                    // Habit rows
                                    ForEach(habits) { habit in
                                        HStack(spacing: 6) {
                                            HStack(spacing: 8) {
                                                Image(systemName: habit.icon)
                                                    .foregroundColor(Color(hex: habit.color))
                                                    .font(.system(size: 16))
                                                
                                                Text(habit.name)
                                                    .font(.system(size: 14, weight: .semibold))
                                                    .foregroundColor(DS.onSurface)
                                                    .lineLimit(1)
                                                    .minimumScaleFactor(0.8)
                                                
                                                Spacer()
                                            }
                                            .frame(maxWidth: .infinity, alignment: .leading)
                                            
                                            ForEach(weekDays, id: \.self) { date in
                                                let isChecked = isHabitChecked(habit: habit, date: date)
                                                RoundedRectangle(cornerRadius: 6)
                                                    .fill(isChecked ? Color(hex: habit.color) : DS.uncheckedPlaceholder)
                                                    .frame(width: 22, height: 22)
                                            }
                                        }
                                    }
                                }
                            }
                        }
                        .padding(24)
                        .background(DS.surface.opacity(0.8))
                        .clipShape(RoundedRectangle(cornerRadius: 24, style: .continuous))
                        .padding(.horizontal, 20)
                    } else {
                        if selectedTab == "Monthly" {
                            // Monthly Date Selector
                            HStack {
                                Button(action: { withAnimation { currentMonthDate = calendar.date(byAdding: .month, value: -1, to: currentMonthDate) ?? currentMonthDate } }) {
                                    Image(systemName: "chevron.left")
                                        .frame(width: 44, height: 44)
                                        .background(DS.surface.opacity(0.8))
                                        .clipShape(Circle())
                                        .foregroundColor(DS.onSurface)
                                }
                                
                                Spacer()
                                
                                HStack(spacing: 8) {
                                    Image(systemName: "calendar")
                                        .foregroundColor(DS.primary)
                                    Text(monthYearString)
                                        .font(.system(size: 16, weight: .bold))
                                        .foregroundColor(DS.onSurface)
                                }
                                .padding(.horizontal, 20)
                                .padding(.vertical, 12)
                                .background(DS.surface.opacity(0.8))
                                .clipShape(Capsule())
                                
                                Spacer()
                                
                                Button(action: { withAnimation { currentMonthDate = calendar.date(byAdding: .month, value: 1, to: currentMonthDate) ?? currentMonthDate } }) {
                                    Image(systemName: "chevron.right")
                                        .frame(width: 44, height: 44)
                                        .background(DS.surface.opacity(0.8))
                                        .clipShape(Circle())
                                        .foregroundColor(DS.onSurface)
                                }
                            }
                            .padding(.horizontal, 16)
                            
                            DonutChartCard(
                                habits: habits,
                                periodCheckins: currentPeriodCheckins,
                                appSettings: appSettings
                            )
                            
                            MonthGridCard(habits: habits, checkins: Array(checkins), appSettings: appSettings, currentMonthDate: $currentMonthDate)
                        } else if selectedTab == "Yearly" {
                            // Yearly Date Selector
                            HStack {
                                Button(action: { withAnimation { currentYear -= 1 } }) {
                                    Image(systemName: "chevron.left")
                                        .frame(width: 44, height: 44)
                                        .background(DS.surface.opacity(0.8))
                                        .clipShape(Circle())
                                        .foregroundColor(DS.onSurface)
                                }
                                
                                Spacer()
                                
                                HStack(spacing: 8) {
                                    Image(systemName: "calendar")
                                        .foregroundColor(DS.primary)
                                    Text("\(currentYear)")
                                        .font(.system(size: 16, weight: .bold))
                                        .foregroundColor(DS.onSurface)
                                }
                                .padding(.horizontal, 20)
                                .padding(.vertical, 12)
                                .background(DS.surface.opacity(0.8))
                                .clipShape(Capsule())
                                
                                Spacer()
                                
                                Button(action: { withAnimation { currentYear += 1 } }) {
                                    Image(systemName: "chevron.right")
                                        .frame(width: 44, height: 44)
                                        .background(DS.surface.opacity(0.8))
                                        .clipShape(Circle())
                                        .foregroundColor(DS.onSurface)
                                }
                            }
                            .padding(.horizontal, 16)
                            
                            DonutChartCard(
                                habits: habits,
                                periodCheckins: currentPeriodCheckins,
                                appSettings: appSettings
                            )
                            
                            YearChartCard(habits: habits, checkins: Array(checkins), appSettings: appSettings, currentYear: $currentYear)
                        } else if selectedTab == "All" {
                            DonutChartCard(
                                habits: habits,
                                periodCheckins: currentPeriodCheckins,
                                appSettings: appSettings
                            )
                            
                            AllChartCard(habits: habits, checkins: Array(checkins), appSettings: appSettings)
                        }
                    }
                    
                    Spacer().frame(height: 120) // Bottom tab bar padding
                }
        }
        .background(AmbientBackground())
    }
}

struct StatSmallCard: View {
    let icon: String
    let iconColor: Color
    let value: String
    let label: String
    
    var body: some View {
        VStack(spacing: 4) {
            Image(systemName: icon)
                .font(.system(size: 14))
                .foregroundColor(iconColor)
            
            Text(value)
                .font(.system(size: 14, weight: .bold))
                .foregroundColor(.black)
                .lineLimit(1)
                .minimumScaleFactor(0.5)
            
            Text(label)
                .font(.system(size: 10, weight: .medium))
                .foregroundColor(.gray)
                .lineLimit(1)
                .minimumScaleFactor(0.5)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 8)
        .padding(.horizontal, 4)
        .background(DS.surface.opacity(0.8))
        .clipShape(RoundedRectangle(cornerRadius: 10, style: .continuous))
    }
}

struct MonthGridCard: View {
    let habits: [Habit]
    let checkins: [Checkin]
    @ObservedObject var appSettings: AppSettings
    @Binding var currentMonthDate: Date
    @State private var selectedDay: Int? = nil
    
    private var calendar: Calendar { appSettings.customCalendar }
    
    private var monthYearString: String {
        let df = DateFormatter()
        df.locale = Locale(identifier: appSettings.resolvedLanguage.localeIdentifier)
        df.setLocalizedDateFormatFromTemplate("yMMMM")
        return df.string(from: currentMonthDate)
    }
    
    private var daysInMonth: [Int] {
        guard let range = calendar.range(of: .day, in: .month, for: currentMonthDate) else { return [] }
        return Array(range)
    }
    
    private var firstWeekday: Int {
        var components = calendar.dateComponents([.year, .month], from: currentMonthDate)
        components.day = 1
        guard let firstDay = calendar.date(from: components) else { return 0 }
        let wd = calendar.component(.weekday, from: firstDay)
        let first = appSettings.firstWeekday
        var offset = wd - first
        if offset < 0 { offset += 7 }
        return offset
    }
    
    private var weekdaysShort: [String] {
        let isChinese = appSettings.resolvedLanguage == .chinese || appSettings.resolvedLanguage == .traditionalChinese
        let sunFirst = appSettings.firstWeekday == 1
        if isChinese {
            return sunFirst ? ["日", "一", "二", "三", "四", "五", "六"] : ["一", "二", "三", "四", "五", "六", "日"]
        } else {
            return sunFirst ? ["Sun", "Mon", "Tue", "Wed", "Thu", "Fri", "Sat"] : ["Mon", "Tue", "Wed", "Thu", "Fri", "Sat", "Sun"]
        }
    }
    
    private func habitsOn(day: Int) -> [Habit] {
        var components = calendar.dateComponents([.year, .month], from: currentMonthDate)
        components.day = day
        guard let date = calendar.date(from: components) else { return [] }
        
        let dateString = SharedFormatters.dateString(from: date)
        
        var completed: [Habit] = []
        for habit in habits {
            if habit.checkinDates.contains(dateString) {
                completed.append(habit)
            }
        }
        return completed
    }
    
    private func checkinFor(habit: Habit, onDate dateString: String) -> Checkin? {
        for item in checkins {
            if item.dateString == dateString {
                if let hid = item.habit?.id, hid == habit.id {
                    return item
                }
                if let hChecks = habit.checkinsArray as? [Checkin] {
                    for hc in hChecks {
                        if hc.id == item.id {
                            return item
                        }
                    }
                }
            }
        }
        if let hChecks = habit.checkinsArray as? [Checkin] {
            for hc in hChecks {
                if hc.dateString == dateString {
                    return hc
                }
            }
        }
        return nil
    }
    
    @ViewBuilder
    private func habitRowView(habit: Habit, dateString: String) -> some View {
        let checkin: Checkin? = checkinFor(habit: habit, onDate: dateString)
        let timeText: String = {
            if let c = checkin {
                let tf = DateFormatter()
                tf.dateFormat = "HH:mm"
                return tf.string(from: c.timestamp)
            } else {
                return L10n.checkedIn.tr(appSettings.resolvedLanguage)
            }
        }()
        
        HStack(spacing: 12) {
            ZStack {
                Circle()
                    .fill(Color(hex: habit.color).opacity(0.15))
                    .frame(width: 32, height: 32)
                Image(systemName: habit.icon)
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundColor(Color(hex: habit.color))
            }
            
            Text(habit.name)
                .font(.system(size: 14, weight: .semibold))
                .foregroundColor(DS.onSurface)
            
            Spacer()
            
            HStack(spacing: 4) {
                Image(systemName: "clock")
                    .font(.system(size: 11, weight: .semibold))
                Text(timeText)
                    .font(.system(size: 13, weight: .bold))
            }
            .foregroundColor(Color(hex: habit.color))
            .padding(.horizontal, 10)
            .padding(.vertical, 5)
            .background(Color(hex: habit.color).opacity(0.12))
            .clipShape(Capsule())
        }
        .padding(10)
        .background(DS.surface)
        .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
    }
    
    @ViewBuilder
    private func dayCellView(day: Int, completedHabits: [Habit], isSelected: Bool) -> some View {
        Button(action: {
            UIImpactFeedbackGenerator(style: .light).impactOccurred()
            withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                selectedDay = isSelected ? nil : day
            }
        }) {
            VStack(spacing: 4) {
                Text("\(day)")
                    .font(.system(size: 14, weight: isSelected ? .bold : .medium))
                    .foregroundColor(isSelected ? .white : DS.onSurface)
                
                HStack(spacing: 3) {
                    ForEach(completedHabits.prefix(3)) { h in
                        Circle()
                            .fill(isSelected ? .white : Color(hex: h.color))
                            .frame(width: 4, height: 4)
                    }
                }
                .frame(height: 4)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 8)
            .background(
                ZStack {
                    if isSelected {
                        RoundedRectangle(cornerRadius: 12, style: .continuous)
                            .fill(DS.primary)
                    } else if !completedHabits.isEmpty {
                        RoundedRectangle(cornerRadius: 12, style: .continuous)
                            .fill(DS.primaryContainer.opacity(0.4))
                    }
                }
            )
        }
        .buttonStyle(PlainButtonStyle())
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            Label {
                Text(L10n.monthlyView.tr(appSettings.resolvedLanguage))
                    .foregroundColor(DS.onSurface)
            } icon: {
                Image(systemName: "square.grid.2x2.fill")
                    .foregroundColor(DS.primary)
            }
            .font(.system(size: 16, weight: .semibold))
            
            Spacer()
            
            // Grid
            VStack(spacing: 12) {
                // Weekday headers
                HStack(spacing: 0) {
                    ForEach(weekdaysShort, id: \.self) { wd in
                        Text(wd)
                            .font(.system(size: 13, weight: .regular))
                            .foregroundColor(DS.onSurfaceVariant)
                            .frame(maxWidth: .infinity)
                    }
                }
                
                // Days
                let days = daysInMonth
                let offset = firstWeekday
                let totalSlots = days.count + offset
                let rows = Int(ceil(Double(totalSlots) / 7.0))
                
                ForEach(0..<rows, id: \.self) { row in
                    HStack(spacing: 0) {
                        ForEach(0..<7, id: \.self) { col in
                            let slot = row * 7 + col
                            if slot >= offset && (slot - offset) < days.count {
                                let day = days[slot - offset]
                                let completedHabits = habitsOn(day: day)
                                let isSelected = (selectedDay == day)
                                
                                dayCellView(day: day, completedHabits: completedHabits, isSelected: isSelected)
                            } else {
                                Color.clear
                                    .frame(maxWidth: .infinity)
                                    .padding(.vertical, 8)
                            }
                        }
                    }
                }
            }
            
            // Selected Day Details
            if let day = selectedDay {
                VStack(alignment: .leading, spacing: 12) {
                    Divider()
                    let selectedDateText: String = {
                        var comps = appSettings.customCalendar.dateComponents([.year, .month], from: currentMonthDate)
                        comps.day = day
                        if let d = appSettings.customCalendar.date(from: comps) {
                            let df = DateFormatter()
                            df.locale = Locale(identifier: appSettings.resolvedLanguage.localeIdentifier)
                            df.setLocalizedDateFormatFromTemplate("yyyyMMMMd")
                            return df.string(from: d)
                        }
                        return ""
                    }()
                    
                    Text(selectedDateText)
                        .font(.system(size: 14, weight: .bold))
                        .foregroundColor(DS.onSurface)
                    
                    let completed = habitsOn(day: day)
                    if completed.isEmpty {
                        Text(L10n.noCheckInsOnThisDay.tr(appSettings.resolvedLanguage))
                            .font(.system(size: 13, weight: .medium))
                            .foregroundColor(DS.onSurfaceVariant)
                            .padding(.vertical, 8)
                    } else {
                        let targetDateString: String = {
                            var components = calendar.dateComponents([.year, .month], from: currentMonthDate)
                            components.day = day
                            guard let date = calendar.date(from: components) else { return "" }
                            return SharedFormatters.dateString(from: date)
                        }()
                        
                        VStack(spacing: 8) {
                            ForEach(completed) { h in
                                habitRowView(habit: h, dateString: targetDateString)
                            }
                        }
                    }
                }
                .transition(.opacity.combined(with: .move(edge: .top)))
            }
        }
        .padding(24)
        .background(DS.surface.opacity(0.8))
        .background(.ultraThinMaterial)
        .clipShape(RoundedRectangle(cornerRadius: 24, style: .continuous))
        .overlay(RoundedRectangle(cornerRadius: 24, style: .continuous).stroke(DS.outline, lineWidth: 1))
        .padding(.horizontal, 20)
    }
}

struct ChartDataPoint: Identifiable {
    let id = UUID()
    let group: String
    let habitName: String
    let color: Color
    let count: Int
}

struct YearChartCard: View {
    let habits: [Habit]
    let checkins: [Checkin]
    @ObservedObject var appSettings: AppSettings
    @Binding var currentYear: Int
    
    private var chartData: [ChartDataPoint] {
        var points: [ChartDataPoint] = []
        let habitSets = habits.map { ($0, $0.checkinDates) }
        
        for m in 1...12 {
            let monthLabel = "\(m)月"
            let prefix = String(format: "%04d-%02d", currentYear, m)
            
            for (habit, dates) in habitSets {
                var uniqueDays = 0
                for d in dates {
                    if d.hasPrefix(prefix) { uniqueDays += 1 }
                }
                if uniqueDays > 0 {
                    points.append(ChartDataPoint(group: monthLabel, habitName: habit.name, color: Color(hex: habit.color), count: uniqueDays))
                }
            }
        }
        return points
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: DS.spacingL) {
            Label {
                Text(L10n.yearlyView.tr(appSettings.resolvedLanguage))
                    .foregroundColor(DS.onSurface)
            } icon: {
                Image(systemName: "square.grid.2x2.fill")
                    .foregroundColor(DS.primary)
            }
            .font(.system(size: 16, weight: .semibold))
            
            Spacer()
            
            if chartData.isEmpty {
                Text(L10n.noData.tr(appSettings.resolvedLanguage))
                    .foregroundColor(DS.onSurfaceVariant)
                    .frame(maxWidth: .infinity, alignment: .center)
                    .padding(.vertical, 40)
            } else {
                Chart(chartData) { point in
                    BarMark(
                        x: .value("Month", point.group),
                        y: .value("Days", point.count)
                    )
                    .foregroundStyle(point.color.gradient)
                    .cornerRadius(4)
                }
                .chartLegend(.hidden)
                .chartXAxis {
                    AxisMarks { _ in
                        AxisValueLabel()
                            .foregroundStyle(DS.onSurfaceVariant)
                            .font(.system(size: 12, weight: .medium))
                    }
                }
                .chartYAxis {
                    AxisMarks(position: .leading) { _ in
                        AxisGridLine(stroke: StrokeStyle(lineWidth: 1, dash: [4]))
                            .foregroundStyle(DS.outlineVariant.opacity(0.5))
                        AxisValueLabel()
                            .foregroundStyle(DS.onSurfaceVariant)
                            .font(.system(size: 12, weight: .medium))
                    }
                }
                .frame(height: 220)
            }
            

        }
        .padding(24)
        .background(DS.surface.opacity(0.8))
        .clipShape(RoundedRectangle(cornerRadius: 24, style: .continuous))
        .padding(.horizontal, 20)
    }
}

struct AllChartCard: View {
    let habits: [Habit]
    let checkins: [Checkin]
    @ObservedObject var appSettings: AppSettings
    
    private var chartData: [ChartDataPoint] {
        var points: [ChartDataPoint] = []
        let habitSets = habits.map { ($0, $0.checkinDates) }
        
        var allYearsSet = Set<String>()
        for (_, dates) in habitSets {
            for d in dates {
                allYearsSet.insert(String(d.prefix(4)))
            }
        }
        let years = Array(allYearsSet).sorted()
        
        for y in years {
            for (habit, dates) in habitSets {
                var uniqueDays = 0
                for d in dates {
                    if d.hasPrefix(y) { uniqueDays += 1 }
                }
                if uniqueDays > 0 {
                    points.append(ChartDataPoint(group: y, habitName: habit.name, color: Color(hex: habit.color), count: uniqueDays))
                }
            }
        }
        return points
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: DS.spacingL) {
            Label {
                Text(L10n.allView.tr(appSettings.resolvedLanguage))
                    .foregroundColor(DS.onSurface)
            } icon: {
                Image(systemName: "square.grid.2x2.fill")
                    .foregroundColor(DS.primary)
            }
            .font(.system(size: 16, weight: .semibold))
            
            Spacer()
            
            if chartData.isEmpty {
                Text(L10n.noData.tr(appSettings.resolvedLanguage))
                    .foregroundColor(DS.onSurfaceVariant)
                    .frame(maxWidth: .infinity, alignment: .center)
                    .padding(.vertical, 40)
            } else {
                Chart(chartData) { point in
                    BarMark(
                        x: .value("Year", point.group),
                        y: .value("Days", point.count)
                    )
                    .foregroundStyle(point.color.gradient)
                    .cornerRadius(4)
                }
                .chartLegend(.hidden)
                .chartXAxis {
                    AxisMarks { _ in
                        AxisValueLabel()
                            .foregroundStyle(DS.onSurfaceVariant)
                            .font(.system(size: 12, weight: .medium))
                    }
                }
                .chartYAxis {
                    AxisMarks(position: .leading) { _ in
                        AxisGridLine(stroke: StrokeStyle(lineWidth: 1, dash: [4]))
                            .foregroundStyle(DS.outlineVariant.opacity(0.5))
                        AxisValueLabel()
                            .foregroundStyle(DS.onSurfaceVariant)
                            .font(.system(size: 12, weight: .medium))
                    }
                }
                .frame(height: 220)
            }
        }
        .padding(16)
        .background(DS.surface.opacity(0.8))
        .clipShape(RoundedRectangle(cornerRadius: 24, style: .continuous))
        .padding(.horizontal, 20)
    }
}

struct HabitCountItem: Identifiable {
    let id = UUID()
    let habit: Habit
    let value: Double
    let checkinCount: Int
    func displayString(lang: AppLanguage) -> String {
        if habit.goalType == "amount" {
            let formatted = value.truncatingRemainder(dividingBy: 1) == 0 ? String(format: "%.0f", value) : String(format: "%.1f", value)
            return "\(formatted)\(habit.amountUnit.tr(lang))"
        } else {
            return "\(Int(value))\(L10n.times1.tr(lang))"
        }
    }
}

struct DonutChartCard: View {
    let habits: [Habit]
    let periodCheckins: [Checkin]
    @ObservedObject var appSettings: AppSettings
    
    private var chartData: [HabitCountItem] {
        habits.compactMap { habit in
            let checks = periodCheckins.filter { $0.habit?.id == habit.id }
            let count = checks.count
            guard count > 0 else { return nil }
            if habit.goalType == "amount" {
                let sum = checks.reduce(0.0) { $0 + $1.amount }
                return HabitCountItem(habit: habit, value: sum, checkinCount: count)
            } else {
                return HabitCountItem(habit: habit, value: Double(count), checkinCount: count)
            }
        }.sorted { $0.checkinCount > $1.checkinCount }
    }
    
    private var totalEvents: Int {
        periodCheckins.filter { checkin in habits.contains(where: { $0.id == checkin.habit?.id }) }.count
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
                            Label {
                                Text(L10n.statisticsOverview.tr(appSettings.resolvedLanguage))
                                    .foregroundColor(DS.onSurface)
                            } icon: {
                                Image(systemName: "chart.pie.fill")
                                    .foregroundColor(DS.primary)
                            }
                            .font(.system(size: 16, weight: .semibold))
                            
                            Spacer()
            
            if chartData.isEmpty {
                Text(L10n.noData.tr(appSettings.resolvedLanguage))
                    .foregroundColor(DS.onSurfaceVariant)
                    .frame(maxWidth: .infinity, alignment: .center)
                    .padding(.vertical, DS.spacingL)
            } else {
                HStack(spacing: 24) {
                    // Donut Chart
                    ZStack {
                        if #available(iOS 17.0, *) {
                            Chart(chartData) { item in
                                SectorMark(
                                    angle: .value("Count", item.checkinCount),
                                    innerRadius: .ratio(0.75),
                                    angularInset: 2.0
                                )
                                .cornerRadius(4.0)
                                .foregroundStyle(Color(hex: item.habit.color))
                            }
                            .frame(width: 80, height: 80)
                        } else {
                            Circle()
                                .strokeBorder(DS.outlineVariant, lineWidth: 10)
                                .frame(width: 80, height: 80)
                        }
                        
                        VStack(spacing: 2) {
                            Text("\(totalEvents)")
                                .font(.system(size: 20, weight: .bold))
                                .foregroundColor(DS.onSurface)
                            Text(L10n.times2.tr(appSettings.resolvedLanguage))
                                .font(.system(size: 10, weight: .medium))
                                .foregroundColor(DS.onSurfaceVariant)
                        }
                    }
                    
                    // Legend
                    VStack(alignment: .leading, spacing: 10) {
                        ForEach(chartData) { item in
                            HStack(spacing: 8) {
                                Circle()
                                    .fill(Color(hex: item.habit.color))
                                    .frame(width: 8, height: 8)
                                
                                Text(item.habit.name)
                                    .font(.system(size: 13, weight: .medium))
                                    .foregroundColor(DS.onSurface)
                                    .lineLimit(1)
                                
                                Spacer()
                                
                                Text(item.displayString(lang: appSettings.resolvedLanguage))
                                    .font(.system(size: 13, weight: .bold))
                                    .foregroundColor(DS.onSurfaceVariant)
                            }
                        }
                    }
                    
                    Spacer(minLength: 0)
                }
                .padding(.vertical, 8)
                .padding(.horizontal, 4)
            }
        }
        .padding(24)
        .background(DS.surface.opacity(0.8))
        .clipShape(RoundedRectangle(cornerRadius: 24, style: .continuous))
        .padding(.horizontal, 20)
    }
}
