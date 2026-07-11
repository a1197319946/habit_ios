import re

new_content = """import SwiftUI
import SwiftData

struct HomeView: View {
    @Environment(\\.modelContext) private var modelContext
    @EnvironmentObject private var appSettings: AppSettings
    @Query(filter: #Predicate<Habit> { $0.isArchived == false }, sort: \\Habit.order) private var habits: [Habit]
    @Query private var checkins: [Checkin]
    
    @State private var selectedDate: Date = Date()
    @State private var showingAmountSheet = false
    @State private var showingSuccessModal = false
    @State private var showingMakeupAlert = false
    @State private var showingMoodRecorder = false
    @State private var selectedHabit: Habit?
    @State private var initialAmountForSheet: Double?
    @State private var showConfetti = false
    
    // Bottom Sheet for interactions
    @State private var showingActionSheet = false
    
    private var todayDateString: String { formatDate(Date()) }
    private var selectedDateString: String { formatDate(selectedDate) }
    
    private var greetingString: String {
        let hour = Calendar.current.component(.hour, from: Date())
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
                VStack(alignment: .leading, spacing: 20) {
                    // Header & Month
                    HStack(alignment: .bottom) {
                        VStack(alignment: .leading, spacing: 6) {
                            Text(greetingString)
                                .font(.system(size: 28, weight: .bold, design: .rounded))
                                .foregroundColor(DS.onSurface)
                            Text(monthString(for: selectedDate))
                                .font(.system(size: 14, weight: .medium))
                                .foregroundColor(DS.onSurfaceVariant)
                        }
                        
                        Spacer()
                        
                        // Small icon or today indicator could go here
                        ZStack {
                            Circle().fill(DS.primaryContainer).frame(width: 40, height: 40)
                            Image(systemName: "calendar")
                                .font(.system(size: 16, weight: .semibold))
                                .foregroundColor(DS.primary)
                        }
                        .onTapGesture {
                            withAnimation { selectedDate = Date() }
                        }
                    }
                    .padding(.horizontal, DS.spacingL)
                    .padding(.top, DS.spacingL)
                    
                    // Weekly Calendar Slider
                    WeeklySlider(selectedDate: $selectedDate, checkins: checkins)
                    
                    // List for Habits
                    if habits.isEmpty {
                        Spacer(minLength: 0)
                        EmptyHabitsView()
                            .frame(maxWidth: .infinity)
                        Spacer(minLength: 0)
                    } else {
                        LazyVStack(spacing: DS.spacingM) {
                            ForEach(habits) { habit in
                                ListHabitCard(
                                    habit: habit,
                                    selectedDate: selectedDate,
                                    checkins: checkins,
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
                        .padding(.horizontal, DS.spacingL)
                        
                        Spacer(minLength: 24)
                        
                        // Motivational Banner
                        VStack {
                            Text("\\"Small steps, big changes.\\"".tr(appSettings.resolvedLanguage))
                                .font(.system(size: 16, weight: .bold, design: .rounded).italic())
                                .foregroundStyle(DS.onSurfaceVariant)
                                .opacity(0.8)
                                .padding(.bottom, 30)
                        }
                        .frame(maxWidth: .infinity)
                    }
                }
                .frame(minHeight: geo.size.height, alignment: .top)
            }
        }
        .background(AmbientBackground())
        // Overlays & Sheets
        .overlay { if showConfetti { ConfettiView() } }
        .sheet(isPresented: $showingSuccessModal) {
            if let selectedHabit = selectedHabit {
                CheckinSuccessView(
                    habit: selectedHabit,
                    date: selectedDate,
                    checkins: checkins,
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
            Text("对 \\(formatDate(selectedDate)) 补卡？")
        }
        .sheet(isPresented: $showingAmountSheet) {
            if let habit = selectedHabit {
                AmountCheckinSheet(
                    habit: habit,
                    date: selectedDate,
                    initialAmount: initialAmountForSheet ?? 0
                )
            }
        }
        .confirmationDialog(
            "Manage Check-in".tr(appSettings.resolvedLanguage),
            isPresented: $showingActionSheet,
            titleVisibility: .visible
        ) {
            Button("Undo Check-in".tr(appSettings.resolvedLanguage), role: .destructive) {
                if let h = selectedHabit { undoCheckin(habit: h) }
            }
            if selectedHabit?.goalType == "amount" {
                Button("Edit Amount".tr(appSettings.resolvedLanguage)) {
                    if let h = selectedHabit { editAmount(habit: h) }
                }
            }
            Button("Cancel".tr(appSettings.resolvedLanguage), role: .cancel) {}
        }
    }
    
    // MARK: - Actions
    private func isHabitChecked(habit: Habit) -> Bool {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        let dateString = formatter.string(from: selectedDate)
        return checkins.contains(where: { $0.habit?.id == habit.id && $0.dateString == dateString })
    }
    
    private func handleCheckinTap(habit: Habit) {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        let dateString = formatter.string(from: selectedDate)
        let isChecked = checkins.contains(where: { $0.habit?.id == habit.id && $0.dateString == dateString })
        
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
            initialAmountForSheet = habit.amountValue
            showingAmountSheet = true
        } else {
            let checkin = Checkin(dateString: formatDate(selectedDate))
            checkin.habit = habit
            modelContext.insert(checkin)
            try? modelContext.save()
            triggerSuccessSequence()
        }
    }
    
    private func undoCheckin(habit: Habit) {
        let dateString = formatDate(selectedDate)
        let checks = checkins.filter { $0.habit?.id == habit.id && $0.dateString == dateString }
        for check in checks {
            modelContext.delete(check)
        }
        try? modelContext.save()
    }
    
    private func editAmount(habit: Habit) {
        let dateString = formatDate(selectedDate)
        if let firstCheckin = checkins.first(where: { $0.habit?.id == habit.id && $0.dateString == dateString }) {
            initialAmountForSheet = firstCheckin.amount
        } else {
            initialAmountForSheet = habit.amountValue
        }
        showingAmountSheet = true
    }
    
    private func triggerSuccessSequence() {
        showConfetti = true
        let impact = UIImpactFeedbackGenerator(style: .medium)
        impact.impactOccurred()
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            showConfetti = false
            showingSuccessModal = true
        }
    }
    
    private func formatDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        return formatter.string(from: date)
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
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        let dateString = formatter.string(from: selectedDate)
        return checkins.contains(where: { $0.habit?.id == habit.id && $0.dateString == dateString })
    }
    
    var periodTarget: Int {
        habit.frequencyType == "weekly" ? habit.weeklyTarget : habit.monthlyTarget
    }
    
    var periodCompleted: Int {
        let calendar = Calendar.current
        let targetComponent: Calendar.Component = habit.frequencyType == "weekly" ? .weekOfYear : .month
        let interval = calendar.dateInterval(of: targetComponent, for: selectedDate)
        
        guard let start = interval?.start, let end = interval?.end else { return 0 }
        
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        
        let validCheckins = checkins.filter {
            guard $0.habit?.id == habit.id else { return false }
            guard let date = formatter.date(from: $0.dateString) else { return false }
            return date >= start && date < end
        }
        
        if habit.goalType == "amount" {
            // Count unique days for frequency goal completion
            let uniqueDays = Set(validCheckins.map { $0.dateString })
            return uniqueDays.count
        } else {
            return validCheckins.count
        }
    }
    
    var progressFraction: Double {
        if periodTarget == 0 { return 0.0 }
        return min(1.0, Double(periodCompleted) / Double(periodTarget))
    }
    
    var progressText: String {
        if habit.goalType == "amount" {
            let formatter = DateFormatter()
            formatter.dateFormat = "yyyy-MM-dd"
            let dateString = formatter.string(from: selectedDate)
            let hCheckins = checkins.filter { $0.habit?.id == habit.id && $0.dateString == dateString }
            let target = habit.amountValue
            let sum = hCheckins.reduce(0) { $0 + $1.amount }
            
            // Format number cleanly
            let sumFormatted = sum.truncatingRemainder(dividingBy: 1) == 0 ? String(format: "%.0f", sum) : String(format: "%.1f", sum)
            let targetFormatted = target.truncatingRemainder(dividingBy: 1) == 0 ? String(format: "%.0f", target) : String(format: "%.1f", target)
            
            return "\\(sumFormatted)/\\(targetFormatted) \\(habit.amountUnit)"
        } else {
            return "\\(periodCompleted)/\\(periodTarget)\(" times".tr(appSettings.resolvedLanguage))"
        }
    }
    
    var body: some View {
        Button(action: {
            onTapCard()
        }) {
            HStack(spacing: 16) {
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
                VStack(alignment: .leading, spacing: 6) {
                    Text(habit.name)
                        .font(.system(size: 16, weight: .bold))
                        .foregroundColor(DS.onSurface)
                        .lineLimit(1)
                    
                    HStack(spacing: 8) {
                        Text(habit.frequencyType == "weekly" ? "Weekly".tr(appSettings.resolvedLanguage) : "Monthly".tr(appSettings.resolvedLanguage))
                            .font(.system(size: 10, weight: .semibold))
                            .foregroundColor(Color(hex: habit.color))
                            .padding(.horizontal, 6)
                            .padding(.vertical, 3)
                            .background(Color(hex: habit.color).opacity(0.1))
                            .clipShape(Capsule())
                        
                        Text(progressText)
                            .font(.system(size: 12, weight: .medium))
                            .foregroundColor(DS.onSurfaceVariant)
                    }
                }
                
                Spacer()
                
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
                                    .stroke(isChecked ? Color.clear : Color(hex: habit.color).opacity(0.4), lineWidth: 2)
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
            .background(Color.white)
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
    
    @State private var weekOffset: Int? = 0
    private let calendar = Calendar.current
    private let weekRange = -50...50
    
    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            LazyHStack(spacing: 0) {
                ForEach(weekRange, id: \\.self) { offset in
                    weekView(for: offset)
                        .containerRelativeFrame(.horizontal)
                        .id(offset)
                }
            }
            .scrollTargetLayout()
        }
        .scrollTargetBehavior(.paging)
        .scrollPosition(id: $weekOffset)
        .frame(height: 90)
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
        
        return HStack(spacing: 8) {
            ForEach(days, id: \\.self) { date in
                let isSelected = calendar.isDate(date, inSameDayAs: selectedDate)
                let isToday = calendar.isDateInToday(date)
                let dayStr = shortDayString(for: date)
                let dayNum = calendar.component(.day, from: date)
                let isCheckedIn = checkins.contains(where: { $0.dateString == formatDate(date) })
                
                Button(action: {
                    withAnimation { selectedDate = date }
                }) {
                    VStack(spacing: 8) {
                        Text(dayStr.tr(appSettings.resolvedLanguage))
                            .font(.system(size: 12, weight: .medium))
                            .foregroundColor(isSelected ? .white : DS.onSurfaceVariant)
                        
                        Text("\\(dayNum)")
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
                                Color.white.opacity(0.6)
                            }
                        }
                    )
                    .clipShape(Capsule())
                    .shadow(color: isSelected ? DS.primary.opacity(0.3) : .clear, radius: 8, x: 0, y: 4)
                }
                .buttonStyle(PlainButtonStyle())
            }
        }
        .padding(.horizontal, DS.spacingL)
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
    var body: some View {
        VStack(spacing: DS.spacingL) {
            Text("No habits yet".tr(appSettings.resolvedLanguage))
                .headlineMd()
                .foregroundColor(DS.onSurface)
            
            Text("Click the + button to add your first habit".tr(appSettings.resolvedLanguage))
                .bodyMd()
                .foregroundColor(DS.onSurfaceVariant)
                .multilineTextAlignment(.center)
        }
        .padding(DS.spacingXL)
        .background(Color.white)
        .clipShape(RoundedRectangle(cornerRadius: 20))
        .padding(.horizontal, DS.spacingL)
    }
}
"""

with open('Sources/HomeView.swift', 'w') as f:
    f.write(new_content)
