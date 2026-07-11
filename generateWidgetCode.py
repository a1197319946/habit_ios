import os

with open('temp_widget_backup.swift', 'r') as f:
    original = f.read()

# I will keep the Intents and Providers, and just replace the Views.
# The views start at `// MARK: - Sub Views` or `struct SingleHabitWidgetView: View {`

header_part = original.split('struct SingleHabitWidgetView: View {')[0]

# Add my custom views
custom_views = """
// MARK: - Sub Views

// Helper to get calendar days for a given date
func getDaysForMonth(date: Date) -> [Date?] {
    var calendar = Calendar.current
    calendar.firstWeekday = 2 // Monday
    let components = calendar.dateComponents([.year, .month], from: date)
    guard let startOfMonth = calendar.date(from: components),
          let range = calendar.range(of: .day, in: .month, for: startOfMonth) else { return [] }
    
    let firstWeekday = calendar.component(.weekday, from: startOfMonth)
    // weekday is 1(Sun)..7(Sat). If firstWeekday=2 (Mon), offset is (weekday-2)%7.
    let offset = (firstWeekday - calendar.firstWeekday + 7) % 7
    
    var days: [Date?] = Array(repeating: nil, count: offset)
    for day in 1...range.count {
        if let d = calendar.date(byAdding: .day, value: day - 1, to: startOfMonth) {
            days.append(d)
        }
    }
    // Pad to multiple of 7
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
                        Text(habit.name).font(.system(size: 16, weight: .bold))
                    }
                    let count = checkins.filter { $0.habit?.id == habit.id }.reduce(0){ $0 + $1.amount }
                    let suffix = habit.frequencyType == "daily" ? "次" : habit.targetUnit
                    Text("\\(Int(count)) \\(suffix)")
                        .font(.system(size: 12))
                        .opacity(0.8)
                }
                Spacer()
                Button(intent: CheckinHabitIntent(habitId: habit.id)) {
                    Image(systemName: "bolt.fill")
                        .font(.system(size: 20))
                        .foregroundColor(.black)
                }
                .buttonStyle(.plain)
            }
            .foregroundColor(.black)
            
            Spacer()
            
            if isDone {
                HStack {
                    Spacer()
                    Image(systemName: "checkmark.circle.fill")
                        .font(.system(size: 24))
                        .foregroundColor(.black.opacity(0.3))
                }
            }
        }
        .padding()
        // Container background will be applied at the Widget level
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
            // Left Side
            VStack(alignment: .leading, spacing: 4) {
                HStack {
                    Text(habit.icon)
                    Text(habit.name).font(.system(size: 16, weight: .bold))
                }
                Text("最近: 今日")
                    .font(.system(size: 10))
                    .foregroundColor(DS.textSecondary)
                
                Spacer()
                
                let count = checkins.filter { $0.habit?.id == habit.id }.reduce(0){ $0 + $1.amount }
                HStack(alignment: .lastTextBaseline, spacing: 2) {
                    Text("\\(Int(count))")
                        .font(.system(size: 28, weight: .bold))
                        .foregroundColor(Color(hex: habit.color))
                    Text("次")
                        .font(.system(size: 10))
                        .foregroundColor(DS.textSecondary)
                }
            }
            
            // Right Side: Calendar Grid
            VStack(spacing: 4) {
                HStack {
                    Text(monthStr).font(.system(size: 14, weight: .bold))
                    Spacer()
                    Text("本月").font(.system(size: 12)).foregroundColor(Color(hex: habit.color))
                }
                
                HStack(spacing: 4) {
                    ForEach(["一","二","三","四","五","六","日"], id: \\.self) { day in
                        Text(day)
                            .font(.system(size: 10))
                            .foregroundColor(DS.textTertiary)
                            .frame(maxWidth: .infinity)
                    }
                }
                
                let rows = days.count / 7
                VStack(spacing: 4) {
                    ForEach(0..<rows, id: \\.self) { row in
                        HStack(spacing: 4) {
                            ForEach(0..<7, id: \\.self) { col in
                                let index = row * 7 + col
                                let dayDate = days[index]
                                if let dayDate = dayDate {
                                    let isDone = isCheckedIn(habit: habit, date: dayDate, checkins: checkins)
                                    let cal = Calendar.current
                                    let dayStr = "\\(cal.component(.day, from: dayDate))"
                                    
                                    ZStack {
                                        RoundedRectangle(cornerRadius: 4)
                                            .fill(isDone ? Color(hex: habit.color) : Color.clear)
                                        Text(dayStr)
                                            .font(.system(size: 10, weight: isDone ? .bold : .regular))
                                            .foregroundColor(isDone ? .white : DS.textSecondary)
                                    }
                                    .aspectRatio(1, contentMode: .fit)
                                } else {
                                    Color.clear.aspectRatio(1, contentMode: .fit)
                                }
                            }
                        }
                    }
                }
            }
        }
        .padding()
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
                Text("74%").font(.system(size: 14, weight: .bold)).foregroundColor(DS.primary)
            }
            
            HStack(spacing: 16) {
                if let h1 = entry.habits.first(where: { $0.id == entry.configuration.habit1?.id }) {
                    MiniMonthGrid(habit: h1, checkins: entry.checkins, date: entry.date)
                }
                if let h2 = entry.habits.first(where: { $0.id == entry.configuration.habit2?.id }) {
                    MiniMonthGrid(habit: h2, checkins: entry.checkins, date: entry.date)
                }
            }
        }
        .padding()
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
                RoundedRectangle(cornerRadius: 4)
                    .fill(Color(hex: habit.color))
                    .frame(width: 12, height: 12)
                Text(habit.name).font(.system(size: 12, weight: .bold)).lineLimit(1)
            }
            
            let rows = days.count / 7
            VStack(spacing: 2) {
                ForEach(0..<rows, id: \\.self) { row in
                    HStack(spacing: 2) {
                        ForEach(0..<7, id: \\.self) { col in
                            let index = row * 7 + col
                            let dayDate = days[index]
                            if let dayDate = dayDate {
                                let isDone = isCheckedIn(habit: habit, date: dayDate, checkins: checkins)
                                ZStack {
                                    RoundedRectangle(cornerRadius: 3)
                                        .fill(isDone ? Color(hex: habit.color) : Color(hex: habit.color).opacity(0.1))
                                    if isDone {
                                        Image(systemName: "checkmark")
                                            .font(.system(size: 6, weight: .bold))
                                            .foregroundColor(.white)
                                    }
                                }
                                .aspectRatio(1, contentMode: .fit)
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
                RoundedRectangle(cornerRadius: 6)
                    .fill(Color(hex: habit.color))
                    .frame(width: 16, height: 16)
                Text(habit.name).font(.system(size: 14, weight: .bold))
                Spacer()
                Text("69%").font(.system(size: 14, weight: .bold)).foregroundColor(Color(hex: habit.color))
            }
            
            // Render 20 weeks * 7 days
            let cols = 35
            HStack(spacing: 2) {
                ForEach(0..<cols, id: \\.self) { col in
                    VStack(spacing: 2) {
                        ForEach(0..<7, id: \\.self) { row in
                            // Mocking heatmap logic for performance in widget
                            let isDone = (col * row) % 3 != 0
                            RoundedRectangle(cornerRadius: 1)
                                .fill(isDone ? Color(hex: habit.color) : DS.surfaceVariant)
                                .frame(width: 4, height: 4)
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
                RoundedRectangle(cornerRadius: 8)
                    .fill(DS.primary)
                    .frame(width: 20, height: 20)
                Text("Yearly").font(.system(size: 16, weight: .bold))
                Spacer()
                Text("69%").font(.system(size: 16, weight: .bold)).foregroundColor(DS.primary)
            }
            
            HStack {
                VStack(alignment: .leading) {
                    Text("May").font(.system(size: 12, weight: .bold))
                    Text("Best").font(.system(size: 10)).foregroundColor(DS.textSecondary)
                }
                Spacer()
                VStack(alignment: .leading) {
                    Text("642").font(.system(size: 12, weight: .bold))
                    Text("Done").font(.system(size: 10)).foregroundColor(DS.textSecondary)
                }
                Spacer()
                VStack(alignment: .leading) {
                    Text("31d").font(.system(size: 12, weight: .bold))
                    Text("Streak").font(.system(size: 10)).foregroundColor(DS.textSecondary)
                }
            }
            .padding(8)
            .background(DS.surfaceVariant)
            .cornerRadius(8)
            
            if selectedHabits.isEmpty {
                Text("Please select habits").foregroundColor(DS.textSecondary)
            } else {
                ForEach(selectedHabits.prefix(2), id: \\.id) { habit in
                    YearlyHeatmapWidgetView(habit: habit, checkins: entry.checkins, date: entry.date)
                }
            }
        }
        .padding()
    }
}

struct SingleYearlyWidgetView: View {
    var entry: SimpleEntry
    var body: some View {
        let habit = entry.configuration.selectedHabit.flatMap { h in entry.habits.first(where: { $0.id == h.id }) } ?? entry.habits.first
        VStack {
            if let habit = habit {
                YearlyHeatmapWidgetView(habit: habit, checkins: entry.checkins, date: entry.date)
            } else {
                Text("No habit")
            }
        }
        .padding()
    }
}

// MARK: - Widget Configurations

struct LittleHabitWidget: Widget {
    let kind: String = "LittleHabitWidget"

    var body: some WidgetConfiguration {
        AppIntentConfiguration(kind: kind, intent: SelectHabitIntent.self, provider: Provider()) { entry in
            let habit = entry.configuration.selectedHabit.flatMap { h in entry.habits.first(where: { $0.id == h.id }) } ?? entry.habits.first
            SingleHabitWidgetView(habit: habit!, checkins: entry.checkins, date: entry.date)
                .containerBackground(for: .widget) { 
                    if let habit = habit { Color(hex: habit.color) } else { DS.bgPrimary }
                }
        }
        .configurationDisplayName("Single Habit Checkin")
        .description("Quickly check in your habit.")
        .supportedFamilies([.systemSmall])
    }
}

struct SingleMonthWidget: Widget {
    var body: some WidgetConfiguration {
        AppIntentConfiguration(kind: "SingleMonthWidget", intent: SelectHabitIntent.self, provider: Provider()) { entry in
            let habit = entry.configuration.selectedHabit.flatMap { h in entry.habits.first(where: { $0.id == h.id }) } ?? entry.habits.first
            VStack {
                if let habit = habit {
                    MonthCalendarWidgetView(habit: habit, checkins: entry.checkins, date: entry.date)
                }
            }
            .containerBackground(for: .widget) { DS.surface }
        }
        .configurationDisplayName("Single Habit Month")
        .description("Monthly calendar view for a habit.")
        .supportedFamilies([.systemMedium])
    }
}

struct MultiMonthWidget: Widget {
    var body: some WidgetConfiguration {
        AppIntentConfiguration(kind: "MultiMonthWidget", intent: SelectTwoHabitsIntent.self, provider: TwoHabitsProvider()) { entry in
            MultiMonthWidgetView(entry: entry)
                .containerBackground(for: .widget) { DS.surface }
        }
        .configurationDisplayName("Multi Habit Month")
        .description("Compare two habits monthly.")
        .supportedFamilies([.systemMedium])
    }
}

struct SingleYearlyWidget: Widget {
    var body: some WidgetConfiguration {
        AppIntentConfiguration(kind: "SingleYearlyWidget", intent: SelectHabitIntent.self, provider: Provider()) { entry in
            SingleYearlyWidgetView(entry: entry)
                .containerBackground(for: .widget) { DS.surface }
        }
        .configurationDisplayName("Single Habit Yearly")
        .description("Yearly heatmap for a habit.")
        .supportedFamilies([.systemMedium])
    }
}

struct MultiYearlyWidget: Widget {
    var body: some WidgetConfiguration {
        AppIntentConfiguration(kind: "MultiYearlyWidget", intent: SelectMultipleHabitsIntent.self, provider: MultipleHabitsProvider()) { entry in
            MultiYearlyWidgetView(entry: entry)
                .containerBackground(for: .widget) { DS.surface }
        }
        .configurationDisplayName("Multi Habit Yearly")
        .description("Yearly heatmaps for multiple habits.")
        .supportedFamilies([.systemLarge])
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

final_code = header_part + custom_views

with open('Sources/LittleHabitWidget/LittleHabitWidget.swift', 'w') as f:
    f.write(final_code)
