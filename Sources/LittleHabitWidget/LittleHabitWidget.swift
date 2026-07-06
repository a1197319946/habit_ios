
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
            "本周": ["zh": "本周", "en": "This week"],
            "本月": ["zh": "本月", "en": "This month"],
            "次": ["zh": "次", "en": "times"],
            "公里": ["zh": "公里", "en": "km"],
            "米": ["zh": "米", "en": "m"],
            "分钟": ["zh": "分钟", "en": "mins"],
            "小时": ["zh": "小时", "en": "hours"],
            "页": ["zh": "页", "en": "pages"],
            "天": ["zh": "天", "en": "days"],
            "周": ["zh": "周", "en": "week"],
            "月": ["zh": "月", "en": "month"]
        ]
        if let trans = dict[self] {
            return trans[lang] ?? self
        }
        return self
    }
}

// MARK: - Providers
struct Provider: AppIntentTimelineProvider {
    let modelContainer: ModelContainer
    
    init() {
        let schema = Schema([Habit.self, Checkin.self, MoodRecord.self])
        let sharedStoreURL = FileManager.default.containerURL(forSecurityApplicationGroupIdentifier: "group.com.littlehabit.tracker")?.appendingPathComponent("shared.store") ?? URL.temporaryDirectory.appending(path: "widget.store")
        let modelConfiguration = ModelConfiguration(schema: schema, url: sharedStoreURL)
        do {
            modelContainer = try ModelContainer(for: schema, configurations: [modelConfiguration])
        } catch {
            let fallbackConfig = ModelConfiguration(schema: schema, isStoredInMemoryOnly: true)
            modelContainer = try! ModelContainer(for: schema, configurations: [fallbackConfig])
        }
    }
    
    @MainActor
    func fetchHabits() -> [Habit] {
        let descriptor = FetchDescriptor<Habit>(sortBy: [SortDescriptor(\.createdAt)])
        return (try? modelContainer.mainContext.fetch(descriptor)) ?? []
    }
    
    @MainActor
    func fetchCheckins() -> [Checkin] {
        return (try? modelContainer.mainContext.fetch(FetchDescriptor<Checkin>())) ?? []
    }

    func placeholder(in context: Context) -> SimpleEntry {
        SimpleEntry(date: Date(), configuration: SelectHabitIntent(), habits: [], checkins: [])
    }

    @MainActor
    func snapshot(for configuration: SelectHabitIntent, in context: Context) async -> SimpleEntry {
        SimpleEntry(date: Date(), configuration: configuration, habits: fetchHabits(), checkins: fetchCheckins())
    }

    @MainActor
    func timeline(for configuration: SelectHabitIntent, in context: Context) async -> Timeline<SimpleEntry> {
        let entry = SimpleEntry(date: Date(), configuration: configuration, habits: fetchHabits(), checkins: fetchCheckins())
        let nextUpdate = Calendar.current.date(byAdding: .hour, value: 1, to: Date())!
        return Timeline(entries: [entry], policy: .after(nextUpdate))
    }
}

struct MultipleHabitsProvider: AppIntentTimelineProvider {
    let modelContainer: ModelContainer
    init() {
        let schema = Schema([Habit.self, Checkin.self, MoodRecord.self])
        let sharedStoreURL = FileManager.default.containerURL(forSecurityApplicationGroupIdentifier: "group.com.littlehabit.tracker")?.appendingPathComponent("shared.store") ?? URL.temporaryDirectory.appending(path: "widget.store")
        do {
            modelContainer = try ModelContainer(for: schema, configurations: [ModelConfiguration(schema: schema, url: sharedStoreURL)])
        } catch {
            modelContainer = try! ModelContainer(for: schema, configurations: [ModelConfiguration(schema: schema, isStoredInMemoryOnly: true)])
        }
    }
    
    @MainActor func fetchHabits() -> [Habit] { return (try? modelContainer.mainContext.fetch(FetchDescriptor<Habit>())) ?? [] }
    @MainActor func fetchCheckins() -> [Checkin] { return (try? modelContainer.mainContext.fetch(FetchDescriptor<Checkin>())) ?? [] }

    func placeholder(in context: Context) -> MultipleHabitsEntry {
        MultipleHabitsEntry(date: Date(), configuration: SelectMultipleHabitsIntent(), habits: [], checkins: [])
    }
    @MainActor func snapshot(for configuration: SelectMultipleHabitsIntent, in context: Context) async -> MultipleHabitsEntry {
        MultipleHabitsEntry(date: Date(), configuration: configuration, habits: fetchHabits(), checkins: fetchCheckins())
    }
    @MainActor func timeline(for configuration: SelectMultipleHabitsIntent, in context: Context) async -> Timeline<MultipleHabitsEntry> {
        let entry = MultipleHabitsEntry(date: Date(), configuration: configuration, habits: fetchHabits(), checkins: fetchCheckins())
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

// MARK: - App Intents
struct HabitEntity: AppEntity {
    var id: String
    var name: String
    var icon: String
    var color: String

    static var typeDisplayRepresentation: TypeDisplayRepresentation = "Habit"
    static var defaultQuery = HabitEntityQuery()

    var displayRepresentation: DisplayRepresentation {
        DisplayRepresentation(title: "\(name)")
    }
}

struct HabitEntityQuery: EntityQuery {
    func entities(for identifiers: [String]) async throws -> [HabitEntity] {
        let allHabits = await fetchAllHabits()
        return allHabits.filter { identifiers.contains($0.id) }
    }

    func suggestedEntities() async throws -> [HabitEntity] { return await fetchAllHabits() }
    func defaultResult() async -> HabitEntity? { return try? await suggestedEntities().first }

    @MainActor
    private func fetchAllHabits() -> [HabitEntity] {
        let schema = Schema([Habit.self, Checkin.self, MoodRecord.self])
        guard let sharedStoreURL = FileManager.default.containerURL(forSecurityApplicationGroupIdentifier: "group.com.littlehabit.tracker")?.appendingPathComponent("shared.store") else { return [] }
        let modelConfiguration = ModelConfiguration(schema: schema, url: sharedStoreURL)
        do {
            let modelContainer = try ModelContainer(for: schema, configurations: [modelConfiguration])
            let descriptor = FetchDescriptor<Habit>(sortBy: [SortDescriptor(\.createdAt)])
            let habits = try modelContainer.mainContext.fetch(descriptor)
            return habits.map { HabitEntity(id: $0.id, name: $0.name, icon: $0.icon, color: $0.color) }
        } catch {
            return []
        }
    }
}

struct SelectHabitIntent: WidgetConfigurationIntent {
    static var title: LocalizedStringResource = "Select Habit"
    @Parameter(title: "Habit") var selectedHabit: HabitEntity?
}

struct SelectMultipleHabitsIntent: WidgetConfigurationIntent {
    static var title: LocalizedStringResource = "Select Multiple Habits"
    @Parameter(title: "Habits") var habits: [HabitEntity]?
}

struct CheckinHabitIntent: AppIntent {
    static var title: LocalizedStringResource = "Check in Habit"
    @Parameter(title: "Habit ID") var habitId: String

    init() {}
    init(habitId: String) { self.habitId = habitId }

    @MainActor
    func perform() async throws -> some IntentResult {
        let schema = Schema([Habit.self, Checkin.self, MoodRecord.self])
        guard let sharedStoreURL = FileManager.default.containerURL(forSecurityApplicationGroupIdentifier: "group.com.littlehabit.tracker")?.appendingPathComponent("shared.store") else { return .result() }
        let modelConfiguration = ModelConfiguration(schema: schema, url: sharedStoreURL)
        do {
            let modelContainer = try ModelContainer(for: schema, configurations: [modelConfiguration])
            let descriptor = FetchDescriptor<Habit>()
            let habits = try modelContainer.mainContext.fetch(descriptor)
            if let targetHabit = habits.first(where: { $0.id == habitId }) {
                let today = Date()
                let dateString = {
                    let formatter = DateFormatter()
                    formatter.dateFormat = "yyyy-MM-dd"
                    return formatter.string(from: today)
                }()
                let descriptorCheckins = FetchDescriptor<Checkin>()
                let allCheckins = try modelContainer.mainContext.fetch(descriptorCheckins)
                let todays = allCheckins.filter { $0.habit?.id == habitId && $0.dateString == dateString }
                let fillAmount = targetHabit.goalType == "amount" ? targetHabit.amountValue : 1
                let totalAmount = todays.reduce(0, { $0 + $1.amount })
                if totalAmount > 0 {
                    // Undo: Delete all checkin records for today to cleanly undo
                    todays.forEach { modelContainer.mainContext.delete($0) }
                } else {
                    // Checkin
                    let newCheckin = Checkin(dateString: dateString, amount: fillAmount)
                    modelContainer.mainContext.insert(newCheckin)
                    newCheckin.habit = targetHabit
                    newCheckin.timestamp = today
                }
                try modelContainer.mainContext.save()
            }
        } catch {}
        WidgetCenter.shared.reloadAllTimelines()
        return .result()
    }
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
    let todays = checkins.filter { $0.habit?.id == habit.id && $0.dateString == dateStr }
    if habit.goalType == "amount" {
        return todays.reduce(0) { $0 + $1.amount } >= habit.amountValue
    } else {
        return todays.reduce(0) { $0 + $1.amount } > 0
    }
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
        let todays = checkins.filter { $0.habit?.id == habit.id && $0.dateString == dateStr }
        sum += todays.reduce(0) { $0 + $1.amount }
        curr = calendar.date(byAdding: .day, value: 1, to: curr)!
    }
    return sum
}

// MARK: - Views

struct MultiHabitCheckinWidgetView: View {
    var entry: MultipleHabitsEntry
    var body: some View {
        let selectedIds = entry.configuration.habits?.map { $0.id } ?? []
        let selectedHabits = Array(entry.habits.filter { selectedIds.contains($0.id) }.prefix(3))
        
        VStack(spacing: 0) {
            if selectedHabits.isEmpty {
                Text("Select Habits".wTr()).foregroundColor(Color.secondary)
            } else {
                ForEach(selectedHabits) { habit in
                    let isDone = isCheckedIn(habit: habit, date: entry.date, checkins: entry.checkins)
                    HStack(spacing: 6) {
                        ZStack {
                            Circle().fill(Color(hex: habit.color).opacity(0.15)).frame(width: 28, height: 28)
                            Image(systemName: habit.icon).font(.system(size: 14)).foregroundColor(Color(hex: habit.color))
                        }
                        Text(habit.name).font(.system(size: 14, weight: .bold)).lineLimit(1)
                        Spacer()
                        Button(intent: CheckinHabitIntent(habitId: habit.id)) {
                            ZStack {
                                if isDone {
                                    Image(systemName: "checkmark.circle.fill").font(.system(size: 24)).foregroundColor(.green)
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
        let habit = entry.configuration.selectedHabit.flatMap { h in entry.habits.first(where: { $0.id == h.id }) } ?? entry.habits.first
        VStack(spacing: 8) {
            if let habit = habit {
                let isDone = isCheckedIn(habit: habit, date: entry.date, checkins: entry.checkins)
                Button(intent: CheckinHabitIntent(habitId: habit.id)) {
                    ZStack {
                        if isDone {
                            Image(systemName: "checkmark.circle.fill").resizable().foregroundColor(.green).frame(width: 56, height: 56)
                        } else {
                            Circle().stroke(Color(hex: habit.color), lineWidth: 2).frame(width: 56, height: 56)
                            Image(systemName: habit.icon).font(.system(size: 24)).foregroundColor(Color(hex: habit.color))
                        }
                    }
                }.buttonStyle(.plain)
                
                Text(habit.name).font(.system(size: 14, weight: .bold)).lineLimit(1)
                
                let label = habit.frequencyType == "weekly" ? "本周".wTr() : "本月".wTr()
                let suffix = habit.goalType == "amount" ? habit.amountUnit.wTr() : "次".wTr()
                let count = Int(getCheckinsForPeriod(habit: habit, date: entry.date, checkins: entry.checkins))
                let target = habit.goalType == "amount" ? Int(habit.amountValue) : (habit.frequencyType == "weekly" ? habit.weeklyTarget : habit.monthlyTarget)
                
                Text("\(label): \(count)/\(target)\(suffix)").font(.system(size: 10, weight: .medium)).foregroundColor(Color.secondary)
            } else {
                Text("No Habit".wTr()).foregroundColor(Color.secondary)
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
        
        let todayIsDone = isCheckedIn(habit: habit, date: Date(), checkins: checkins)
        
        HStack(alignment: .firstTextBaseline, spacing: 12) {
            VStack(spacing: 16) {
                Text(monthStr).font(.system(size: 14, weight: .heavy)).foregroundColor(Color.primary).lineLimit(1).minimumScaleFactor(0.8).padding(.top, 4)
                
                ZStack {
                    Circle().fill(Color(hex: habit.color).opacity(0.15)).frame(width: 52, height: 52)
                    Image(systemName: habit.icon).font(.system(size: 24)).foregroundColor(Color(hex: habit.color))
                }
                
                Text(habit.name).font(.system(size: 16, weight: .bold)).lineLimit(1).foregroundColor(Color.primary)
            }
            .frame(width: 90)
            
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
                                        RoundedRectangle(cornerRadius: 6)
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
        .padding(.top, 20)
    }
}

struct MultiHabitWeekWidgetView: View {
    var entry: MultipleHabitsEntry
    var body: some View {
        let lang = getWidgetLanguage()
        let days = getDaysForWeek(date: entry.date)
        let sunFirst = getWidgetFirstWeekday() == 1
        let weekdaysEn = sunFirst ? ["S", "M", "T", "W", "T", "F", "S"] : ["M", "T", "W", "T", "F", "S", "S"]
        let weekdaysZh = sunFirst ? ["日", "一", "二", "三", "四", "五", "六"] : ["一", "二", "三", "四", "五", "六", "日"]
        let weekdays = lang == "zh" ? weekdaysZh : weekdaysEn
        
        let selectedIds = entry.configuration.habits?.map { $0.id } ?? []
        let selectedHabits = Array(entry.habits.filter { selectedIds.contains($0.id) }.prefix(4))
        
        VStack(spacing: 8) {
            HStack(spacing: 6) {
                Spacer().frame(width: 84)
                Spacer(minLength: 0)
                ForEach(weekdays, id: \.self) { day in
                    Text(day).font(.system(size: 10, weight: .bold)).foregroundColor(Color.secondary)
                        .frame(width: 20)
                }
            }
            
            ForEach(selectedHabits) { habit in
                HStack(spacing: 6) {
                    HStack(spacing: 4) {
                        ZStack {
                            Circle().fill(Color(hex: habit.color).opacity(0.15)).frame(width: 20, height: 20)
                            Image(systemName: habit.icon).font(.system(size: 10)).foregroundColor(Color(hex: habit.color))
                        }
                        Text(habit.name).font(.system(size: 12, weight: .bold)).lineLimit(1)
                        Spacer()
                    }
                    .frame(width: 84, alignment: .leading)
                    Spacer(minLength: 0)
                    ForEach(days, id: \.self) { day in
                        let isDone = isCheckedIn(habit: habit, date: day, checkins: entry.checkins)
                        RoundedRectangle(cornerRadius: 4)
                            .fill(isDone ? Color(hex: habit.color) : Color(UIColor.tertiarySystemFill))
                            .frame(width: 20, height: 20)
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
    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            HStack {
                ZStack {
                    Circle().fill(Color(hex: habit.color).opacity(0.15)).frame(width: 20, height: 20)
                    Image(systemName: habit.icon).font(.system(size: 10)).foregroundColor(Color(hex: habit.color))
                }
                Text(habit.name).font(.system(size: 12, weight: .bold))
                Spacer()
            }
            
            let cols = 52
            let calendar = Calendar.current
            let startOfToday = calendar.startOfDay(for: date)
            // Generate last 52*7 = 364 days.
            let daysArray = (0..<(cols*7)).compactMap { offset in 
                calendar.date(byAdding: .day, value: -(cols*7 - 1) + offset, to: startOfToday)
            }
            
            HStack(spacing: 2) {
                ForEach(0..<cols, id: \.self) { col in
                    VStack(spacing: 2) {
                        ForEach(0..<7, id: \.self) { row in
                            let index = col * 7 + row
                            if index < daysArray.count {
                                let isDone = isCheckedIn(habit: habit, date: daysArray[index], checkins: checkins)
                                RoundedRectangle(cornerRadius: 2)
                                    .fill(isDone ? Color(hex: habit.color) : Color(UIColor.tertiarySystemFill))
                                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                            } else {
                                Color.clear.frame(maxWidth: .infinity, maxHeight: .infinity)
                            }
                        }
                    }
                }
            }
        }
    }
}

struct SingleYearlyWidgetView: View {
    var entry: SimpleEntry
    var body: some View {
        let habit = entry.configuration.selectedHabit.flatMap { h in entry.habits.first(where: { $0.id == h.id }) } ?? entry.habits.first
        VStack {
            if let habit = habit { 
                YearlyHeatmapWidgetView(habit: habit, checkins: entry.checkins, date: entry.date)
            } else {
                Text("No Habit".wTr()).foregroundColor(Color.secondary)
            }
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
        AppIntentConfiguration(kind: "SingleMonthWidget", intent: SelectHabitIntent.self, provider: Provider()) { entry in
            let habit = entry.configuration.selectedHabit.flatMap { h in entry.habits.first(where: { $0.id == h.id }) } ?? entry.habits.first
            VStack { if let habit = habit { MonthCalendarWidgetView(habit: habit, checkins: entry.checkins, date: entry.date) } }.forceAppTheme().containerBackground(for: .widget) { MyWidgetBackground().forceAppTheme() }
        }.configurationDisplayName("Single Habit Month").description("Monthly calendar view for a habit.").supportedFamilies([.systemMedium])
    }
}

struct MultiMonthWidget: Widget {
    var body: some WidgetConfiguration {
        AppIntentConfiguration(kind: "MultiMonthWidget", intent: SelectMultipleHabitsIntent.self, provider: MultipleHabitsProvider()) { entry in
            MultiHabitWeekWidgetView(entry: entry).forceAppTheme().containerBackground(for: .widget) { MyWidgetBackground().forceAppTheme() }
        }.configurationDisplayName("Multi Habit Weekly").description("Compare multiple habits weekly.").supportedFamilies([.systemMedium])
    }
}

struct SingleYearlyWidget: Widget {
    var body: some WidgetConfiguration {
        AppIntentConfiguration(kind: "SingleYearlyWidget", intent: SelectHabitIntent.self, provider: Provider()) { entry in
            SingleYearlyWidgetView(entry: entry).forceAppTheme().containerBackground(for: .widget) { MyWidgetBackground().forceAppTheme() }
        }.configurationDisplayName("Single Habit Yearly").description("Yearly heatmap for a habit.").supportedFamilies([.systemMedium])
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
    var body: some View {
        AmbientBackground()
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
