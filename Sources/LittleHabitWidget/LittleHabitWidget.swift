
import WidgetKit
import SwiftUI
import SwiftData
import AppIntents

import Foundation

func getWidgetLanguage() -> String {
    let mode = UserDefaults(suiteName: "group.com.littlehabit.tracker")?.string(forKey: "appLanguage") ?? "system"
    if mode == "zh" { return "zh" }
    if mode == "en" { return "en" }
    if let firstLang = Locale.preferredLanguages.first {
        if firstLang.hasPrefix("zh") { return "zh" }
    }
    return "en"
}

extension String {
    func wTr() -> String {
        let lang = getWidgetLanguage()
        let dict: [String: [String: String]] = [
            "No Habit": ["zh": "暂无习惯", "en": "No Habit"],
            "Select Habits": ["zh": "请选择习惯", "en": "Select Habits"],
            "请长按编辑选择习惯": ["zh": "请长按编辑选择习惯", "en": "Please long press to edit & select habit"],
            "本周": ["zh": "本周", "en": "This week"],
            "本月": ["zh": "本月", "en": "This month"],
            "次": ["zh": "次", "en": "times"],
            "公里": ["zh": "公里", "en": "km"],
            "米": ["zh": "米", "en": "m"],
            "分钟": ["zh": "分钟", "en": "mins"],
            "小时": ["zh": "小时", "en": "hours"],
            "页": ["zh": "页", "en": "pages"],
            "天": ["zh": "天", "en": "days"],
            "周": ["zh": "周", "en": "Week"],
            "月": ["zh": "月", "en": "Month"],
            "年": ["zh": "年", "en": "Year"]
        ]
        if let trans = dict[self] {
            return trans[lang] ?? self
        }
        return self
    }
}

// MARK: - Providers
@MainActor
func fetchFreshHabitsAndCheckins() -> ([Habit], [Checkin]) {
    do {
        let context = SharedModelContainerManager.mainContext
        var habitDescriptor = FetchDescriptor<Habit>(predicate: #Predicate<Habit> { $0.isArchived == false }, sortBy: [SortDescriptor(\.order)])
        habitDescriptor.relationshipKeyPathsForPrefetching = [\.checkins]
        habitDescriptor.includePendingChanges = true
        var checkinDescriptor = FetchDescriptor<Checkin>()
        checkinDescriptor.relationshipKeyPathsForPrefetching = [\.habit]
        checkinDescriptor.includePendingChanges = true
        let habits = (try? context.fetch(habitDescriptor)) ?? []
        let checkins = (try? context.fetch(checkinDescriptor)) ?? []
        
        for h in habits {
            _ = h.checkins?.count
            if let hc = h.checkins {
                for c in hc { _ = c.dateString }
            }
        }
        for c in checkins {
            _ = c.habit?.id
        }
        return (habits, checkins)
    } catch {
        return ([], [])
    }
}

struct Provider: AppIntentTimelineProvider {
    init() {}

    func placeholder(in context: Context) -> SimpleEntry {
        SimpleEntry(date: Date(), configuration: SelectHabitIntent(), habits: [], checkins: [])
    }

    @MainActor
    func snapshot(for configuration: SelectHabitIntent, in context: Context) async -> SimpleEntry {
        let (habits, checkins) = fetchFreshHabitsAndCheckins()
        return SimpleEntry(date: Date(), configuration: configuration, habits: habits, checkins: checkins)
    }

    @MainActor
    func timeline(for configuration: SelectHabitIntent, in context: Context) async -> Timeline<SimpleEntry> {
        let (habits, checkins) = fetchFreshHabitsAndCheckins()
        let entry = SimpleEntry(date: Date(), configuration: configuration, habits: habits, checkins: checkins)
        let nextUpdate = Calendar.current.date(byAdding: .hour, value: 1, to: Date())!
        return Timeline(entries: [entry], policy: .after(nextUpdate))
    }
}

struct MultipleHabitsProvider: AppIntentTimelineProvider {
    init() {}

    func placeholder(in context: Context) -> MultipleHabitsEntry {
        MultipleHabitsEntry(date: Date(), configuration: SelectMultipleHabitsIntent(), habits: [], checkins: [])
    }
    @MainActor func snapshot(for configuration: SelectMultipleHabitsIntent, in context: Context) async -> MultipleHabitsEntry {
        let (habits, checkins) = fetchFreshHabitsAndCheckins()
        return MultipleHabitsEntry(date: Date(), configuration: configuration, habits: habits, checkins: checkins)
    }
    @MainActor func timeline(for configuration: SelectMultipleHabitsIntent, in context: Context) async -> Timeline<MultipleHabitsEntry> {
        let (habits, checkins) = fetchFreshHabitsAndCheckins()
        let entry = MultipleHabitsEntry(date: Date(), configuration: configuration, habits: habits, checkins: checkins)
        return Timeline(entries: [entry], policy: .after(Calendar.current.date(byAdding: .hour, value: 1, to: Date())!))
    }
}

struct MonthProvider: AppIntentTimelineProvider {
    init() {}

    func placeholder(in context: Context) -> MonthEntry {
        MonthEntry(date: Date(), configuration: SelectMonthHabitIntent(), habits: [], checkins: [])
    }
    @MainActor func snapshot(for configuration: SelectMonthHabitIntent, in context: Context) async -> MonthEntry {
        let (habits, checkins) = fetchFreshHabitsAndCheckins()
        return MonthEntry(date: Date(), configuration: configuration, habits: habits, checkins: checkins)
    }
    @MainActor func timeline(for configuration: SelectMonthHabitIntent, in context: Context) async -> Timeline<MonthEntry> {
        let (habits, checkins) = fetchFreshHabitsAndCheckins()
        let entry = MonthEntry(date: Date(), configuration: configuration, habits: habits, checkins: checkins)
        return Timeline(entries: [entry], policy: .after(Calendar.current.date(byAdding: .hour, value: 1, to: Date())!))
    }
}

struct YearlyProvider: AppIntentTimelineProvider {
    init() {}

    func placeholder(in context: Context) -> YearlyEntry {
        YearlyEntry(date: Date(), configuration: SelectYearlyHabitIntent(), habits: [], checkins: [])
    }
    @MainActor func snapshot(for configuration: SelectYearlyHabitIntent, in context: Context) async -> YearlyEntry {
        let (habits, checkins) = fetchFreshHabitsAndCheckins()
        return YearlyEntry(date: Date(), configuration: configuration, habits: habits, checkins: checkins)
    }
    @MainActor func timeline(for configuration: SelectYearlyHabitIntent, in context: Context) async -> Timeline<YearlyEntry> {
        let (habits, checkins) = fetchFreshHabitsAndCheckins()
        let entry = YearlyEntry(date: Date(), configuration: configuration, habits: habits, checkins: checkins)
        return Timeline(entries: [entry], policy: .after(Calendar.current.date(byAdding: .hour, value: 1, to: Date())!))
    }
}

struct SimpleEntry: TimelineEntry {
    let date: Date
    let configuration: SelectHabitIntent
    let habits: [Habit]
    let checkins: [Checkin]
}

struct MultipleHabitsEntry: TimelineEntry {
    let date: Date
    let configuration: SelectMultipleHabitsIntent
    let habits: [Habit]
    let checkins: [Checkin]
}

struct MonthEntry: TimelineEntry {
    let date: Date
    let configuration: SelectMonthHabitIntent
    let habits: [Habit]
    let checkins: [Checkin]
}

struct YearlyEntry: TimelineEntry {
    let date: Date
    let configuration: SelectYearlyHabitIntent
    let habits: [Habit]
    let checkins: [Checkin]
}

// MARK: - Widget Helpers
func getWidgetFirstWeekday() -> Int {
    let defaults = UserDefaults(suiteName: "group.com.littlehabit.tracker")
    let wd = defaults?.integer(forKey: "firstWeekday") ?? 2
    return wd == 0 ? 2 : wd // fallback to 2 if not found
}

func getDaysForMonth(date: Date) -> [Date?] {
    var calendar = Calendar.current
    calendar.firstWeekday = getWidgetFirstWeekday()
    let components = calendar.dateComponents([.year, .month], from: date)
    guard let startOfMonth = calendar.date(from: components),
          let range = calendar.range(of: .day, in: .month, for: startOfMonth) else { return [] }
    
    let firstWeekday = calendar.component(.weekday, from: startOfMonth)
    var offset = firstWeekday - calendar.firstWeekday
    if offset < 0 { offset += 7 }
    
    var days: [Date?] = Array(repeating: nil, count: 42)
    for day in 1...range.count {
        if let d = calendar.date(byAdding: .day, value: day - 1, to: startOfMonth) {
            days[offset + day - 1] = d
        }
    }
    return days
}

func getDaysForWeek(date: Date) -> [Date] {
    var calendar = Calendar.current
    calendar.firstWeekday = getWidgetFirstWeekday()
    let components = calendar.dateComponents([.yearForWeekOfYear, .weekOfYear], from: date)
    guard let startOfWeek = calendar.date(from: components) else { return [] }
    
    var days: [Date] = []
    for i in 0..<7 {
        if let d = calendar.date(byAdding: .day, value: i, to: startOfWeek) {
            days.append(d)
        }
    }
    return days
}

func isCheckedIn(habit: Habit, date: Date, checkins: [Checkin]) -> Bool {
    let formatter = DateFormatter()
    formatter.dateFormat = "yyyy-MM-dd"
    let dateStr = formatter.string(from: date)
    if let hc = habit.checkins, hc.contains(where: { $0.dateString == dateStr }) {
        return true
    }
    return checkins.contains(where: { $0.habit?.id == habit.id && $0.dateString == dateStr })
}

func getCheckinsForPeriod(habit: Habit, date: Date, checkins: [Checkin]) -> Double {
    let calendar = Calendar.current
    let formatter = DateFormatter()
    formatter.dateFormat = "yyyy-MM-dd"
    
    let start: Date
    let end: Date
    
    if habit.frequencyType == "weekly" {
        var cal = calendar
        cal.firstWeekday = getWidgetFirstWeekday()
        let comps = cal.dateComponents([.yearForWeekOfYear, .weekOfYear], from: date)
        start = cal.date(from: comps)!
        end = cal.date(byAdding: .day, value: 7, to: start)!
    } else {
        let comps = calendar.dateComponents([.year, .month], from: date)
        start = calendar.date(from: comps)!
        end = calendar.date(byAdding: .month, value: 1, to: start)!
    }
    
    var sum: Double = 0
    var curr = start
    while curr < end {
        let dateStr = formatter.string(from: curr)
        let hc = habit.checkins ?? []
        let todaysFromHabit = hc.filter { $0.dateString == dateStr }
        let todaysFromGlobal = checkins.filter { $0.habit?.id == habit.id && $0.dateString == dateStr }
        let todays = todaysFromHabit.isEmpty ? todaysFromGlobal : todaysFromHabit
        if habit.goalType == "amount" {
            sum += todays.reduce(0) { $0 + $1.amount }
        } else {
            sum += todays.isEmpty ? 0 : 1
        }
        curr = calendar.date(byAdding: .day, value: 1, to: curr)!
    }
    return sum
}

// MARK: - Views

struct UnselectedHabitWidgetView: View {
    var body: some View {
        VStack(spacing: 6) {
            Image(systemName: "hand.tap.fill")
                .font(.system(size: 24))
                .foregroundColor(DS.primary)
            Text("请长按编辑选择习惯".wTr())
                .font(.system(size: 13, weight: .semibold))
                .foregroundColor(DS.onSurfaceVariant)
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .padding(12)
    }
}

struct MultiHabitCheckinWidgetView: View {
    var entry: MultipleHabitsEntry
    var body: some View {
        let selectedIds = entry.configuration.habits?.map { $0.id } ?? []
        let configured = entry.habits.filter { selectedIds.contains($0.id) && !$0.isArchived }
        let selectedHabits = configured.isEmpty ? Array(entry.habits.filter { !$0.isArchived }.prefix(3)) : Array(configured.prefix(3))
        
        VStack(spacing: 0) {
            if selectedHabits.isEmpty {
                UnselectedHabitWidgetView()
            } else {
                ForEach(selectedHabits) { habit in
                    let isDone = isCheckedIn(habit: habit, date: entry.date, checkins: entry.checkins)
                    HStack(spacing: 6) {
                        ZStack {
                            Circle().fill(Color(hex: habit.color).opacity(0.15)).frame(width: 28, height: 28)
                            Image(systemName: habit.icon).font(.system(size: 14)).foregroundColor(Color(hex: habit.color))
                        }
                        Text(habit.name).font(.system(size: 14, weight: .bold)).lineLimit(1).truncationMode(.tail)
                        Spacer(minLength: 0)
                        Button(intent: CheckinHabitIntent(habitId: habit.id)) {
                            ZStack {
                                if isDone {
                                    Image(systemName: "checkmark.circle.fill").font(.system(size: 24)).foregroundColor(Color(hex: habit.color))
                                } else {
                                    Circle().stroke(Color(hex: habit.color), lineWidth: 2).frame(width: 22, height: 22)
                                }
                            }
                            .frame(width: 28, height: 28)
                        }.buttonStyle(.plain)
                    }
                    .frame(maxHeight: .infinity)
                }
            }
        }
        .padding(.vertical, 4)
    }
}

struct NewSingleHabitWidgetView: View {
    var entry: SimpleEntry
    var body: some View {
        let habit = entry.configuration.selectedHabit.flatMap { h in entry.habits.first(where: { $0.id == h.id && !$0.isArchived }) } ?? entry.habits.first(where: { !$0.isArchived })
        VStack(spacing: 8) {
            if let habit = habit {
                let isDone = isCheckedIn(habit: habit, date: entry.date, checkins: entry.checkins)
                Button(intent: CheckinHabitIntent(habitId: habit.id)) {
                    ZStack {
                        if isDone {
                            Image(systemName: "checkmark.circle.fill").resizable().foregroundColor(Color(hex: habit.color)).frame(width: 56, height: 56)
                        } else {
                            Circle().stroke(Color(hex: habit.color), lineWidth: 2).frame(width: 56, height: 56)
                            Image(systemName: habit.icon).font(.system(size: 24)).foregroundColor(Color(hex: habit.color))
                        }
                    }
                }.buttonStyle(.plain)
                
                Text(habit.name).font(.system(size: 15, weight: .bold)).lineLimit(1).truncationMode(.tail)
                
                let label = habit.frequencyType == "weekly" ? "本周".wTr() : "本月".wTr()
                let suffix = habit.goalType == "amount" ? habit.amountUnit.wTr() : "次".wTr()
                let count = Int(getCheckinsForPeriod(habit: habit, date: entry.date, checkins: entry.checkins))
                let target = habit.goalType == "amount" ? Int(habit.amountValue) : (habit.frequencyType == "weekly" ? habit.weeklyTarget : habit.monthlyTarget)
                
                Text("\(label): \(count)/\(target)\(suffix)").font(.system(size: 10, weight: .medium)).foregroundColor(Color.secondary)
            } else {
                UnselectedHabitWidgetView()
            }
        }
    }
}

struct MonthCalendarWidgetView: View {
    var habit: Habit
    var checkins: [Checkin]
    var date: Date
    var body: some View {
        let lang = getWidgetLanguage()
        let days = getDaysForMonth(date: date)
        let sunFirst = getWidgetFirstWeekday() == 1
        let weekdaysEn = sunFirst ? ["S", "M", "T", "W", "T", "F", "S"] : ["M", "T", "W", "T", "F", "S", "S"]
        let weekdaysZh = sunFirst ? ["日", "一", "二", "三", "四", "五", "六"] : ["一", "二", "三", "四", "五", "六", "日"]
        let weekdays = lang == "zh" ? weekdaysZh : weekdaysEn
        
        let monthStr = {
            let f = DateFormatter()
            f.dateFormat = lang == "zh" ? "yyyy年M月" : "MMM yyyy"
            return f.string(from: date)
        }()
        
        HStack(alignment: .top, spacing: 14) {
            VStack(alignment: .leading, spacing: 10) {
                // Top: Enlarged icon + Habit Name (moved up and enlarged!)
                HStack(spacing: 8) {
                    ZStack {
                        Circle().fill(Color(hex: habit.color).opacity(0.18)).frame(width: 38, height: 38)
                        Image(systemName: habit.icon).font(.system(size: 19, weight: .bold)).foregroundColor(Color(hex: habit.color))
                    }
                    Text(habit.name)
                        .font(.system(size: 16, weight: .bold))
                        .lineLimit(2)
                        .truncationMode(.tail)
                        .foregroundColor(Color.primary)
                }
                
                // Check-in Count Badge (enlarged and moved up!)
                let statText = {
                    let periodVal = getCheckinsForPeriod(habit: habit, date: date, checkins: checkins)
                    if habit.goalType == "amount" {
                        let amountFormatted = periodVal.truncatingRemainder(dividingBy: 1) == 0 ? String(format: "%.0f", periodVal) : String(format: "%.1f", periodVal)
                        return "\(amountFormatted) \(habit.amountUnit.wTr())"
                    } else {
                        return "\(Int(periodVal)) \("天".wTr())"
                    }
                }()
                
                Text(statText)
                    .font(.system(size: 14, weight: .heavy))
                    .foregroundColor(Color(hex: habit.color))
                    .padding(.horizontal, 9)
                    .padding(.vertical, 4)
                    .background(Color(hex: habit.color).opacity(0.15))
                    .clipShape(Capsule())
                
                Spacer(minLength: 2)
                
                // Subtext: Month label moved below
                HStack(spacing: 4) {
                    Image(systemName: "calendar")
                    Text("\(monthStr)")
                        .font(.system(size: 11, weight: .semibold))
                }
                .foregroundColor(Color.secondary)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            
            Spacer(minLength: 0)
            
            VStack(spacing: 4) {
                HStack(spacing: 4) {
                    ForEach(weekdays, id: \.self) { day in
                        Text(day).font(.system(size: 11, weight: .bold)).foregroundColor(Color.secondary).frame(width: 20)
                    }
                }
                VStack(spacing: 4) {
                    ForEach(0..<6, id: \.self) { row in
                        HStack(spacing: 4) {
                            ForEach(0..<7, id: \.self) { col in
                                let index = row * 7 + col
                                if let dayDate = days[index] {
                                    let isDone = isCheckedIn(habit: habit, date: dayDate, checkins: checkins)
                                    let dayStr = "\(Calendar.current.component(.day, from: dayDate))"
                                    ZStack {
                                        RoundedRectangle(cornerRadius: 5)
                                            .fill(isDone ? Color(hex: habit.color) : Color(UIColor.tertiarySystemFill))
                                            .frame(width: 20, height: 20)
                                        Text(dayStr)
                                            .font(.system(size: 10, weight: isDone ? .bold : .medium))
                                            .foregroundColor(isDone ? .white : Color.primary.opacity(0.8))
                                    }
                                } else {
                                    Color.clear.frame(width: 20, height: 20)
                                }
                            }
                        }
                    }
                }
            }
        }
    }
}

struct MultiHabitWeekWidgetView: View {
    var entry: MultipleHabitsEntry
    var selectedHabits: [Habit]
    var body: some View {
        let lang = getWidgetLanguage()
        let days = getDaysForWeek(date: entry.date)
        let sunFirst = getWidgetFirstWeekday() == 1
        let weekdaysEn = sunFirst ? ["S", "M", "T", "W", "T", "F", "S"] : ["M", "T", "W", "T", "F", "S", "S"]
        let weekdaysZh = sunFirst ? ["日", "一", "二", "三", "四", "五", "六"] : ["一", "二", "三", "四", "五", "六", "日"]
        let weekdays = lang == "zh" ? weekdaysZh : weekdaysEn
        
        let weekRangeStr = {
            guard let first = days.first, let last = days.last else { return "" }
            let f = DateFormatter()
            if lang == "zh" {
                f.locale = Locale(identifier: "zh_CN")
                f.dateFormat = "M月d日"
            } else {
                f.locale = Locale(identifier: "en_US")
                f.dateFormat = "MMM d"
            }
            return "\(f.string(from: first)) - \(f.string(from: last))"
        }()
        
        VStack(spacing: 8) {
            HStack(alignment: .bottom, spacing: 14) {
                VStack(alignment: .leading, spacing: 2) {
                    HStack(spacing: 4) {
                        Image(systemName: "calendar")
                        Text("周".wTr())
                            .font(.system(size: 11, weight: .bold))
                    }
                    .foregroundColor(DS.primary)
                    
                    Text(weekRangeStr)
                        .font(.system(size: 10, weight: .semibold))
                        .foregroundColor(Color.secondary)
                        .lineLimit(2)
                        .minimumScaleFactor(0.7)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                
                Spacer(minLength: 0)
                
                HStack(spacing: 4) {
                    ForEach(weekdays, id: \.self) { day in
                        Text(day).font(.system(size: 11, weight: .bold)).foregroundColor(Color.secondary)
                            .frame(width: 20)
                    }
                }
            }
            
            ForEach(selectedHabits) { habit in
                HStack(spacing: 14) {
                    HStack(spacing: 6) {
                        ZStack {
                            Circle().fill(Color(hex: habit.color).opacity(0.15)).frame(width: 22, height: 22)
                            Image(systemName: habit.icon).font(.system(size: 11)).foregroundColor(Color(hex: habit.color))
                        }
                        Text(habit.name).font(.system(size: 13, weight: .bold)).lineLimit(1).truncationMode(.tail)
                        Spacer(minLength: 0)
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    
                    Spacer(minLength: 0)
                    
                    HStack(spacing: 4) {
                        ForEach(days, id: \.self) { day in
                            let isDone = isCheckedIn(habit: habit, date: day, checkins: entry.checkins)
                            ZStack {
                                RoundedRectangle(cornerRadius: 5)
                                    .fill(isDone ? Color(hex: habit.color) : Color(UIColor.tertiarySystemFill))
                                    .frame(width: 20, height: 20)
                            }
                        }
                    }
                }
            }
        }
    }
}

struct YearlyHeatmapWidgetView: View {
    var habit: Habit
    var checkins: [Checkin]
    var date: Date
    @Environment(\.widgetFamily) var family
    
    var body: some View {
        let lang = getWidgetLanguage()
        let calendar = Calendar.current
        let currentYear = calendar.component(.year, from: date)
        let yearStr = lang == "zh" ? "\(currentYear)年" : "\(currentYear)"
        let yearPrefix = String(format: "%04d-", currentYear)
        
        let hc = habit.checkins ?? []
        let globalHc = checkins.filter { $0.habit?.id == habit.id }
        let checkedDateStrings = Set(hc.map { $0.dateString } + globalHc.map { $0.dateString })
        
        let thisYearCheckins = hc.filter { $0.dateString.hasPrefix(yearPrefix) } + globalHc.filter { $0.dateString.hasPrefix(yearPrefix) }
        let thisYearDays = Set(thisYearCheckins.map { $0.dateString }).count
        let thisYearAmount = thisYearCheckins.reduce(0.0) { $0 + $1.amount }
        
        let statStr = {
            if habit.goalType == "amount" {
                let amountFormatted = thisYearAmount.truncatingRemainder(dividingBy: 1) == 0 ? String(format: "%.0f", thisYearAmount) : String(format: "%.1f", thisYearAmount)
                return "\(amountFormatted) \(habit.amountUnit.wTr())"
            } else {
                return "\(thisYearDays) \("次".wTr())"
            }
        }()
        
        let isLarge = (family == .systemLarge)
        let cols = 52
        let cellWidth: CGFloat = 4.3
        let cellSpacing: CGFloat = 1.5
        let cellHeight: CGFloat = isLarge ? 14 : 4.3
        
        let startOfToday = calendar.startOfDay(for: date)
        let gridData: [Bool] = {
            let df = DateFormatter()
            df.dateFormat = "yyyy-MM-dd"
            return (0..<(cols*7)).map { offset in
                if let d = calendar.date(byAdding: .day, value: -(cols*7 - 1) + offset, to: startOfToday) {
                    let dStr = df.string(from: d)
                    return checkedDateStrings.contains(dStr)
                }
                return false
            }
        }()
        
        VStack(alignment: .leading, spacing: isLarge ? 14 : 8) {
            HStack(alignment: .center, spacing: 14) {
                VStack(alignment: .leading, spacing: 2) {
                    HStack(spacing: 4) {
                        Image(systemName: "calendar")
                        Text("年".wTr())
                            .font(.system(size: 11, weight: .bold))
                    }
                    .foregroundColor(Color(hex: habit.color))
                    
                    Text(yearStr)
                        .font(.system(size: 11, weight: .semibold))
                        .foregroundColor(Color.secondary)
                }
                .frame(minWidth: 50, alignment: .leading)
                
                Spacer(minLength: 0)
                
                HStack(spacing: 6) {
                    ZStack {
                        Circle().fill(Color(hex: habit.color).opacity(0.15)).frame(width: 22, height: 22)
                        Image(systemName: habit.icon).font(.system(size: 11)).foregroundColor(Color(hex: habit.color))
                    }
                    Text(habit.name).font(.system(size: 13, weight: .bold)).lineLimit(1).truncationMode(.tail).foregroundColor(Color.primary)
                }
                
                Spacer(minLength: 0)
                
                Text(statStr)
                    .font(.system(size: 11, weight: .heavy))
                    .foregroundColor(Color(hex: habit.color))
                    .padding(.horizontal, 6)
                    .padding(.vertical, 2)
                    .background(Color(hex: habit.color).opacity(0.12))
                    .clipShape(Capsule())
            }
            
            Spacer(minLength: 0)
            
            HStack(spacing: cellSpacing) {
                ForEach(0..<cols, id: \.self) { col in
                    VStack(spacing: cellSpacing) {
                        ForEach(0..<7, id: \.self) { row in
                            let index = col * 7 + row
                            if index < gridData.count {
                                let isDone = gridData[index]
                                RoundedRectangle(cornerRadius: isLarge ? 1.5 : 1)
                                    .fill(isDone ? Color(hex: habit.color) : Color(UIColor.tertiarySystemFill))
                                    .frame(width: cellWidth, height: cellHeight)
                            } else {
                                Color.clear.frame(width: cellWidth, height: cellHeight)
                            }
                        }
                    }
                }
            }
            .frame(maxWidth: .infinity, alignment: .center)
            
            Spacer(minLength: 0)
        }
        .padding(.vertical, isLarge ? 16 : 8)
    }
}

struct SingleYearlyWidgetView: View {
    var entry: YearlyEntry
    var body: some View {
        let habit = entry.configuration.selectedHabit.flatMap { h in entry.habits.first(where: { $0.id == h.id && !$0.isArchived }) } ?? entry.habits.first(where: { !$0.isArchived })
        VStack {
            if let habit = habit { 
                YearlyHeatmapWidgetView(habit: habit, checkins: entry.checkins, date: entry.date)
            } else {
                UnselectedHabitWidgetView()
            }
        }
    }
}

struct SingleMonthWidgetView: View {
    var entry: MonthEntry
    var body: some View {
        let habit = entry.configuration.selectedHabit.flatMap { h in entry.habits.first(where: { $0.id == h.id && !$0.isArchived }) } ?? entry.habits.first(where: { !$0.isArchived })
        if let habit = habit {
            MonthCalendarWidgetView(habit: habit, checkins: entry.checkins, date: entry.date)
        } else {
            UnselectedHabitWidgetView()
        }
    }
}

struct MultiHabitWeekWidgetContainerView: View {
    var entry: MultipleHabitsEntry
    var body: some View {
        let selectedIds = entry.configuration.habits?.map { $0.id } ?? []
        let configured = entry.habits.filter { selectedIds.contains($0.id) && !$0.isArchived }
        let selectedHabits = configured.isEmpty ? Array(entry.habits.filter { !$0.isArchived }.prefix(4)) : Array(configured.prefix(4))
        if selectedHabits.isEmpty {
            UnselectedHabitWidgetView()
        } else {
            MultiHabitWeekWidgetView(entry: entry, selectedHabits: selectedHabits)
        }
    }
}

// MARK: - Configurations
struct MultiHabitCheckinWidget: Widget {
    var body: some WidgetConfiguration {
        AppIntentConfiguration(kind: "LittleHabitWidget", intent: SelectMultipleHabitsIntent.self, provider: MultipleHabitsProvider()) { entry in
            MultiHabitCheckinWidgetView(entry: entry).forceAppTheme().containerBackground(for: .widget) { MyWidgetBackground().forceAppTheme() }
        }.configurationDisplayName("Multi Habit Checkin").description("Track 3 habits side by side.").supportedFamilies([.systemSmall])
    }
}

struct NewSingleHabitWidget: Widget {
    var body: some WidgetConfiguration {
        AppIntentConfiguration(kind: "NewSingleHabitWidget", intent: SelectHabitIntent.self, provider: Provider()) { entry in
            NewSingleHabitWidgetView(entry: entry).forceAppTheme().containerBackground(for: .widget) { MyWidgetBackground().forceAppTheme() }
        }.configurationDisplayName("Single Habit Checkin").description("Quickly check in one habit.").supportedFamilies([.systemSmall])
    }
}

struct SingleMonthWidget: Widget {
    var body: some WidgetConfiguration {
        AppIntentConfiguration(kind: "SingleMonthWidget", intent: SelectMonthHabitIntent.self, provider: MonthProvider()) { entry in
            SingleMonthWidgetView(entry: entry).forceAppTheme().containerBackground(for: .widget) { MyWidgetBackground().forceAppTheme() }
        }.configurationDisplayName("Single Habit Month").description("Monthly calendar view for a habit.").supportedFamilies([.systemMedium])
    }
}

struct MultiMonthWidget: Widget {
    var body: some WidgetConfiguration {
        AppIntentConfiguration(kind: "MultiMonthWidget", intent: SelectMultipleHabitsIntent.self, provider: MultipleHabitsProvider()) { entry in
            MultiHabitWeekWidgetContainerView(entry: entry).forceAppTheme().containerBackground(for: .widget) { MyWidgetBackground().forceAppTheme() }
        }.configurationDisplayName("Multi Habit Weekly").description("Compare multiple habits weekly.").supportedFamilies([.systemMedium])
    }
}

struct SingleYearlyWidget: Widget {
    var body: some WidgetConfiguration {
        AppIntentConfiguration(kind: "SingleYearlyWidget", intent: SelectYearlyHabitIntent.self, provider: YearlyProvider()) { entry in
            SingleYearlyWidgetView(entry: entry).forceAppTheme().containerBackground(for: .widget) { MyWidgetBackground().forceAppTheme() }
        }.configurationDisplayName("Single Habit Yearly").description("Yearly heatmap for a habit.").supportedFamilies([.systemMedium, .systemLarge])
    }
}



func getWidgetColorScheme(systemScheme: ColorScheme) -> ColorScheme {
    let mode = UserDefaults(suiteName: "group.com.littlehabit.tracker")?.string(forKey: "themeMode") ?? "system"
    if mode == "dark" { return .dark }
    if mode == "light" { return .light }
    return systemScheme
}

struct AppThemeModifier: ViewModifier {
    @Environment(\.colorScheme) var systemScheme
    func body(content: Content) -> some View {
        let scheme = getWidgetColorScheme(systemScheme: systemScheme)
        content
            .environment(\.colorScheme, scheme)
    }
}

extension View {
    func forceAppTheme() -> some View {
        self.modifier(AppThemeModifier())
    }
}

struct MyWidgetBackground: View {
    @Environment(\.colorScheme) var colorScheme
    var body: some View {
        if colorScheme == .dark {
            Color(hex: "#1C1C1E")
        } else {
            Color(hex: "#F9FAFC")
        }
    }
}


@main

struct LittleHabitWidgetBundle: WidgetBundle {
    var body: some Widget {
        MultiHabitCheckinWidget()
        NewSingleHabitWidget()          
        SingleMonthWidget()          
        MultiMonthWidget()           
        SingleYearlyWidget()         
    }
}
