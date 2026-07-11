import re

# 1. Update Widget schema and init parameters
with open('Sources/LittleHabitWidget/LittleHabitWidget.swift', 'r') as f:
    widget_content = f.read()

widget_content = widget_content.replace('ArchivedHabit.self', 'MoodRecord.self')
# Fix ModelConfiguration parameters in Widget (since iOS 17 SwiftData API might be different)
# It complained: incorrect argument labels in call (have 'schema:isStoredInMemoryOnly:url:', expected '_:schema:url:allowsSave:cloudKitDatabase:')
# Wait, actually ModelConfiguration(_:schema:url:allowsSave:cloudKitDatabase:) is an older beta API?
# Actually in Xcode 15 iOS 17, it's `ModelConfiguration(url: sharedStoreURL)`
# Let's just use `ModelConfiguration(url: sharedStoreURL)` for the widget.
old_config = 'let modelConfiguration = ModelConfiguration(schema: schema, isStoredInMemoryOnly: false, url: sharedStoreURL)'
new_config = 'let modelConfiguration = ModelConfiguration(schema: schema, url: sharedStoreURL)'
widget_content = widget_content.replace(old_config, new_config)

with open('Sources/LittleHabitWidget/LittleHabitWidget.swift', 'w') as f:
    f.write(widget_content)

# 2. Update App's sharedModelContainer to use App Group
with open('Sources/LittleHabitTrackerApp.swift', 'r') as f:
    app_content = f.read()

old_app_container = """    var sharedModelContainer: ModelContainer = {
        let schema = Schema([
            Habit.self,
            Checkin.self,
            MoodRecord.self
        ])
        let modelConfiguration = ModelConfiguration(schema: schema, isStoredInMemoryOnly: false)

        do {
            return try ModelContainer(for: schema, configurations: [modelConfiguration])
        } catch {
            fatalError("Could not create ModelContainer: \\(error)")
        }
    }()"""

new_app_container = """    var sharedModelContainer: ModelContainer = {
        let schema = Schema([
            Habit.self,
            Checkin.self,
            MoodRecord.self
        ])
        let sharedStoreURL = FileManager.default.containerURL(forSecurityApplicationGroupIdentifier: "group.com.littlehabit.tracker")!.appendingPathComponent("shared.store")
        let modelConfiguration = ModelConfiguration(schema: schema, url: sharedStoreURL)

        do {
            return try ModelContainer(for: schema, configurations: [modelConfiguration])
        } catch {
            fatalError("Could not create ModelContainer: \\(error)")
        }
    }()"""

app_content = app_content.replace(old_app_container, new_app_container)

with open('Sources/LittleHabitTrackerApp.swift', 'w') as f:
    f.write(app_content)
