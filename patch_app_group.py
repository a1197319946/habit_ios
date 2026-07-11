import re

with open('Sources/LittleHabitTrackerApp.swift', 'r') as f:
    content = f.read()

old_container = """    let container: ModelContainer = {
        let schema = Schema([Habit.self, Checkin.self, ArchivedHabit.self])
        let modelConfiguration = ModelConfiguration(schema: schema, isStoredInMemoryOnly: false)
        do {
            return try ModelContainer(for: schema, configurations: [modelConfiguration])
        } catch {
            fatalError("Could not create ModelContainer: \\(error)")
        }
    }()"""

new_container = """    let container: ModelContainer = {
        let schema = Schema([Habit.self, Checkin.self, ArchivedHabit.self])
        let sharedStoreURL = FileManager.default.containerURL(forSecurityApplicationGroupIdentifier: "group.com.littlehabit.tracker")!.appendingPathComponent("shared.store")
        let modelConfiguration = ModelConfiguration(schema: schema, isStoredInMemoryOnly: false, url: sharedStoreURL)
        do {
            return try ModelContainer(for: schema, configurations: [modelConfiguration])
        } catch {
            fatalError("Could not create ModelContainer: \\(error)")
        }
    }()"""

content = content.replace(old_container, new_container)

with open('Sources/LittleHabitTrackerApp.swift', 'w') as f:
    f.write(content)
