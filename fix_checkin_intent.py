with open('Sources/LittleHabitWidget/LittleHabitWidget.swift', 'r') as f:
    content = f.read()

bad_content = """    func perform() async throws -> some IntentResult {
        let schema = Schema([Habit.self, Checkin.self, MoodRecord.self])
        WidgetCenter.shared.reloadAllTimelines()
        return .result()
    }"""

good_content = """    func perform() async throws -> some IntentResult {
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
                    if let existing = todays.first {
                        existing.amount += 1
                        existing.timestamp = today
                    } else {
                        let newCheckin = Checkin(dateString: dateString, amount: 1)
                        modelContainer.mainContext.insert(newCheckin)
                        newCheckin.habit = targetHabit
                    }
                } else {
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
            print("Widget checkin failed: \\(error)")
        }
        WidgetCenter.shared.reloadAllTimelines()
        return .result()
    }"""

content = content.replace(bad_content, good_content)

with open('Sources/LittleHabitWidget/LittleHabitWidget.swift', 'w') as f:
    f.write(content)
