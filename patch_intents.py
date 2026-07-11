with open('Sources/LittleHabitWidget/LittleHabitWidget.swift', 'r') as f:
    content = f.read()

new_intents = """
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
                        existing.lastUpdatedAt = today
                    } else {
                        let newCheckin = Checkin(amount: 1, dateString: dateString)
                        modelContainer.mainContext.insert(newCheckin)
                        newCheckin.habit = targetHabit
                    }
                } else {
                    // Daily habit toggle
                    if let existing = todays.first {
                        existing.isCompleted.toggle()
                        existing.lastUpdatedAt = today
                    } else {
                        let newCheckin = Checkin(isCompleted: true, dateString: dateString)
                        modelContainer.mainContext.insert(newCheckin)
                        newCheckin.habit = targetHabit
                    }
                }
                try modelContainer.mainContext.save()
            }
        } catch {
            print("Widget checkin failed: \\(error)")
        }
        return .result()
    }
}
"""

content += new_intents

with open('Sources/LittleHabitWidget/LittleHabitWidget.swift', 'w') as f:
    f.write(content)
