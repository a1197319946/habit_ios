import SwiftUI
import CoreData
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
            let context = PersistenceController.shared.container.viewContext
            let fetchRequest: NSFetchRequest<Habit> = Habit.fetchRequest()
            fetchRequest.predicate = NSPredicate(format: "id == %@", habitId)
            
            let habits = try context.fetch(fetchRequest)
            if let targetHabit = habits.first {
                let today = Date()
                let dateString = SharedFormatters.dateString(from: today)
                
                let checkinFetch: NSFetchRequest<Checkin> = Checkin.fetchRequest()
                checkinFetch.predicate = NSPredicate(format: "habit.id == %@ AND dateString == %@", habitId, dateString)
                
                let todays = try context.fetch(checkinFetch)
                let fillAmount = targetHabit.goalType == "amount" ? (targetHabit.amountValue > 0 ? targetHabit.amountValue : 1.0) : 1.0
                
                if !todays.isEmpty {
                    todays.forEach { context.delete($0) }
                } else {
                    if targetHabit.goalType == "amount" {
                        return .result()
                    }
                    let newCheckin = Checkin(context: context)
                    newCheckin.dateString = dateString
                    newCheckin.amount = fillAmount
                    newCheckin.habit = targetHabit
                    newCheckin.timestamp = today
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
