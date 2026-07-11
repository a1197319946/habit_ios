import re

with open('Sources/StatisticsView.swift', 'r') as f:
    content = f.read()

# Update HabitCountItem
old_item = """struct HabitCountItem: Identifiable {
    let id = UUID()
    let habit: Habit
    let value: Double
    var displayString: String {"""
new_item = """struct HabitCountItem: Identifiable {
    let id = UUID()
    let habit: Habit
    let value: Double
    let checkinCount: Int
    var displayString: String {"""
content = content.replace(old_item, new_item)

# Update chartData
old_data = """    private var chartData: [HabitCountItem] {
        habits.compactMap { habit in
            let checks = periodCheckins.filter { $0.habit?.id == habit.id }
            if habit.goalType == "amount" {
                let sum = checks.reduce(0.0) { $0 + $1.amount }
                return sum > 0 ? HabitCountItem(habit: habit, value: sum) : nil
            } else {
                let count = checks.count
                return count > 0 ? HabitCountItem(habit: habit, value: Double(count)) : nil
            }
        }.sorted { $0.value > $1.value }
    }"""
new_data = """    private var chartData: [HabitCountItem] {
        habits.compactMap { habit in
            let checks = periodCheckins.filter { $0.habit?.id == habit.id }
            let count = checks.count
            guard count > 0 else { return nil }
            if habit.goalType == "amount" {
                let sum = checks.reduce(0.0) { $0 + $1.amount }
                return HabitCountItem(habit: habit, value: sum, checkinCount: count)
            } else {
                return HabitCountItem(habit: habit, value: Double(count), checkinCount: count)
            }
        }.sorted { $0.checkinCount > $1.checkinCount }
    }"""
content = content.replace(old_data, new_data)

# Update SectorMark
old_sector = """                            SectorMark(
                                angle: .value("Count", item.value),
                                innerRadius: .ratio(0.75),
                                angularInset: 2.0
                            )"""
new_sector = """                            SectorMark(
                                angle: .value("Count", item.checkinCount),
                                innerRadius: .ratio(0.75),
                                angularInset: 2.0
                            )"""
content = content.replace(old_sector, new_sector)

with open('Sources/StatisticsView.swift', 'w') as f:
    f.write(content)
