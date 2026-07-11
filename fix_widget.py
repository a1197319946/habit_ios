import re

with open('Sources/LittleHabitWidget/LittleHabitWidget.swift', 'r') as f:
    code = f.read()

# 1. Add translation helper at the top
helper = """
import Foundation

func getWidgetLanguage() -> String {
    let mode = UserDefaults(suiteName: "group.com.littlehabit.tracker")?.string(forKey: "appLanguage") ?? "system"
    if mode == "zh" { return "zh" }
    if mode == "en" { return "en" }
    if let firstLang = Locale.preferredLanguages.first {
        if firstLang.hasPrefix("zh") { return "zh" }
    }
    return "en"
}

extension String {
    func wTr() -> String {
        let lang = getWidgetLanguage()
        let dict: [String: [String: String]] = [
            "No Habit": ["zh": "暂无习惯", "en": "No Habit"],
            "Select Habits": ["zh": "请选择习惯", "en": "Select Habits"]
        ]
        if let trans = dict[self] {
            return trans[lang] ?? self
        }
        return self
    }
}
"""
code = code.replace("import Foundation\n", helper)

# 2. Fix MultiHabitCheckinWidgetView
old_multi_checkin = """            if selectedHabits.isEmpty {
                Text("Select Habits").foregroundColor(Color.secondary)
            } else {
                ForEach(selectedHabits) { habit in
                    let isDone = isCheckedIn(habit: habit, date: entry.date, checkins: entry.checkins)
                    HStack {
                        ZStack {
                            Circle().fill(Color(hex: habit.color).opacity(0.15)).frame(width: 32, height: 32)
                            Image(systemName: habit.icon).font(.system(size: 16)).foregroundColor(Color(hex: habit.color))
                        }
                        Text(habit.name).font(.system(size: 14, weight: .bold)).lineLimit(1).padding(.leading, 4)
                        Spacer()
                        Button(intent: CheckinHabitIntent(habitId: habit.id)) {
                            ZStack {
                                if isDone {
                                    Image(systemName: "checkmark.circle.fill").font(.system(size: 26)).foregroundColor(.green)
                                } else {
                                    Circle().stroke(Color(hex: habit.color), lineWidth: 2).frame(width: 24, height: 24)
                                }
                            }
                            .frame(width: 32, height: 32)
                        }.buttonStyle(.plain)
                    }"""

new_multi_checkin = """            if selectedHabits.isEmpty {
                Text("Select Habits".wTr()).foregroundColor(Color.secondary)
            } else {
                ForEach(selectedHabits) { habit in
                    let isDone = isCheckedIn(habit: habit, date: entry.date, checkins: entry.checkins)
                    HStack(spacing: 6) {
                        ZStack {
                            Circle().fill(Color(hex: habit.color).opacity(0.15)).frame(width: 28, height: 28)
                            Image(systemName: habit.icon).font(.system(size: 14)).foregroundColor(Color(hex: habit.color))
                        }
                        Text(habit.name).font(.system(size: 14, weight: .bold)).lineLimit(1)
                        Spacer()
                        Button(intent: CheckinHabitIntent(habitId: habit.id)) {
                            ZStack {
                                if isDone {
                                    Image(systemName: "checkmark.circle.fill").font(.system(size: 24)).foregroundColor(.green)
                                } else {
                                    Circle().stroke(Color(hex: habit.color), lineWidth: 2).frame(width: 22, height: 22)
                                }
                            }
                            .frame(width: 28, height: 28)
                        }.buttonStyle(.plain)
                    }"""
code = code.replace(old_multi_checkin, new_multi_checkin)

# 3. Fix MonthCalendarWidgetView
old_month = """    var body: some View {
        let days = getDaysForMonth(date: date)
        let sunFirst = getWidgetFirstWeekday() == 1
        let weekdays = sunFirst ? ["日", "一", "二", "三", "四", "五", "六"] : ["一", "二", "三", "四", "五", "六", "日"]
        
        let monthStr = {
            let f = DateFormatter()
            f.dateFormat = "yyyy年M月"
            return f.string(from: date)
        }()
        
        let todayIsDone = isCheckedIn(habit: habit, date: Date(), checkins: checkins)
        
        HStack(alignment: .firstTextBaseline, spacing: 12) {
            VStack(spacing: 16) {
                Text(monthStr).font(.system(size: 14, weight: .heavy)).foregroundColor(Color.primary).lineLimit(1).minimumScaleFactor(0.8)
                
                ZStack {
                    Circle().stroke(Color(hex: habit.color), lineWidth: 3).frame(width: 60, height: 60)
                    Image(systemName: habit.icon).font(.system(size: 26)).foregroundColor(Color(hex: habit.color))
                }"""

new_month = """    var body: some View {
        let lang = getWidgetLanguage()
        let days = getDaysForMonth(date: date)
        let sunFirst = getWidgetFirstWeekday() == 1
        let weekdaysEn = sunFirst ? ["Sun", "Mon", "Tue", "Wed", "Thu", "Fri", "Sat"] : ["Mon", "Tue", "Wed", "Thu", "Fri", "Sat", "Sun"]
        let weekdaysZh = sunFirst ? ["日", "一", "二", "三", "四", "五", "六"] : ["一", "二", "三", "四", "五", "六", "日"]
        let weekdays = lang == "zh" ? weekdaysZh : weekdaysEn
        
        let monthStr = {
            let f = DateFormatter()
            f.dateFormat = lang == "zh" ? "yyyy年M月" : "MMM yyyy"
            return f.string(from: date)
        }()
        
        let todayIsDone = isCheckedIn(habit: habit, date: Date(), checkins: checkins)
        
        HStack(alignment: .firstTextBaseline, spacing: 12) {
            VStack(spacing: 16) {
                Text(monthStr).font(.system(size: 14, weight: .heavy)).foregroundColor(Color.primary).lineLimit(1).minimumScaleFactor(0.8).padding(.top, 4)
                
                ZStack {
                    Circle().fill(Color(hex: habit.color).opacity(0.15)).frame(width: 52, height: 52)
                    Image(systemName: habit.icon).font(.system(size: 24)).foregroundColor(Color(hex: habit.color))
                }"""
code = code.replace(old_month, new_month)

# 4. Fix MultiHabitWeekWidgetView
old_multi_week = """    var body: some View {
        let days = getDaysForWeek(date: entry.date)
        let sunFirst = getWidgetFirstWeekday() == 1
        let weekdays = sunFirst ? ["日", "一", "二", "三", "四", "五", "六"] : ["一", "二", "三", "四", "五", "六", "日"]
        
        let selectedIds = entry.configuration.habits?.map { $0.id } ?? []
        let selectedHabits = Array(entry.habits.filter { selectedIds.contains($0.id) }.prefix(4))
        
        VStack(spacing: 8) {
            HStack(spacing: 6) {
                Spacer().frame(width: 60)
                Spacer(minLength: 0)
                ForEach(weekdays, id: \.self) { day in
                    Text(day).font(.system(size: 10, weight: .bold)).foregroundColor(Color.secondary)
                        .frame(width: 20)
                }
            }
            
            ForEach(selectedHabits) { habit in
                HStack(spacing: 6) {
                    HStack(spacing: 4) {
                        ZStack {
                            Circle().fill(Color(hex: habit.color).opacity(0.15)).frame(width: 20, height: 20)
                            Image(systemName: habit.icon).font(.system(size: 10)).foregroundColor(Color(hex: habit.color))
                        }
                        Text(habit.name).font(.system(size: 12, weight: .bold)).lineLimit(1)
                        Spacer()
                    }
                    .frame(width: 60, alignment: .leading)"""

new_multi_week = """    var body: some View {
        let lang = getWidgetLanguage()
        let days = getDaysForWeek(date: entry.date)
        let sunFirst = getWidgetFirstWeekday() == 1
        let weekdaysEn = sunFirst ? ["Sun", "Mon", "Tue", "Wed", "Thu", "Fri", "Sat"] : ["Mon", "Tue", "Wed", "Thu", "Fri", "Sat", "Sun"]
        let weekdaysZh = sunFirst ? ["日", "一", "二", "三", "四", "五", "六"] : ["一", "二", "三", "四", "五", "六", "日"]
        let weekdays = lang == "zh" ? weekdaysZh : weekdaysEn
        
        let selectedIds = entry.configuration.habits?.map { $0.id } ?? []
        let selectedHabits = Array(entry.habits.filter { selectedIds.contains($0.id) }.prefix(4))
        
        VStack(spacing: 8) {
            HStack(spacing: 6) {
                Spacer().frame(width: 84)
                Spacer(minLength: 0)
                ForEach(weekdays, id: \.self) { day in
                    Text(day).font(.system(size: 10, weight: .bold)).foregroundColor(Color.secondary)
                        .frame(width: 20)
                }
            }
            
            ForEach(selectedHabits) { habit in
                HStack(spacing: 6) {
                    HStack(spacing: 4) {
                        ZStack {
                            Circle().fill(Color(hex: habit.color).opacity(0.15)).frame(width: 20, height: 20)
                            Image(systemName: habit.icon).font(.system(size: 10)).foregroundColor(Color(hex: habit.color))
                        }
                        Text(habit.name).font(.system(size: 12, weight: .bold)).lineLimit(1)
                        Spacer()
                    }
                    .frame(width: 84, alignment: .leading)"""
code = code.replace(old_multi_week, new_multi_week)

# 5. Fix YearlyHeatmapWidgetView
old_yearly = """    var body: some View {
        let monthGroups = getMonthsForYear(date: date)
        
        let yearStr = {
            let f = DateFormatter()
            f.dateFormat = "yyyy年"
            return f.string(from: date)
        }()
        
        HStack(alignment: .firstTextBaseline, spacing: 12) {
            VStack(spacing: 16) {
                Text(yearStr).font(.system(size: 14, weight: .heavy)).foregroundColor(Color.primary).lineLimit(1).minimumScaleFactor(0.8)"""

new_yearly = """    var body: some View {
        let lang = getWidgetLanguage()
        let monthGroups = getMonthsForYear(date: date)
        
        let yearStr = {
            let f = DateFormatter()
            f.dateFormat = lang == "zh" ? "yyyy年" : "yyyy"
            return f.string(from: date)
        }()
        
        HStack(alignment: .firstTextBaseline, spacing: 12) {
            VStack(spacing: 16) {
                Text(yearStr).font(.system(size: 14, weight: .heavy)).foregroundColor(Color.primary).lineLimit(1).minimumScaleFactor(0.8)"""
code = code.replace(old_yearly, new_yearly)


# 6. Replace `Text("No Habit").foregroundColor(Color.secondary)` in the file with `Text("No Habit".wTr()).foregroundColor(Color.secondary)`
code = code.replace('Text("No Habit").foregroundColor(Color.secondary)', 'Text("No Habit".wTr()).foregroundColor(Color.secondary)')

with open('Sources/LittleHabitWidget/LittleHabitWidget.swift', 'w') as f:
    f.write(code)
