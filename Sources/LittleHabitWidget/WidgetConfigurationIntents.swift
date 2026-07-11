import AppIntents
import CoreData

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
        await fetchAllHabits()
    }

    func defaultResult() async -> HabitEntity? {
        await fetchAllHabits().first
    }

    @MainActor
    private func fetchAllHabits() -> [HabitEntity] {
        do {
            let context = PersistenceController.shared.container.viewContext
            let fetchRequest: NSFetchRequest<Habit> = Habit.fetchRequest()
            fetchRequest.predicate = NSPredicate(format: "isArchived == NO")
            fetchRequest.sortDescriptors = [NSSortDescriptor(keyPath: \Habit.order, ascending: true)]
            let habits = try context.fetch(fetchRequest)
            return habits.map { HabitEntity(id: $0.id ?? "", name: $0.name ?? "", icon: $0.icon ?? "", color: $0.color ?? "") }
        } catch {
            return []
        }
    }
}

struct SelectHabitIntent: WidgetConfigurationIntent {
    static var title: LocalizedStringResource = "选择单习惯打卡"
    static var description = IntentDescription("为您配置要展示并打卡的习惯")

    @Parameter(title: "习惯名称") var selectedHabit: HabitEntity?

    init() {}

    init(selectedHabit: HabitEntity? = nil) {
        self.selectedHabit = selectedHabit
    }
}

struct SelectMonthHabitIntent: WidgetConfigurationIntent {
    static var title: LocalizedStringResource = "选择月度日历习惯"
    static var description = IntentDescription("为您配置月度日历中追踪的习惯")

    @Parameter(title: "习惯名称") var selectedHabit: HabitEntity?

    init() {}

    init(selectedHabit: HabitEntity? = nil) {
        self.selectedHabit = selectedHabit
    }
}

struct SelectYearlyHabitIntent: WidgetConfigurationIntent {
    static var title: LocalizedStringResource = "选择年度网格习惯"
    static var description = IntentDescription("为您配置年度网格中展示的习惯")

    @Parameter(title: "单习惯(中等尺寸)") var selectedHabit: HabitEntity?
    @Parameter(title: "多习惯清单(大尺寸展示3个)") var habits: [HabitEntity]?

    init() {}

    init(selectedHabit: HabitEntity? = nil, habits: [HabitEntity]? = nil) {
        self.selectedHabit = selectedHabit
        self.habits = habits
    }
}

struct SelectMultipleHabitsIntent: WidgetConfigurationIntent {
    static var title: LocalizedStringResource = "选择多习惯清单"
    static var description = IntentDescription("为您配置顶部展示的多习惯列表")

    @Parameter(title: "习惯清单") var habits: [HabitEntity]?

    init() {}

    init(habits: [HabitEntity]? = nil) {
        self.habits = habits
    }
}
