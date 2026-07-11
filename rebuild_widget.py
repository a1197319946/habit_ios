with open('temp_widget_backup.swift', 'r') as f:
    lines = f.readlines()

# Part 1: lines 1 to 119
part1 = "".join(lines[0:119])

# Part 2: lines 295 to 513
part2 = "".join(lines[294:513])

custom_views = """
// MARK: - Widget Helpers
func getDaysForMonth(date: Date) -> [Date?] {
    var calendar = Calendar.current
    calendar.firstWeekday = 2 // Monday
    let components = calendar.dateComponents([.year, .month], from: date)
    guard let startOfMonth = calendar.date(from: components),
          let range = calendar.range(of: .day, in: .month, for: startOfMonth) else { return [] }
    
    let firstWeekday = calendar.component(.weekday, from: startOfMonth)
    let offset = (firstWeekday - calendar.firstWeekday + 7) % 7
    
    var days: [Date?] = Array(repeating: nil, count: offset)
    for day in 1...range.count {
        if let d = calendar.date(byAdding: .day, value: day - 1, to: startOfMonth) {
            days.append(d)
        }
    }
    while days.count % 7 != 0 {
        days.append(nil)
    }
    return days
}

func isCheckedIn(habit: Habit, date: Date, checkins: [Checkin]) -> Bool {
    let formatter = DateFormatter()
    formatter.dateFormat = "yyyy-MM-dd"
    let dateStr = formatter.string(from: date)
    let todays = checkins.filter { $0.habit?.id == habit.id && $0.dateString == dateStr }
    if habit.goalType == "amount" {
        return todays.reduce(0) { $0 + $1.amount } >= habit.amountValue
    }
    return !todays.isEmpty
}

// MARK: - Views
struct SingleHabitWidgetView: View {
    let habit: Habit
    let checkins: [Checkin]
    let date: Date
    var body: some View {
        let isDone = isCheckedIn(habit: habit, date: date, checkins: checkins)
        VStack(alignment: .leading) {
            HStack(alignment: .top) {
                VStack(alignment: .leading, spacing: 4) {
                    HStack(spacing: 4) {
                        Text(habit.icon)
                        Text(habit.name).font(.system(size: 16, weight: .bold)).lineLimit(1)
                    }
                    let count = checkins.filter { $0.habit?.id == habit.id }.reduce(0){ $0 + $1.amount }
                    let suffix = habit.frequencyType == "daily" ? "次" : habit.targetUnit
                    Text("\\(Int(count)) \\(suffix)")
                        .font(.system(size: 12))
                        .opacity(0.8)
                }
                Spacer()
                Button(intent: CheckinHabitIntent(habitId: habit.id)) {
                    Image(systemName: isDone ? "checkmark.circle.fill" : "bolt.fill")
                        .font(.system(size: 20))
                        .foregroundColor(isDone ? .black.opacity(0.3) : .black)
                }
                .buttonStyle(.plain)
            }
            .foregroundColor(.black)
            Spacer()
        }
        .padding()
    }
}

struct MonthCalendarWidgetView: View {
    var habit: Habit
    var checkins: [Checkin]
    var date: Date
    var body: some View {
        let days = getDaysForMonth(date: date)
        let formatter = DateFormatter()
        formatter.dateFormat = "M月"
        let monthStr = formatter.string(from: date)
        HStack(spacing: 16) {
            VStack(alignment: .leading, spacing: 4) {
                HStack {
                    Text(habit.icon)
                    Text(habit.name).font(.system(size: 16, weight: .bold))
                }
                Text("最近: 今日").font(.system(size: 10)).foregroundColor(.gray)
                Spacer()
                let count = checkins.filter { $0.habit?.id == habit.id }.reduce(0){ $0 + $1.amount }
                HStack(alignment: .lastTextBaseline, spacing: 2) {
                    Text("\\(Int(count))").font(.system(size: 28, weight: .bold)).foregroundColor(Color(hex: habit.color))
                    Text("次").font(.system(size: 10)).foregroundColor(.gray)
                }
            }
            VStack(spacing: 4) {
                HStack {
                    Text(monthStr).font(.system(size: 14, weight: .bold))
                    Spacer()
                    Text("本月").font(.system(size: 12)).foregroundColor(Color(hex: habit.color))
                }
                HStack(spacing: 4) {
                    ForEach(["一","二","三","四","五","六","日"], id: \\.self) { day in
                        Text(day).font(.system(size: 10)).foregroundColor(.gray).frame(maxWidth: .infinity)
                    }
                }
                let rows = days.count / 7
                VStack(spacing: 4) {
                    ForEach(0..<rows, id: \\.self) { row in
                        HStack(spacing: 4) {
                            ForEach(0..<7, id: \\.self) { col in
                                let index = row * 7 + col
                                if let dayDate = days[index] {
                                    let isDone = isCheckedIn(habit: habit, date: dayDate, checkins: checkins)
                                    let dayStr = "\\(Calendar.current.component(.day, from: dayDate))"
                                    ZStack {
                                        RoundedRectangle(cornerRadius: 4).fill(isDone ? Color(hex: habit.color) : Color.clear)
                                        Text(dayStr).font(.system(size: 10, weight: isDone ? .bold : .regular)).foregroundColor(isDone ? .white : .gray)
                                    }.aspectRatio(1, contentMode: .fit)
                                } else {
                                    Color.clear.aspectRatio(1, contentMode: .fit)
                                }
                            }
                        }
                    }
                }
            }
        }.padding()
    }
}

struct MultiMonthWidgetView: View {
    var entry: TwoHabitsEntry
    var body: some View {
        VStack(spacing: 8) {
            HStack {
                let formatter = DateFormatter()
                formatter.dateFormat = "yyyy MMM"
                Text("Monthly \\n\\(formatter.string(from: entry.date))").font(.system(size: 12, weight: .bold))
                Spacer()
                Text("74%").font(.system(size: 14, weight: .bold)).foregroundColor(Color(hex: "#5e4dbb"))
            }
            HStack(spacing: 16) {
                if let h1 = entry.habits.first(where: { $0.id == entry.configuration.habit1?.id }) {
                    MiniMonthGrid(habit: h1, checkins: entry.checkins, date: entry.date)
                }
                if let h2 = entry.habits.first(where: { $0.id == entry.configuration.habit2?.id }) {
                    MiniMonthGrid(habit: h2, checkins: entry.checkins, date: entry.date)
                }
            }
        }.padding()
    }
}

struct MiniMonthGrid: View {
    var habit: Habit
    var checkins: [Checkin]
    var date: Date
    var body: some View {
        let days = getDaysForMonth(date: date)
        VStack(alignment: .leading, spacing: 4) {
            HStack {
                RoundedRectangle(cornerRadius: 4).fill(Color(hex: habit.color)).frame(width: 12, height: 12)
                Text(habit.name).font(.system(size: 12, weight: .bold)).lineLimit(1)
            }
            let rows = days.count / 7
            VStack(spacing: 2) {
                ForEach(0..<rows, id: \\.self) { row in
                    HStack(spacing: 2) {
                        ForEach(0..<7, id: \\.self) { col in
                            let index = row * 7 + col
                            if let dayDate = days[index] {
                                let isDone = isCheckedIn(habit: habit, date: dayDate, checkins: checkins)
                                ZStack {
                                    RoundedRectangle(cornerRadius: 3).fill(isDone ? Color(hex: habit.color) : Color(hex: habit.color).opacity(0.1))
                                    if isDone { Image(systemName: "checkmark").font(.system(size: 6, weight: .bold)).foregroundColor(.white) }
                                }.aspectRatio(1, contentMode: .fit)
                            } else {
                                Color.clear.aspectRatio(1, contentMode: .fit)
                            }
                        }
                    }
                }
            }
        }
    }
}

struct YearlyHeatmapWidgetView: View {
    var habit: Habit
    var checkins: [Checkin]
    var date: Date
    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            HStack {
                RoundedRectangle(cornerRadius: 6).fill(Color(hex: habit.color)).frame(width: 16, height: 16)
                Text(habit.name).font(.system(size: 14, weight: .bold))
                Spacer()
                Text("69%").font(.system(size: 14, weight: .bold)).foregroundColor(Color(hex: habit.color))
            }
            let cols = 35
            HStack(spacing: 2) {
                ForEach(0..<cols, id: \\.self) { col in
                    VStack(spacing: 2) {
                        ForEach(0..<7, id: \\.self) { row in
                            let isDone = (col * row) % 3 != 0
                            RoundedRectangle(cornerRadius: 1).fill(isDone ? Color(hex: habit.color) : Color.gray.opacity(0.2)).frame(width: 4, height: 4)
                        }
                    }
                }
            }
        }
    }
}

struct MultiYearlyWidgetView: View {
    var entry: MultipleHabitsEntry
    var body: some View {
        let selectedIds = entry.configuration.habits?.map { $0.id } ?? []
        let selectedHabits = entry.habits.filter { selectedIds.contains($0.id) }
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                RoundedRectangle(cornerRadius: 8).fill(Color(hex: "#5e4dbb")).frame(width: 20, height: 20)
                Text("Yearly").font(.system(size: 16, weight: .bold))
                Spacer()
                Text("69%").font(.system(size: 16, weight: .bold)).foregroundColor(Color(hex: "#5e4dbb"))
            }
            HStack {
                VStack(alignment: .leading) { Text("May").font(.system(size: 12, weight: .bold)); Text("Best").font(.system(size: 10)).foregroundColor(.gray) }
                Spacer()
                VStack(alignment: .leading) { Text("642").font(.system(size: 12, weight: .bold)); Text("Done").font(.system(size: 10)).foregroundColor(.gray) }
                Spacer()
                VStack(alignment: .leading) { Text("31d").font(.system(size: 12, weight: .bold)); Text("Streak").font(.system(size: 10)).foregroundColor(.gray) }
            }.padding(8).background(Color.gray.opacity(0.1)).cornerRadius(8)
            
            if selectedHabits.isEmpty { Text("Please select habits").foregroundColor(.gray) } 
            else { ForEach(selectedHabits.prefix(2), id: \\.id) { habit in YearlyHeatmapWidgetView(habit: habit, checkins: entry.checkins, date: entry.date) } }
        }.padding()
    }
}

struct SingleYearlyWidgetView: View {
    var entry: SimpleEntry
    var body: some View {
        let habit = entry.configuration.selectedHabit.flatMap { h in entry.habits.first(where: { $0.id == h.id }) } ?? entry.habits.first
        VStack {
            if let habit = habit { YearlyHeatmapWidgetView(habit: habit, checkins: entry.checkins, date: entry.date) }
        }.padding()
    }
}

// MARK: - Configurations
struct LittleHabitWidget: Widget {
    let kind: String = "LittleHabitWidget"
    var body: some WidgetConfiguration {
        AppIntentConfiguration(kind: kind, intent: SelectHabitIntent.self, provider: Provider()) { entry in
            let habit = entry.configuration.selectedHabit.flatMap { h in entry.habits.first(where: { $0.id == h.id }) } ?? entry.habits.first
            if let habit = habit { SingleHabitWidgetView(habit: habit, checkins: entry.checkins, date: entry.date).containerBackground(for: .widget) { Color(hex: habit.color) } }
            else { Text("No Habit").containerBackground(for: .widget) { Color.black } }
        }.configurationDisplayName("Single Habit Checkin").description("Quickly check in your habit.").supportedFamilies([.systemSmall])
    }
}
struct SingleMonthWidget: Widget {
    var body: some WidgetConfiguration {
        AppIntentConfiguration(kind: "SingleMonthWidget", intent: SelectHabitIntent.self, provider: Provider()) { entry in
            let habit = entry.configuration.selectedHabit.flatMap { h in entry.habits.first(where: { $0.id == h.id }) } ?? entry.habits.first
            VStack { if let habit = habit { MonthCalendarWidgetView(habit: habit, checkins: entry.checkins, date: entry.date) } }.containerBackground(for: .widget) { Color(hex: "#1C1C1E") }
        }.configurationDisplayName("Single Habit Month").description("Monthly calendar view for a habit.").supportedFamilies([.systemMedium])
    }
}
struct MultiMonthWidget: Widget {
    var body: some WidgetConfiguration {
        AppIntentConfiguration(kind: "MultiMonthWidget", intent: SelectTwoHabitsIntent.self, provider: TwoHabitsProvider()) { entry in
            MultiMonthWidgetView(entry: entry).containerBackground(for: .widget) { Color(hex: "#1C1C1E") }
        }.configurationDisplayName("Multi Habit Month").description("Compare two habits monthly.").supportedFamilies([.systemMedium])
    }
}
struct SingleYearlyWidget: Widget {
    var body: some WidgetConfiguration {
        AppIntentConfiguration(kind: "SingleYearlyWidget", intent: SelectHabitIntent.self, provider: Provider()) { entry in
            SingleYearlyWidgetView(entry: entry).containerBackground(for: .widget) { Color(hex: "#1C1C1E") }
        }.configurationDisplayName("Single Habit Yearly").description("Yearly heatmap for a habit.").supportedFamilies([.systemMedium])
    }
}
struct MultiYearlyWidget: Widget {
    var body: some WidgetConfiguration {
        AppIntentConfiguration(kind: "MultiYearlyWidget", intent: SelectMultipleHabitsIntent.self, provider: MultipleHabitsProvider()) { entry in
            MultiYearlyWidgetView(entry: entry).containerBackground(for: .widget) { Color(hex: "#1C1C1E") }
        }.configurationDisplayName("Multi Habit Yearly").description("Yearly heatmaps for multiple habits.").supportedFamilies([.systemLarge])
    }
}

@main
struct LittleHabitWidgetBundle: WidgetBundle {
    var body: some Widget {
        LittleHabitWidget()          
        SingleMonthWidget()          
        MultiMonthWidget()           
        SingleYearlyWidget()         
        MultiYearlyWidget()          
    }
}
"""

final_code = part1 + "\n" + part2 + "\n" + custom_views

with open('Sources/LittleHabitWidget/LittleHabitWidget.swift', 'w') as f:
    f.write(final_code)
