import SwiftUI
import SwiftData
import AppIntents
import WidgetKit

enum LittleHabitWidgetKind {
    static let multiCheckin = "LittleHabitWidget"
    static let singleCheckin = "NewSingleHabitWidget"
    static let singleMonth = "SingleMonthWidget"
    static let multiWeek = "MultiMonthWidget"
    static let singleYearly = "SingleYearlyWidget"

    static let all = [multiCheckin, singleCheckin, singleMonth, multiWeek, singleYearly]
}

func reloadLittleHabitWidgets() {
    WidgetCenter.shared.reloadAllTimelines()
    for kind in LittleHabitWidgetKind.all {
        WidgetCenter.shared.reloadTimelines(ofKind: kind)
    }
}

final class SharedModelContainerManager {
    static let shared: ModelContainer = {
        let schema = Schema([Habit.self, Checkin.self, MoodRecord.self])
        guard let groupURL = FileManager.default.containerURL(forSecurityApplicationGroupIdentifier: "group.com.littlehabit.tracker") else {
            print("SharedModelContainerManager: App Group container URL is nil! Using fallback.")
            let fallbackConfig = ModelConfiguration(schema: schema, isStoredInMemoryOnly: true)
            return try! ModelContainer(for: schema, configurations: [fallbackConfig])
        }
        let sharedStoreURL = groupURL.appendingPathComponent("shared.store")
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

struct CheckinHabitIntent: AppIntent {
    static var title: LocalizedStringResource = "打卡习惯"
    static var description = IntentDescription("完成指定习惯的一次快捷打卡")
    static var openAppWhenRun: Bool = false
    @Parameter(title: "习惯 ID") var habitId: String?

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
            context.processPendingChanges()
            var descriptor = FetchDescriptor<Habit>()
            descriptor.relationshipKeyPathsForPrefetching = [\.checkins]
            descriptor.includePendingChanges = true
            let habits = try context.fetch(descriptor)
            if let targetHabit = habits.first(where: { $0.id == habitId }) {
                if targetHabit.goalType == "amount" {
                    return .result()
                }
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
                let defaults = UserDefaults(suiteName: "group.com.littlehabit.tracker")
                defaults?.set(Date().timeIntervalSince1970, forKey: "lastWidgetCheckin")
                defaults?.synchronize()
            }
        } catch {
            print("CheckinHabitIntent error: \(error)")
        }
        reloadLittleHabitWidgets()
        Task {
            try? await Task.sleep(nanoseconds: 300_000_000)
            reloadLittleHabitWidgets()
        }
        return .result()
    }
}
