import SwiftUI
import SwiftData
import AppIntents
import WidgetKit

final class SharedModelContainerManager {
    static let shared: ModelContainer = {
        let schema = Schema([Habit.self, Checkin.self, MoodRecord.self])
        let sharedStoreURL = FileManager.default.containerURL(forSecurityApplicationGroupIdentifier: "group.com.littlehabit.tracker")?.appendingPathComponent("shared.store") ?? URL.temporaryDirectory.appending(path: "widget.store")
        
        let defaultURL = URL.applicationSupportDirectory.appending(path: "default.store")
        let fileManager = FileManager.default
        let hasMigrated = UserDefaults.standard.bool(forKey: "didMigrateToAppGroup2")
        if !hasMigrated && fileManager.fileExists(atPath: defaultURL.path) {
            do {
                if fileManager.fileExists(atPath: sharedStoreURL.path) { try fileManager.removeItem(at: sharedStoreURL) }
                try fileManager.copyItem(at: defaultURL, to: sharedStoreURL)
                let defaultShmURL = URL.applicationSupportDirectory.appending(path: "default.store-shm")
                let sharedShmURL = FileManager.default.containerURL(forSecurityApplicationGroupIdentifier: "group.com.littlehabit.tracker")!.appendingPathComponent("shared.store-shm")
                if fileManager.fileExists(atPath: sharedShmURL.path) { try fileManager.removeItem(at: sharedShmURL) }
                if fileManager.fileExists(atPath: defaultShmURL.path) { try fileManager.copyItem(at: defaultShmURL, to: sharedShmURL) }
                let defaultWalURL = URL.applicationSupportDirectory.appending(path: "default.store-wal")
                let sharedWalURL = FileManager.default.containerURL(forSecurityApplicationGroupIdentifier: "group.com.littlehabit.tracker")!.appendingPathComponent("shared.store-wal")
                if fileManager.fileExists(atPath: sharedWalURL.path) { try fileManager.removeItem(at: sharedWalURL) }
                if fileManager.fileExists(atPath: defaultWalURL.path) { try fileManager.copyItem(at: defaultWalURL, to: sharedWalURL) }
                UserDefaults.standard.set(true, forKey: "didMigrateToAppGroup2")
            } catch {}
        }
        
        let modelConfiguration = ModelConfiguration(schema: schema, url: sharedStoreURL)
        do {
            return try ModelContainer(for: schema, configurations: [modelConfiguration])
        } catch {
            print("SharedModelContainerManager error creating container: \(error)")
            let fallbackConfig = ModelConfiguration(schema: schema, isStoredInMemoryOnly: true)
            return try! ModelContainer(for: schema, configurations: [fallbackConfig])
        }
    }()
    
    @MainActor
    static var mainContext: ModelContext {
        shared.mainContext
    }
}

func getAppGroupModelContainer() -> ModelContainer {
    return SharedModelContainerManager.shared
}

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
        return await fetchAllHabits().first
    }

    @MainActor
    private func fetchAllHabits() -> [HabitEntity] {
        do {
            let context = SharedModelContainerManager.mainContext
            var descriptor = FetchDescriptor<Habit>(predicate: #Predicate<Habit> { $0.isArchived == false }, sortBy: [SortDescriptor(\.order)])
            descriptor.includePendingChanges = true
            let habits = try context.fetch(descriptor)
            return habits.filter { !$0.isArchived }.map { HabitEntity(id: $0.id, name: $0.name, icon: $0.icon, color: $0.color) }
        } catch {
            return []
        }
    }
}

struct SelectHabitIntent: WidgetConfigurationIntent {
    static var title: LocalizedStringResource = "Select Habit"
    @Parameter(title: "Habit") var selectedHabit: HabitEntity?

    init() {}
    init(selectedHabit: HabitEntity? = nil) {
        self.selectedHabit = selectedHabit
    }
}

struct SelectMonthHabitIntent: WidgetConfigurationIntent {
    static var title: LocalizedStringResource = "Select Habit"
    @Parameter(title: "Habit") var selectedHabit: HabitEntity?

    init() {}
    init(selectedHabit: HabitEntity? = nil) {
        self.selectedHabit = selectedHabit
    }
}

struct SelectYearlyHabitIntent: WidgetConfigurationIntent {
    static var title: LocalizedStringResource = "Select Habit"
    @Parameter(title: "Habit") var selectedHabit: HabitEntity?

    init() {}
    init(selectedHabit: HabitEntity? = nil) {
        self.selectedHabit = selectedHabit
    }
}

struct SelectMultipleHabitsIntent: WidgetConfigurationIntent {
    static var title: LocalizedStringResource = "Select Multiple Habits"
    @Parameter(title: "Habits") var habits: [HabitEntity]?

    init() {}
    init(habits: [HabitEntity]? = nil) {
        self.habits = habits
    }
}

struct CheckinHabitIntent: AppIntent {
    static var title: LocalizedStringResource = "Check in Habit"
    static var openAppWhenRun: Bool = false
    @Parameter(title: "Habit ID") var habitId: String?

    init() {}
    init(habitId: String) { self.habitId = habitId }

    @MainActor
    func perform() async throws -> some IntentResult {
        guard let habitId = habitId, !habitId.isEmpty else {
            print("CheckinHabitIntent error: habitId is nil or empty!")
            return .result()
        }
        do {
            let context = SharedModelContainerManager.mainContext
            var descriptor = FetchDescriptor<Habit>()
            descriptor.relationshipKeyPathsForPrefetching = [\.checkins]
            descriptor.includePendingChanges = true
            let habits = try context.fetch(descriptor)
            if let targetHabit = habits.first(where: { $0.id == habitId }) {
                let today = Date()
                let dateString = {
                    let formatter = DateFormatter()
                    formatter.dateFormat = "yyyy-MM-dd"
                    return formatter.string(from: today)
                }()
                var descriptorCheckins = FetchDescriptor<Checkin>()
                descriptorCheckins.relationshipKeyPathsForPrefetching = [\.habit]
                descriptorCheckins.includePendingChanges = true
                let allCheckins = try context.fetch(descriptorCheckins)
                let hc = targetHabit.checkins ?? []
                let todaysFromHabit = hc.filter { $0.dateString == dateString }
                let todaysFromGlobal = allCheckins.filter { $0.habit?.id == habitId && $0.dateString == dateString }
                let allTodaysIds = Set(todaysFromHabit.map { $0.id }).union(todaysFromGlobal.map { $0.id })
                let todays = allCheckins.filter { allTodaysIds.contains($0.id) }
                let fillAmount = targetHabit.goalType == "amount" ? (targetHabit.amountValue > 0 ? targetHabit.amountValue : 1.0) : 1.0
                if !todays.isEmpty {
                    todays.forEach { checkinToDelete in
                        if let idx = targetHabit.checkins?.firstIndex(where: { $0.id == checkinToDelete.id }) {
                            targetHabit.checkins?.remove(at: idx)
                        }
                        context.delete(checkinToDelete)
                    }
                } else {
                    let newCheckin = Checkin(dateString: dateString, amount: fillAmount)
                    newCheckin.habit = targetHabit
                    newCheckin.timestamp = today
                    context.insert(newCheckin)
                    if targetHabit.checkins == nil {
                        targetHabit.checkins = [newCheckin]
                    } else if !targetHabit.checkins!.contains(where: { $0.id == newCheckin.id }) {
                        targetHabit.checkins?.append(newCheckin)
                    }
                }
                try context.save()
                UserDefaults(suiteName: "group.com.littlehabit.tracker")?.set(Date().timeIntervalSince1970, forKey: "lastWidgetCheckin")
            }
        } catch {
            print("CheckinHabitIntent error: \(error)")
        }
        WidgetCenter.shared.reloadAllTimelines()
        return .result()
    }
}
