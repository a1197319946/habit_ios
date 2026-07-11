with open('Sources/HomeView.swift', 'r') as f:
    code = f.read()

# 1. Add weekOffset to HomeView
code = code.replace('@State private var selectedDate: Date = Date()\n    @State private var showingAmountSheet = false', '@State private var selectedDate: Date = Date()\n    @State private var weekOffset: Int? = 0\n    @State private var showingAmountSheet = false')

# 2. Update WeeklySlider instantiation
code = code.replace('WeeklySlider(selectedDate: $selectedDate, checkins: checkins).id(appSettings.firstWeekday)', 'WeeklySlider(selectedDate: $selectedDate, checkins: checkins, weekOffset: $weekOffset).id(appSettings.firstWeekday)')

# 3. Change WeeklySlider weekOffset to @Binding
code = code.replace('@State private var weekOffset: Int? = 0\n    private var calendar: Calendar', '@Binding var weekOffset: Int?\n    private var calendar: Calendar')

with open('Sources/HomeView.swift', 'w') as f:
    f.write(code)

