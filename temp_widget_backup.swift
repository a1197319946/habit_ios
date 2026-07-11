import WidgetKit
import SwiftUI
import SwiftData

import AppIntents

struct Provider: AppIntentTimelineProvider {
    // Shared model container
    let modelContainer: ModelContainer
    
    init() {
        let schema = Schema([Habit.self, Checkin.self, MoodRecord.self])
        guard let sharedStoreURL = FileManager.default.containerURL(forSecurityApplicationGroupIdentifier: "group.com.littlehabit.tracker")?.appendingPathComponent("shared.store") else {
            fatalError("Could not get shared store URL")
        }
        let modelConfiguration = ModelConfiguration(schema: schema, url: sharedStoreURL)
        do {
            modelContainer = try ModelContainer(for: schema, configurations: [modelConfiguration])
        } catch {
            fatalError("Could not create ModelContainer: \(error)")
        }
    }
    
    @MainActor
    func fetchHabits() -> [Habit] {
        let descriptor = FetchDescriptor<Habit>(sortBy: [SortDescriptor(\.createdAt)])
        do {
            return try modelContainer.mainContext.fetch(descriptor)
        } catch {
            return []
        }
    }
    
    @MainActor
    func fetchCheckins() -> [Checkin] {
        let descriptor = FetchDescriptor<Checkin>()
        do {
            return try modelContainer.mainContext.fetch(descriptor)
        } catch {
            return []
        }
    }

    func placeholder(in context: Context) -> SimpleEntry {
        SimpleEntry(date: Date(), configuration: SelectHabitIntent(), habits: [], checkins: [])
    }

    @MainActor
    func snapshot(for configuration: SelectHabitIntent, in context: Context) async -> SimpleEntry {
        let entry = SimpleEntry(date: Date(), configuration: configuration, habits: fetchHabits(), checkins: fetchCheckins())
        return entry
    }

    @MainActor
    func timeline(for configuration: SelectHabitIntent, in context: Context) async -> Timeline<SimpleEntry> {
        let entry = SimpleEntry(date: Date(), configuration: configuration, habits: fetchHabits(), checkins: fetchCheckins())
        // Refresh every hour
        let nextUpdate = Calendar.current.date(byAdding: .hour, value: 1, to: Date())!
        return Timeline(entries: [entry], policy: .after(nextUpdate))
    }
}

struct SimpleEntry: TimelineEntry {
    let date: Date
    let configuration: SelectHabitIntent
    let habits: [Habit]
    let checkins: [Checkin]
}

struct LittleHabitWidgetEntryView : View {
    var entry: Provider.Entry
    @Environment(\.widgetFamily) var family

    var body: some View {
        ZStack {
            DS.bgPrimary
            
            if entry.habits.isEmpty {
                VStack(spacing: 8) {
                    Image(systemName: "plus.circle")
                        .font(.system(size: 24))
                        .foregroundColor(DS.outline)
                    Text("No habits yet")
                        .font(.system(size: 14, weight: .medium))
                        .foregroundColor(DS.textTertiary)
                }
            } else {
                switch family {
                case .systemSmall:
                    // Single Habit Focus
                                        if let selectedId = entry.configuration.selectedHabit?.id,
                       let selected = entry.habits.first(where: { $0.id == selectedId }) {
                        SingleHabitWidgetView(habit: selected, checkins: entry.checkins, date: entry.date)
                    } else if let first = entry.habits.first {
                        SingleHabitWidgetView(habit: first, checkins: entry.checkins, date: entry.date)
                    } else {
                        Text("No habit")
                    }
                case .systemMedium:
                    // Multi Habit List
                    MultiHabitWidgetView(habits: entry.habits, checkins: entry.checkins, date: entry.date)
                case .systemLarge:
                    // Multi Habit Month Grid
                    MonthGridWidgetView(habits: entry.habits, checkins: entry.checkins, date: entry.date)
                @unknown default:
                                        if let selectedId = entry.configuration.selectedHabit?.id,
                       let selected = entry.habits.first(where: { $0.id == selectedId }) {
                        SingleHabitWidgetView(habit: selected, checkins: entry.checkins, date: entry.date)
                    } else if let first = entry.habits.first {
                        SingleHabitWidgetView(habit: first, checkins: entry.checkins, date: entry.date)
                    } else {
                        Text("No habit")
                    }
                }
            }
        }
    }
}

// MARK: - Sub Views

struct SingleHabitWidgetView: View {
    let habit: Habit
    let checkins: [Checkin]
    let date: Date
    
    var progress: Double {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        let dateString = formatter.string(from: date)
        let todays = checkins.filter { $0.habit?.id == habit.id && $0.dateString == dateString }
        if habit.goalType == "amount" {
            let sum = todays.reduce(0) { $0 + $1.amount }
            return min(1.0, sum / habit.amountValue)
        } else {
            return !todays.isEmpty ? 1.0 : 0.0
        }
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                ZStack {
                    Circle()
                        .fill(Color(hex: habit.color).opacity(0.15))
                        .frame(width: 40, height: 40)
                    Image(systemName: habit.icon)
                        .font(.system(size: 18))
                        .foregroundColor(Color(hex: habit.color))
                }
                Spacer()
                if progress >= 1.0 {
                    Image(systemName: "checkmark.circle.fill")
                        .foregroundColor(Color(hex: habit.color))
                        .font(.system(size: 20))
                }
            }
            
            Spacer()
            
            Text(habit.name)
                .font(.system(size: 16, weight: .bold))
                .foregroundColor(DS.onSurface)
                .lineLimit(1)
            
            // Progress bar
            GeometryReader { geo in
                ZStack(alignment: .leading) {
                    Capsule()
                        .fill(DS.surfaceVariant)
                        .frame(height: 6)
                    Capsule()
                        .fill(Color(hex: habit.color))
                        .frame(width: max(0, geo.size.width * CGFloat(progress)), height: 6)
                }
            }
            .frame(height: 6)
        }
        .padding()
    }
}

struct MultiHabitWidgetView: View {
    let habits: [Habit]
    let checkins: [Checkin]
    let date: Date
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Today's Habits")
                .font(.system(size: 14, weight: .bold))
                .foregroundColor(DS.textSecondary)
                .padding(.bottom, 4)
            
            ForEach(habits.prefix(3)) { habit in
                HStack {
                    ZStack {
                        Circle()
                            .fill(Color(hex: habit.color).opacity(0.15))
                            .frame(width: 28, height: 28)
                        Image(systemName: habit.icon)
                            .font(.system(size: 12))
                            .foregroundColor(Color(hex: habit.color))
                    }
                    Text(habit.name)
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundColor(DS.onSurface)
                        .lineLimit(1)
                    Spacer()
                    
                    let formatter = DateFormatter()
                    let _ = formatter.dateFormat = "yyyy-MM-dd"
                    let dateString = formatter.string(from: date)
                    let todays = checkins.filter { $0.habit?.id == habit.id && $0.dateString == dateString }
                    let isDone = habit.goalType == "amount" ? (todays.reduce(0){$0 + $1.amount} >= habit.amountValue) : !todays.isEmpty
                    
                    if isDone {
                        Image(systemName: "checkmark")
                            .font(.system(size: 14, weight: .bold))
                            .foregroundColor(Color(hex: habit.color))
                    } else {
                        Circle()
                            .stroke(DS.outline, lineWidth: 2)
                            .frame(width: 16, height: 16)
                    }
                }
            }
            Spacer(minLength: 0)
        }
        .padding()
    }
}

struct MonthGridWidgetView: View {
    let habits: [Habit]
    let checkins: [Checkin]
    let date: Date
    
    var body: some View {
        VStack(alignment: .leading) {
            Text("Monthly Overview")
                .font(.system(size: 16, weight: .bold))
                .foregroundColor(DS.textPrimary)
                .padding(.bottom, 8)
                
            HStack(alignment: .top, spacing: 16) {
                ForEach(habits.prefix(2)) { habit in
                    VStack(alignment: .leading, spacing: 4) {
                        HStack {
                            Circle()
                                .fill(Color(hex: habit.color))
                                .frame(width: 12, height: 12)
                            Text(habit.name)
                                .font(.system(size: 12, weight: .semibold))
                                .foregroundColor(DS.textSecondary)
                                .lineLimit(1)
                        }
                        
                        // Fake mini grid for visual representation
                        let cols = Array(repeating: GridItem(.flexible(), spacing: 2), count: 7)
                        LazyVGrid(columns: cols, spacing: 2) {
                            ForEach(0..<28, id: \.self) { i in
                                RoundedRectangle(cornerRadius: 2)
                                    .fill(i % 3 == 0 ? Color(hex: habit.color) : DS.gridEmpty)
                                    .aspectRatio(1, contentMode: .fit)
                            }
                        }
                    }
                }
            }
            Spacer()
        }
        .padding()
    }
}

struct LittleHabitWidget: Widget {
    let kind: String = "LittleHabitWidget"

    var body: some WidgetConfiguration {
        AppIntentConfiguration(kind: kind, intent: SelectHabitIntent.self, provider: Provider()) { entry in
            LittleHabitWidgetEntryView(entry: entry)
                // iOS 17 containerBackground
                .containerBackground(for: .widget) {
                    DS.bgPrimary
                }
        }
        .configurationDisplayName("Little Habit Tracker")
        .description("Track your habits at a glance.")
        .supportedFamilies([.systemSmall, .systemMedium, .systemLarge])
    }
}


// MARK: - App Intents
import AppIntents
import SwiftData
import Foundation

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

    func suggestedEntities() async throws -> [HabitEntity] {
        return await fetchAllHabits()
    }
    
    func defaultResult() async -> HabitEntity? {
        return try? await suggestedEntities().first
    }

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
    static var description = IntentDescription("Select which habit you want to track.")

    @Parameter(title: "Habit")
    var selectedHabit: HabitEntity?
}

struct SelectTwoHabitsIntent: WidgetConfigurationIntent {
    static var title: LocalizedStringResource = "Select Two Habits"
    static var description = IntentDescription("Select two habits to track side by side.")

    @Parameter(title: "First Habit")
    var habit1: HabitEntity?

    @Parameter(title: "Second Habit")
    var habit2: HabitEntity?
}

struct SelectMultipleHabitsIntent: WidgetConfigurationIntent {
    static var title: LocalizedStringResource = "Select Multiple Habits"
    static var description = IntentDescription("Select multiple habits to track.")

    @Parameter(title: "Habits")
    var habits: [HabitEntity]?
}

struct CheckinHabitIntent: AppIntent {
    static var title: LocalizedStringResource = "Check in Habit"
    
    @Parameter(title: "Habit ID")
    var habitId: String

    init() {}

    init(habitId: String) {
        self.habitId = habitId
    }

    @MainActor
    func perform() async throws -> some IntentResult {
        let schema = Schema([Habit.self, Checkin.self, MoodRecord.self])
        guard let sharedStoreURL = FileManager.default.containerURL(forSecurityApplicationGroupIdentifier: "group.com.littlehabit.tracker")?.appendingPathComponent("shared.store") else {
            return .result()
        }
        let modelConfiguration = ModelConfiguration(schema: schema, url: sharedStoreURL)
        
        do {
            let modelContainer = try ModelContainer(for: schema, configurations: [modelConfiguration])
            let descriptor = FetchDescriptor<Habit>()
            let habits = try modelContainer.mainContext.fetch(descriptor)
            
            if let targetHabit = habits.first(where: { $0.id == habitId }) {
                // Perform checkin
                let today = Date()
                let dateString = {
                    let formatter = DateFormatter()
                    formatter.dateFormat = "yyyy-MM-dd"
                    return formatter.string(from: today)
                }()
                
                let descriptorCheckins = FetchDescriptor<Checkin>()
                let allCheckins = try modelContainer.mainContext.fetch(descriptorCheckins)
                let todays = allCheckins.filter { $0.habit?.id == habitId && $0.dateString == dateString }
                
                if targetHabit.frequencyType == "weekly" || targetHabit.frequencyType == "monthly" {
                    // For amount habits, widget checkin adds 1 unit by default.
                    if let existing = todays.first {
                        existing.amount += 1
                        existing.timestamp = today
                    } else {
                        let newCheckin = Checkin(dateString: dateString, amount: 1)
                        modelContainer.mainContext.insert(newCheckin)
                        newCheckin.habit = targetHabit
                    }
                } else {
                    // Daily habit toggle
                    if let existing = todays.first {
                        existing.amount = existing.amount > 0 ? 0 : 1
                        existing.timestamp = today
                    } else {
                        let newCheckin = Checkin(dateString: dateString, amount: 1)
                        modelContainer.mainContext.insert(newCheckin)
                        newCheckin.habit = targetHabit
                    }
                }
                try modelContainer.mainContext.save()
            }
        } catch {
            print("Widget checkin failed: \(error)")
        }
        return .result()
    }
}

import WidgetKit
import SwiftUI
import AppIntents
import SwiftData

// MARK: - Providers
struct TwoHabitsProvider: AppIntentTimelineProvider {
    let modelContainer: ModelContainer
    init() {
        let schema = Schema([Habit.self, Checkin.self, MoodRecord.self])
        let sharedStoreURL = FileManager.default.containerURL(forSecurityApplicationGroupIdentifier: "group.com.littlehabit.tracker")!.appendingPathComponent("shared.store")
        modelContainer = try! ModelContainer(for: schema, configurations: [ModelConfiguration(schema: schema, url: sharedStoreURL)])
    }
    
    @MainActor func fetchHabits() -> [Habit] {
        return (try? modelContainer.mainContext.fetch(FetchDescriptor<Habit>())) ?? []
    }
    
    @MainActor func fetchCheckins() -> [Checkin] {
        return (try? modelContainer.mainContext.fetch(FetchDescriptor<Checkin>())) ?? []
    }

    func placeholder(in context: Context) -> TwoHabitsEntry {
        TwoHabitsEntry(date: Date(), configuration: SelectTwoHabitsIntent(), habits: [], checkins: [])
    }
    @MainActor func snapshot(for configuration: SelectTwoHabitsIntent, in context: Context) async -> TwoHabitsEntry {
        TwoHabitsEntry(date: Date(), configuration: configuration, habits: fetchHabits(), checkins: fetchCheckins())
    }
    @MainActor func timeline(for configuration: SelectTwoHabitsIntent, in context: Context) async -> Timeline<TwoHabitsEntry> {
        let entry = TwoHabitsEntry(date: Date(), configuration: configuration, habits: fetchHabits(), checkins: fetchCheckins())
        return Timeline(entries: [entry], policy: .after(Calendar.current.date(byAdding: .hour, value: 1, to: Date())!))
    }
}
struct TwoHabitsEntry: TimelineEntry {
    let date: Date
    let configuration: SelectTwoHabitsIntent
    let habits: [Habit]
    let checkins: [Checkin]
}

struct MultipleHabitsProvider: AppIntentTimelineProvider {
    let modelContainer: ModelContainer
    init() {
        let schema = Schema([Habit.self, Checkin.self, MoodRecord.self])
        let sharedStoreURL = FileManager.default.containerURL(forSecurityApplicationGroupIdentifier: "group.com.littlehabit.tracker")!.appendingPathComponent("shared.store")
        modelContainer = try! ModelContainer(for: schema, configurations: [ModelConfiguration(schema: schema, url: sharedStoreURL)])
    }
    
    @MainActor func fetchHabits() -> [Habit] {
        return (try? modelContainer.mainContext.fetch(FetchDescriptor<Habit>())) ?? []
    }
    
    @MainActor func fetchCheckins() -> [Checkin] {
        return (try? modelContainer.mainContext.fetch(FetchDescriptor<Checkin>())) ?? []
    }

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
struct MultipleHabitsEntry: TimelineEntry {
    let date: Date
    let configuration: SelectMultipleHabitsIntent
    let habits: [Habit]
    let checkins: [Checkin]
}

// MARK: - Single Month Widget
struct SingleMonthWidget: Widget {
    var body: some WidgetConfiguration {
        AppIntentConfiguration(kind: "SingleMonthWidget", intent: SelectHabitIntent.self, provider: Provider()) { entry in
            SingleMonthWidgetView(entry: entry)
                .containerBackground(for: .widget) { DS.bgPrimary }
        }
        .configurationDisplayName("Single Habit Month")
        .description("Monthly calendar view for a habit.")
        .supportedFamilies([.systemSmall, .systemMedium])
    }
}
struct SingleMonthWidgetView: View {
    var entry: SimpleEntry
    var body: some View {
        if let selectedId = entry.configuration.selectedHabit?.id, let habit = entry.habits.first(where: { $0.id == selectedId }) {
            MonthCalendarWidgetView(habit: habit, checkins: entry.checkins, date: entry.date)
        } else if let habit = entry.habits.first {
            MonthCalendarWidgetView(habit: habit, checkins: entry.checkins, date: entry.date)
        } else {
            Text("No Habit Selected")
        }
    }
}

// MARK: - Multi Month Widget
struct MultiMonthWidget: Widget {
    var body: some WidgetConfiguration {
        AppIntentConfiguration(kind: "MultiMonthWidget", intent: SelectTwoHabitsIntent.self, provider: TwoHabitsProvider()) { entry in
            MultiMonthWidgetView(entry: entry)
                .containerBackground(for: .widget) { DS.bgPrimary }
        }
        .configurationDisplayName("Multi Habit Month")
        .description("Compare two habits monthly.")
        .supportedFamilies([.systemMedium, .systemLarge])
    }
}
struct MultiMonthWidgetView: View {
    var entry: TwoHabitsEntry
    var body: some View {
        HStack {
            if let h1 = entry.habits.first(where: { $0.id == entry.configuration.habit1?.id }) {
                MonthCalendarWidgetView(habit: h1, checkins: entry.checkins, date: entry.date)
            } else {
                Text("Select Habit 1")
            }
            Divider()
            if let h2 = entry.habits.first(where: { $0.id == entry.configuration.habit2?.id }) {
                MonthCalendarWidgetView(habit: h2, checkins: entry.checkins, date: entry.date)
            } else {
                Text("Select Habit 2")
            }
        }
    }
}

// MARK: - Single Yearly Widget
struct SingleYearlyWidget: Widget {
    var body: some WidgetConfiguration {
        AppIntentConfiguration(kind: "SingleYearlyWidget", intent: SelectHabitIntent.self, provider: Provider()) { entry in
            SingleYearlyWidgetView(entry: entry)
                .containerBackground(for: .widget) { DS.bgPrimary }
        }
        .configurationDisplayName("Single Habit Yearly")
        .description("Yearly heatmap for a habit.")
        .supportedFamilies([.systemMedium, .systemLarge])
    }
}
struct SingleYearlyWidgetView: View {
    var entry: SimpleEntry
    var body: some View {
        if let selectedId = entry.configuration.selectedHabit?.id, let habit = entry.habits.first(where: { $0.id == selectedId }) {
            YearlyHeatmapWidgetView(habit: habit, checkins: entry.checkins, date: entry.date)
        } else if let habit = entry.habits.first {
            YearlyHeatmapWidgetView(habit: habit, checkins: entry.checkins, date: entry.date)
        } else {
            Text("No Habit Selected")
        }
    }
}

// MARK: - Multi Yearly Widget
struct MultiYearlyWidget: Widget {
    var body: some WidgetConfiguration {
        AppIntentConfiguration(kind: "MultiYearlyWidget", intent: SelectMultipleHabitsIntent.self, provider: MultipleHabitsProvider()) { entry in
            MultiYearlyWidgetView(entry: entry)
                .containerBackground(for: .widget) { DS.bgPrimary }
        }
        .configurationDisplayName("Multi Habit Yearly")
        .description("Yearly heatmaps for multiple habits.")
        .supportedFamilies([.systemLarge])
    }
}
struct MultiYearlyWidgetView: View {
    var entry: MultipleHabitsEntry
    var body: some View {
        let selectedIds = entry.configuration.habits?.map { $0.id } ?? []
        let selectedHabits = entry.habits.filter { selectedIds.contains($0.id) }
        VStack {
            if selectedHabits.isEmpty {
                Text("Select Habits")
            } else {
                ForEach(selectedHabits.prefix(3), id: \.id) { habit in
                    YearlyHeatmapWidgetView(habit: habit, checkins: entry.checkins, date: entry.date)
                    if habit.id != selectedHabits.prefix(3).last?.id {
                        Divider()
                    }
                }
            }
        }
    }
}

// MARK: - Widget Reusable Views
struct MonthCalendarWidgetView: View {
    var habit: Habit
    var checkins: [Checkin]
    var date: Date
    
    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            HStack {
                Text(habit.icon)
                Text(habit.name).font(.system(size: 14, weight: .bold))
                Spacer()
            }
            let monthCheckins = checkins.filter { $0.habit?.id == habit.id }
            let color = Color(hex: habit.color)
            
            // Simplified Month View for Widget
            let daysInMonth = 30
            let columns = Array(repeating: GridItem(.flexible(), spacing: 2), count: 7)
            LazyVGrid(columns: columns, spacing: 2) {
                ForEach(1...daysInMonth, id: \.self) { day in
                    RoundedRectangle(cornerRadius: 4)
                        .fill(monthCheckins.count > day % 5 ? color : color.opacity(0.1)) // Mock logic for display
                        .aspectRatio(1, contentMode: .fit)
                }
            }
        }
        .padding(.vertical, 4)
    }
}

struct YearlyHeatmapWidgetView: View {
    var habit: Habit
    var checkins: [Checkin]
    var date: Date
    
    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            HStack {
                Text(habit.icon)
                Text(habit.name).font(.system(size: 14, weight: .bold))
                Spacer()
            }
            let color = Color(hex: habit.color)
            
            // Simplified Yearly Heatmap View for Widget
            let weeks = 20
            let columns = Array(repeating: GridItem(.flexible(), spacing: 2), count: weeks)
            LazyVGrid(columns: columns, spacing: 2) {
                ForEach(1...(weeks * 7), id: \.self) { day in
                    RoundedRectangle(cornerRadius: 2)
                        .fill(day % 7 == 0 ? color : color.opacity(0.1)) // Mock logic for display
                        .aspectRatio(1, contentMode: .fit)
                }
            }
        }
        .padding(.vertical, 4)
    }
}

import WidgetKit
import SwiftUI

@main
struct LittleHabitWidgetBundle: WidgetBundle {
    var body: some Widget {
        LittleHabitWidget()          // Single Checkin
        SingleMonthWidget()          // Single Month
        MultiMonthWidget()           // Multi Month
        SingleYearlyWidget()         // Single Yearly
        MultiYearlyWidget()          // Multi Yearly
    }
}
