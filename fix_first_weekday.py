import os

# 1. Fix StatisticsView.swift
with open('Sources/StatisticsView.swift', 'r') as f:
    stats = f.read()

# Replace weekdaysShort
old_weekdays_short = """    private var weekdaysShort: [String] {
        if appSettings.resolvedLanguage == .chinese {
            return ["日", "一", "二", "三", "四", "五", "六"]
        } else {
            return ["Sun", "Mon", "Tue", "Wed", "Thu", "Fri", "Sat"]
        }
    }"""
new_weekdays_short = """    private var weekdaysShort: [String] {
        let isChinese = appSettings.resolvedLanguage == .chinese
        let sunFirst = appSettings.firstWeekday == 1
        if isChinese {
            return sunFirst ? ["日", "一", "二", "三", "四", "五", "六"] : ["一", "二", "三", "四", "五", "六", "日"]
        } else {
            return sunFirst ? ["Sun", "Mon", "Tue", "Wed", "Thu", "Fri", "Sat"] : ["Mon", "Tue", "Wed", "Thu", "Fri", "Sat", "Sun"]
        }
    }"""
stats = stats.replace(old_weekdays_short, new_weekdays_short)

# Replace firstWeekday offset math
old_first_weekday_math = """    private var firstWeekday: Int {
        var components = calendar.dateComponents([.year, .month], from: currentMonthDate)
        components.day = 1
        guard let firstDay = calendar.date(from: components) else { return 0 }
        // 1 = Sunday, 2 = Monday... We want to offset based on calendar's first weekday (usually Sun=1)
        let wd = calendar.component(.weekday, from: firstDay)
        return wd - 1 // 0 offset for Sunday
    }"""
new_first_weekday_math = """    private var firstWeekday: Int {
        var components = calendar.dateComponents([.year, .month], from: currentMonthDate)
        components.day = 1
        guard let firstDay = calendar.date(from: components) else { return 0 }
        let wd = calendar.component(.weekday, from: firstDay)
        let first = appSettings.firstWeekday
        var offset = wd - first
        if offset < 0 { offset += 7 }
        return offset
    }"""
stats = stats.replace(old_first_weekday_math, new_first_weekday_math)

# Add .id(appSettings.firstWeekday) to StatisticsView ScrollView
old_stats_scroll = "ScrollView(showsIndicators: false) {"
new_stats_scroll = "ScrollView(showsIndicators: false) {\n            let _ = appSettings.firstWeekday // Force dependency"
stats = stats.replace(old_stats_scroll, new_stats_scroll)

with open('Sources/StatisticsView.swift', 'w') as f:
    f.write(stats)


# 2. Fix HabitStatsDetailView.swift
with open('Sources/HabitStatsDetailView.swift', 'r') as f:
    detail = f.read()

old_get_first = """    private func getFirstWeekday() -> Int {
        let date = dateForFirstDayOfMonth()
        let wd = calendar.component(.weekday, from: date)
        return wd - 1 // 0 for Sunday
    }"""
new_get_first = """    private func getFirstWeekday() -> Int {
        let date = dateForFirstDayOfMonth()
        let wd = calendar.component(.weekday, from: date)
        let first = appSettings.firstWeekday
        var offset = wd - first
        if offset < 0 { offset += 7 }
        return offset
    }"""
detail = detail.replace(old_get_first, new_get_first)
with open('Sources/HabitStatsDetailView.swift', 'w') as f:
    f.write(detail)


# 3. Fix HomeView.swift
with open('Sources/HomeView.swift', 'r') as f:
    home = f.read()

old_weekly_slider = """        ScrollView(.horizontal, showsIndicators: false) {
            LazyHStack(spacing: 0) {"""
new_weekly_slider = """        ScrollView(.horizontal, showsIndicators: false) {
            LazyHStack(spacing: 0) {
                let _ = appSettings.firstWeekday // Force refresh on change"""
home = home.replace(old_weekly_slider, new_weekly_slider)

# Also ID the weekly slider to force recreation
old_slider_call = "WeeklySlider(selectedDate: $selectedDate, checkins: checkins)"
new_slider_call = "WeeklySlider(selectedDate: $selectedDate, checkins: checkins).id(appSettings.firstWeekday)"
home = home.replace(old_slider_call, new_slider_call)

with open('Sources/HomeView.swift', 'w') as f:
    f.write(home)

