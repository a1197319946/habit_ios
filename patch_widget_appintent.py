with open('Sources/LittleHabitWidget/LittleHabitWidget.swift', 'r') as f:
    content = f.read()

import re

# We will completely replace Provider and LittleHabitWidget main
new_provider = """import AppIntents

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
            fatalError("Could not create ModelContainer: \\(error)")
        }
    }
    
    @MainActor
    func fetchHabits() -> [Habit] {
        let descriptor = FetchDescriptor<Habit>(sortBy: [SortDescriptor(\\.createdAt)])
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
}"""

content = re.sub(r'struct Provider: TimelineProvider \{.*struct SimpleEntry: TimelineEntry \{[^}]+\}', new_provider, content, flags=re.DOTALL)

# Update the widget configuration
new_widget = """@main
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
}"""

content = re.sub(r'@main\nstruct LittleHabitWidget: Widget \{.*\}', new_widget, content, flags=re.DOTALL)

# Update LittleHabitWidgetEntryView to use selectedHabit for small family
# Find the line: SingleHabitWidgetView(habit: entry.habits.first!, checkins: entry.checkins, date: entry.date)
new_small = """                    if let selectedId = entry.configuration.selectedHabit?.id,
                       let selected = entry.habits.first(where: { $0.id == selectedId }) {
                        SingleHabitWidgetView(habit: selected, checkins: entry.checkins, date: entry.date)
                    } else if let first = entry.habits.first {
                        SingleHabitWidgetView(habit: first, checkins: entry.checkins, date: entry.date)
                    } else {
                        Text("No habit")
                    }"""

content = content.replace("SingleHabitWidgetView(habit: entry.habits.first!, checkins: entry.checkins, date: entry.date)", new_small)

with open('Sources/LittleHabitWidget/LittleHabitWidget.swift', 'w') as f:
    f.write(content)
