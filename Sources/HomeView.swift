import SwiftUI
import WidgetKit
import CoreData

struct HomeView: View {
    @Environment(\.managedObjectContext) private var viewContext
    @EnvironmentObject private var appSettings: AppSettings
    
    @FetchRequest(
        sortDescriptors: [NSSortDescriptor(keyPath: \Habit.order, ascending: true)],
        predicate: NSPredicate(format: "isArchived == NO")
    ) private var habits: FetchedResults<Habit>
    
    @FetchRequest(
        sortDescriptors: []
    ) private var checkins: FetchedResults<Checkin>
    
    @Binding var selectedTab: AppTab
    
    @State private var selectedDate: Date = Date()
    @State private var weekOffset: Int? = 0
    @State private var showingAmountSheet = false
    @State private var showingSuccessModal = false
    @State private var showingMakeupAlert = false
    @State private var showingMoodRecorder = false
    @State private var selectedHabit: Habit?
    @State private var initialAmountForSheet: Double?
    @State private var hideCompleted = false
    
    // Bottom Sheet for interactions
    @State private var showingActionSheet = false
    
    private var todayDateString: String { formatDate(Date()) }
    private var selectedDateString: String { formatDate(selectedDate) }
    
    private var greetingString: String {
        let hour = appSettings.customCalendar.component(.hour, from: Date())
        if appSettings.resolvedLanguage == .chinese {
            switch hour {
            case 5..<12: return "早上好"
            case 12..<18: return "下午好"
            default: return "晚上好"
            }
        } else {
            switch hour {
            case 5..<12: return "Good Morning"
            case 12..<18: return "Good Afternoon"
            default: return "Good Evening"
            }
        }
    }
    
    var body: some View {
        GeometryReader { geo in
            ScrollView(showsIndicators: false) {
                VStack(alignment: .leading, spacing: 12) {
                    // Header & Month
                    HStack(alignment: .lastTextBaseline, spacing: 8) {
                        Text(greetingString)
                            .font(.system(size: 28, weight: .bold, design: .rounded))
                            .foregroundColor(DS.onSurface)
                            
                        Spacer()
                        
                        Text(monthString(for: selectedDate))
                            .font(.system(size: 14, weight: .medium))
                            .foregroundColor(DS.onSurfaceVariant)
                    }
                    .padding(.horizontal, 16)
                    .padding(.top, 8)
                    
                    // Weekly Calendar Slider
                    WeeklySlider(selectedDate: $selectedDate, checkins: Array(checkins), weekOffset: $weekOffset).id(appSettings.firstWeekday)
                    
                    // List for Habits
                    if habits.isEmpty {
                        EmptyHabitsView {
                            withAnimation {
                                selectedTab = .habits
                            }
                        }
                        .frame(maxWidth: .infinity)
                        .padding(.top, 20)
                        Spacer(minLength: 0)
                    } else {
                        // Top Actions
                        HStack {
                            Spacer()
                            
                            Button(action: {
                                withAnimation { hideCompleted.toggle() }
                            }) {
                                Text(hideCompleted ? "Show Completed".tr(appSettings.resolvedLanguage) : "Hide Completed".tr(appSettings.resolvedLanguage))
                                    .font(.system(size: 12, weight: .bold))
                                    .foregroundColor(DS.primary)
                                    .padding(.horizontal, 12)
                                    .padding(.vertical, 6)
                                    .background(Color.clear)
                                    .overlay(
                                        Capsule()
                                            .stroke(DS.primary, lineWidth: 1)
                                    )
                                    .clipShape(Capsule())
                            }
                        }
                        .padding(.horizontal, 16)
                        .padding(.bottom, 0)
                        
                        LazyVStack(spacing: 10) {
                            let visibleHabits = habits.filter { habit in
                                if hideCompleted {
                                    return !isHabitChecked(habit: habit)
                                }
                                return true
                            }
                            ForEach(visibleHabits) { habit in
                                renderHabitCard(habit: habit)
                            }
                        }
                        .padding(.horizontal, 16)
                        
                        Spacer(minLength: 24)
                    }
                    
                    // Motivational Banner
                    VStack {
                        Text("\"Small steps, big changes.\"".tr(appSettings.resolvedLanguage))
                            .font(.system(size: 16, weight: .bold, design: .rounded).italic())
                            .foregroundStyle(DS.onSurfaceVariant)
                            .opacity(0.8)
                            .padding(.bottom, 30)
                    }
                    .frame(maxWidth: .infinity)
                }
                .frame(minHeight: geo.size.height, alignment: .top)
            }
        }
        .background(AmbientBackground())
        .onAppear {
            selectedDate = Date()
            weekOffset = 0
            let toDelete = checkins.filter { $0.habit == nil }
            for c in toDelete {
                viewContext.delete(c)
            }
            try? viewContext.save()
            NotificationManager.shared.updateAllReminders(habits: Array(habits))
            WidgetCenter.shared.reloadAllTimelines()
        }
        // Overlays & Sheets
        .sheet(isPresented: $showingSuccessModal) {
            if let selectedHabit = selectedHabit {
                CheckinSuccessView(
                    habit: selectedHabit,
                    date: selectedDate,
                    checkins: Array(checkins),
                    onRecordMood: { showingMoodRecorder = true }
                )
                .presentationDetents([.height(440)])
                .presentationDragIndicator(.visible)
            }
        }
        .sheet(isPresented: $showingMoodRecorder) {
            if let selectedHabit = selectedHabit {
                MoodRecorderView(habit: selectedHabit)
                    .presentationDetents([.height(680)])
                    .presentationDragIndicator(.visible)
            }
        }
        .alert("提示", isPresented: $showingMakeupAlert) {
            Button("取消", role: .cancel) { }
            Button("确认") {
                if let h = selectedHabit { executeCheckin(habit: h) }
            }
        } message: {
            Text("对 \(formatDate(selectedDate)) 补卡？")
        }
        .sheet(isPresented: $showingAmountSheet) {
            if let habit = selectedHabit {
                AmountCheckinSheet(
                    habit: habit,
                    selectedDate: selectedDate,
                    initialAmount: initialAmountForSheet ?? 0,
                    onComplete: {
                        NotificationManager.shared.scheduleReminder(for: habit)
                        triggerSuccessSequence()
                    }
                )
            }
        }
        .alert(
            "Options".tr(appSettings.resolvedLanguage),
            isPresented: $showingActionSheet,
            presenting: selectedHabit
        ) { habit in
            if habit.goalType == "amount" {
                Button("Edit Amount".tr(appSettings.resolvedLanguage)) {
                    editAmount(habit: habit)
                }
            }
            Button("Undo Check-in".tr(appSettings.resolvedLanguage), role: .destructive) {
                undoCheckin(habit: habit)
            }
            Button("Cancel".tr(appSettings.resolvedLanguage), role: .cancel) {}
        }
        .onAppear {
            checkOpenHabit()
        }
        .onChange(of: appSettings.openCheckinHabitId, perform: { _ in
            checkOpenHabit()
        })
    }
    
    private func checkOpenHabit() {
        if let habitId = appSettings.openCheckinHabitId {
            if let habit = habits.first(where: { $0.id == habitId }) {
                appSettings.openCheckinHabitId = nil
                selectedHabit = habit
                if habit.goalType == "amount" {
                    initialAmountForSheet = nil
                    showingAmountSheet = true
                } else {
                    handleCheckinTap(habit: habit)
                }
            }
        }
    }
    
    // MARK: - Actions
    private func isHabitChecked(habit: Habit) -> Bool {
        let dateString = SharedFormatters.dateString(from: selectedDate)
        return habit.checkinDates.contains(dateString)
    }
    
    private func handleCheckinTap(habit: Habit) {
        let dateString = SharedFormatters.dateString(from: selectedDate)
        let isChecked = habit.checkinDates.contains(dateString)
        
        selectedHabit = habit
        
        if isChecked {
            // Checked in, just open action sheet
            showingActionSheet = true
            return
        }
        
        // Not checked in -> checkin flow
        if selectedDateString < todayDateString {
            showingMakeupAlert = true
        } else if selectedDateString > todayDateString {
            // Future date logic (if needed)
        } else {
            executeCheckin(habit: habit)
        }
    }
    
    private func executeCheckin(habit: Habit) {
        if habit.goalType == "amount" {
            initialAmountForSheet = nil
            showingAmountSheet = true
        } else {
            let checkin = Checkin(context: viewContext)
            checkin.dateString = selectedDateString
            checkin.amount = 1.0
            checkin.habit = habit
            try? viewContext.save()
            NotificationManager.shared.scheduleReminder(for: habit)
            WidgetCenter.shared.reloadAllTimelines()
            triggerSuccessSequence()
        }
    }
    
    private func undoCheckin(habit: Habit) {
        let dateString = formatDate(selectedDate)
        let checks = checkins.filter { $0.habit?.id == habit.id && $0.dateString == dateString }
        for check in checks {
            viewContext.delete(check)
        }
        try? viewContext.save()
        WidgetCenter.shared.reloadAllTimelines()
    }
    
    private func editAmount(habit: Habit) {
        let dateString = formatDate(selectedDate)
        if let firstCheckin = checkins.first(where: { $0.habit?.id == habit.id && $0.dateString == dateString }) {
            initialAmountForSheet = firstCheckin.amount
        } else {
            initialAmountForSheet = nil
        }
        showingAmountSheet = true
    }
    
    private func triggerSuccessSequence() {
        let impact = UIImpactFeedbackGenerator(style: .medium)
        impact.impactOccurred()
        showingSuccessModal = true
    }
    
    private func formatDate(_ date: Date) -> String {
        return SharedFormatters.dateString(from: date)
    }
    
    private func monthString(for date: Date) -> String {
        let formatter = DateFormatter()
        if appSettings.resolvedLanguage == .chinese {
            formatter.locale = Locale(identifier: "zh_CN")
            formatter.dateFormat = "yyyy年 M月"
        } else {
            formatter.locale = Locale(identifier: "en_US")
            formatter.dateFormat = "MMMM yyyy"
        }
        return formatter.string(from: date)
    }
    
    @ViewBuilder
    private func renderHabitCard(habit: Habit) -> some View {
        ListHabitCard(
            habit: habit,
            selectedDate: selectedDate,
            checkins: Array(checkins),
            onTapCheckin: { handleCheckinTap(habit: habit) },
            onTapCard: {
                if isHabitChecked(habit: habit) {
                    selectedHabit = habit
                    showingActionSheet = true
                } else {
                    handleCheckinTap(habit: habit)
                }
            }
        )
    }
}

// MARK: - List Habit Card
struct ListHabitCard: View {
    let habit: Habit
    let selectedDate: Date
    let checkins: [Checkin]
    @EnvironmentObject private var appSettings: AppSettings
    let onTapCheckin: () -> Void
    let onTapCard: () -> Void
    
    var isChecked: Bool {
        let dateString = SharedFormatters.dateString(from: selectedDate)
        return habit.checkinDates.contains(dateString)
    }
    
    private func currentWeekCheckins(for habit: Habit) -> [Checkin] {
        let hc = habit.checkinsArray
        let calendar = appSettings.customCalendar
        guard let interval = calendar.dateInterval(of: .weekOfYear, for: selectedDate) else { return [] }
        let startStr = SharedFormatters.dateString(from: interval.start)
        let endStr = SharedFormatters.dateString(from: interval.end)
        return hc.filter { $0.dateString >= startStr && $0.dateString < endStr }
    }
    
    var periodValidCheckins: [Checkin] {
        var calendar: Calendar { appSettings.customCalendar }
        let targetComponent: Calendar.Component = habit.frequencyType == "weekly" ? .weekOfYear : .month
        let interval = calendar.dateInterval(of: targetComponent, for: selectedDate)
        
        guard let start = interval?.start, let end = interval?.end else { return [] }
        let startStr = SharedFormatters.dateString(from: start)
        let endStr = SharedFormatters.dateString(from: end)
        let hc = habit.checkinsArray
        return hc.filter { $0.dateString >= startStr && $0.dateString < endStr }
    }
    
    var periodCompletedCount: Int {
        periodValidCheckins.count
    }
    
    var periodCompletedAmount: Double {
        periodValidCheckins.reduce(0.0) { $0 + $1.amount }
    }
    
    var periodTarget: Int {
        habit.frequencyType == "weekly" ? habit.weeklyTarget : habit.monthlyTarget
    }
    
    var progressFraction: Double {
        if habit.goalType == "amount" {
            if habit.amountValue <= 0 { return 0.0 }
            return min(1.0, periodCompletedAmount / habit.amountValue)
        } else {
            if periodTarget == 0 { return 0.0 }
            return min(1.0, Double(periodCompletedCount) / Double(periodTarget))
        }
    }
    
    var progressText: String {
        if habit.goalType == "amount" {
            let sum = periodCompletedAmount
            let target = habit.amountValue
            let sumFormatted = sum.truncatingRemainder(dividingBy: 1) == 0 ? String(format: "%.0f", sum) : String(format: "%.1f", sum)
            let targetFormatted = target.truncatingRemainder(dividingBy: 1) == 0 ? String(format: "%.0f", target) : String(format: "%.1f", target)
            return "\(sumFormatted)/\(targetFormatted) \(habit.amountUnit.tr(appSettings.resolvedLanguage))"
        } else {
            return "\(periodCompletedCount)/\(periodTarget)\("次".tr(appSettings.resolvedLanguage))"
        }
    }
    
    var body: some View {
        Button(action: {
            onTapCard()
        }) {
            HStack(spacing: 10) {
                // Icon
                ZStack {
                    Circle()
                        .fill(Color(hex: habit.color).opacity(0.15))
                        .frame(width: 52, height: 52)
                    
                    Image(systemName: habit.icon)
                        .font(.system(size: 22))
                        .foregroundColor(Color(hex: habit.color))
                }
                
                // Details
                VStack(alignment: .leading, spacing: 8) {
                    HStack(alignment: .lastTextBaseline, spacing: 6) {
                        Text(habit.name)
                            .font(.system(size: 16, weight: .bold))
                            .foregroundColor(DS.onSurface)
                            .lineLimit(1)
                        
                        Spacer()
                        
                        Text(progressText)
                            .font(.system(size: 12, weight: .bold))
                            .foregroundColor(DS.onSurfaceVariant)
                            .lineLimit(1)
                            .fixedSize(horizontal: true, vertical: false)
                    }
                    
                    HStack(spacing: 8) {
                        Text(habit.frequencyType == "weekly" ? "本周".tr(appSettings.resolvedLanguage) : "本月".tr(appSettings.resolvedLanguage))
                            .font(.system(size: 10, weight: .semibold))
                            .lineLimit(1)
                            .fixedSize(horizontal: true, vertical: false)
                            .foregroundColor(Color(hex: habit.color))
                            .padding(.horizontal, 6)
                            .padding(.vertical, 3)
                            .background(Color(hex: habit.color).opacity(0.1))
                            .clipShape(Capsule())
                            
                        GeometryReader { geometry in
                            ZStack(alignment: .leading) {
                                Capsule()
                                    .fill(DS.surfaceVariant)
                                    .frame(height: 6)
                                Capsule()
                                    .fill(Color(hex: habit.color))
                                    .frame(width: max(0, min(geometry.size.width, geometry.size.width * CGFloat(progressFraction))), height: 6)
                            }
                        }
                        .frame(height: 6)
                        
                        Text("\(Int(progressFraction * 100))%")
                            .font(.system(size: 11, weight: .bold))
                            .foregroundColor(DS.onSurfaceVariant)
                            .frame(width: 36, alignment: .trailing)
                    }
                }
                
                // Check-in Button
                Button(action: {
                    onTapCheckin()
                }) {
                    ZStack {
                        Circle()
                            .fill(isChecked ? Color(hex: "#4CD964") : Color.clear)
                            .frame(width: 44, height: 44)
                            .overlay(
                                Circle()
                                    .stroke(isChecked ? Color.clear : Color(hex: habit.color).opacity(0.6), lineWidth: 2)
                                    .background(Circle().fill(isChecked ? Color.clear : DS.uncheckedPlaceholder))
                            )
                        
                        if isChecked {
                            Image(systemName: "checkmark")
                                .font(.system(size: 18, weight: .bold))
                                .foregroundColor(.white)
                                .transition(.scale.combined(with: .opacity))
                        }
                    }
                    .animation(.spring(response: 0.3, dampingFraction: 0.6), value: isChecked)
                }
                .buttonStyle(PlainButtonStyle())
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 16)
            .background(DS.surface)
            .clipShape(RoundedRectangle(cornerRadius: 20, style: .continuous))
            .shadow(color: Color.black.opacity(0.04), radius: 15, x: 0, y: 5)
        }
        .buttonStyle(PlainButtonStyle())
    }
}

// MARK: - Weekly Slider
struct WeeklySlider: View {
    @Binding var selectedDate: Date
    let checkins: [Checkin]
    @EnvironmentObject private var appSettings: AppSettings
    
    @Binding var weekOffset: Int?
    private var calendar: Calendar { appSettings.customCalendar }
    private let weekRange = -50...50
    
    private var activeCheckinDates: Set<String> {
        var set = Set<String>()
        for c in checkins {
            if let h = c.habit, !h.isArchived {
                set.insert(c.dateString)
            }
        }
        return set
    }
    
    var body: some View {
        if #available(iOS 17.0, *) {
            ScrollView(.horizontal, showsIndicators: false) {
                LazyHStack(spacing: 0) {
                    let _ = appSettings.firstWeekday // Force refresh on change
                    ForEach(weekRange, id: \.self) { offset in
                        weekView(for: offset)
                            .containerRelativeFrame(.horizontal)
                            .id(offset)
                    }
                }
                .scrollTargetLayout()
            }
            .scrollTargetBehavior(.paging)
            .scrollPosition(id: $weekOffset)
            .frame(height: 105)
            .padding(.bottom, -15)
            .onChange(of: weekOffset, perform: { newOffset in
                handleOffsetChange(newOffset)
            })
        } else {
            TabView(selection: Binding(get: { weekOffset ?? 0 }, set: { weekOffset = $0 })) {
                let _ = appSettings.firstWeekday
                ForEach(weekRange, id: \.self) { offset in
                    weekView(for: offset)
                        .tag(offset)
                }
            }
            .tabViewStyle(.page(indexDisplayMode: .never))
            .frame(height: 105)
            .padding(.bottom, -15)
            .onChange(of: weekOffset, perform: { newOffset in
                handleOffsetChange(newOffset)
            })
        }
    }
    
    private func handleOffsetChange(_ newOffset: Int?) {
            if let newOffset = newOffset {
                let targetDate = calendar.date(byAdding: .weekOfYear, value: newOffset, to: Date()) ?? Date()
                if let weekInterval = calendar.dateInterval(of: .weekOfYear, for: targetDate) {
                    let todayWeekday = calendar.component(.weekday, from: Date())
                    var matchedDate = weekInterval.start
                    for i in 0..<7 {
                        if let d = calendar.date(byAdding: .day, value: i, to: weekInterval.start),
                           calendar.component(.weekday, from: d) == todayWeekday {
                            matchedDate = d
                            break
                        }
                    }
                    selectedDate = matchedDate
                }
            }
        }
    
    private func weekView(for offset: Int) -> some View {
        let targetDate = calendar.date(byAdding: .weekOfYear, value: offset, to: Date()) ?? Date()
        let weekInterval = calendar.dateInterval(of: .weekOfYear, for: targetDate)!
        let startDate = weekInterval.start
        
        var days: [Date] = []
        for i in 0..<7 {
            if let date = calendar.date(byAdding: .day, value: i, to: startDate) {
                days.append(date)
            }
        }
        
        let activeSet = activeCheckinDates
        return HStack(spacing: 8) {
            ForEach(days, id: \.self) { date in
                let isSelected = calendar.isDate(date, inSameDayAs: selectedDate)
                let isToday = calendar.isDateInToday(date)
                let dayStr = shortDayString(for: date)
                let dayNum = calendar.component(.day, from: date)
                let isCheckedIn = activeSet.contains(SharedFormatters.dateString(from: date))
                
                Button(action: {
                    UIImpactFeedbackGenerator(style: .light).impactOccurred()
                    withAnimation { selectedDate = date }
                }) {
                    VStack(spacing: 8) {
                        Text(isToday ? "Today".tr(appSettings.resolvedLanguage) : dayStr.tr(appSettings.resolvedLanguage))
                            .font(.system(size: isToday ? 14 : 12, weight: isToday ? .bold : .medium))
                            .foregroundColor(isSelected ? .white : (isToday ? DS.primary : DS.onSurfaceVariant))
                            .lineLimit(1)
                            .minimumScaleFactor(0.7)
                        
                        Text("\(dayNum)")
                            .font(.system(size: 16, weight: .bold))
                            .foregroundColor(isSelected ? .white : DS.onSurface)
                        
                        Circle()
                            .fill(isSelected ? (isCheckedIn ? .white : .clear) : (isCheckedIn ? DS.primary : .clear))
                            .frame(width: 4, height: 4)
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 12)
                    .background(
                        ZStack {
                            if isSelected {
                                DS.primary
                            } else if isToday {
                                DS.primaryContainer.opacity(0.5)
                            } else {
                                DS.surface.opacity(0.6)
                            }
                        }
                    )
                    .clipShape(Capsule())
                    .overlay(
                        Capsule()
                            .stroke((!isSelected && isToday) ? DS.primary : Color.clear, lineWidth: 2)
                    )
                    .shadow(color: isSelected ? DS.primary.opacity(0.3) : .clear, radius: 8, x: 0, y: 4)
                }
                .buttonStyle(PlainButtonStyle())
            }
        }
        .padding(.horizontal, 16)
    }
    
    private func shortDayString(for date: Date) -> String {
        let df = DateFormatter()
        df.dateFormat = "EEE"
        return String(df.string(from: date).prefix(3))
    }
    
    private func formatDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        return formatter.string(from: date)
    }
}

// Ensure EmptyHabitsView matches
struct EmptyHabitsView: View {
    @EnvironmentObject private var appSettings: AppSettings
    var onAction: (() -> Void)? = nil
    
    var body: some View {
        VStack(spacing: DS.spacingM) {
            ZStack {
                RoundedRectangle(cornerRadius: 32, style: .continuous)
                    .fill(Color(UIColor.secondarySystemBackground))
                    .frame(width: 90, height: 90)
                
                Image(systemName: "flag")
                    .font(.system(size: 32, weight: .regular))
                    .foregroundColor(DS.primary)
            }
            .padding(.bottom, DS.spacingS)
            
            VStack(spacing: DS.spacingXS) {
                Text("美好的改变，从今天开始".tr(appSettings.resolvedLanguage))
                    .font(.system(size: 16, weight: .medium))
                    .foregroundColor(DS.onSurface)
                
                Text("开启你的第一个小习惯吧".tr(appSettings.resolvedLanguage))
                    .font(.system(size: 14))
                    .foregroundColor(DS.onSurfaceVariant)
            }
            .multilineTextAlignment(.center)
            
            if let onAction = onAction {
                Button(action: onAction) {
                    Text("创建第一个习惯".tr(appSettings.resolvedLanguage))
                        .font(.system(size: 16, weight: .bold))
                        .foregroundColor(DS.primary)
                        .padding(.horizontal, 32)
                        .padding(.vertical, 14)
                        .background(DS.primary.opacity(0.1))
                        .clipShape(Capsule())
                }
                .padding(.top, DS.spacingS)
            }
        }
        .padding(.vertical, 40)
        .frame(maxWidth: .infinity)
    }
}
