import SwiftUI
import SwiftData

struct HomeView: View {
    @Environment(\.modelContext) private var modelContext
    @EnvironmentObject private var appSettings: AppSettings
    @Query(filter: #Predicate<Habit> { $0.isArchived == false }, sort: \Habit.order) private var habits: [Habit]
    @Query private var checkins: [Checkin]
    
    @State private var selectedDate: Date = Date()
    @State private var showingAmountSheet = false
    @State private var showingSuccessModal = false
    @State private var showingMakeupAlert = false
    @State private var showingMoodRecorder = false
    @State private var selectedHabit: Habit?
    @State private var initialAmountForSheet: Double?
    @State private var showConfetti = false
    
    private var todayDateString: String { formatDate(Date()) }
    private var selectedDateString: String { formatDate(selectedDate) }
    
    let columns = [
        GridItem(.adaptive(minimum: 110), spacing: DS.spacingM)
    ]
    
    var body: some View {
        GeometryReader { geo in
            ScrollView(showsIndicators: false) {
                VStack(alignment: .leading, spacing: 16) {
                    // Header & Month
                    HStack(alignment: .bottom) {
                        VStack(alignment: .leading, spacing: 4) {
                            Text("Good Morning.".tr(appSettings.resolvedLanguage))
                                .display()
                                .foregroundColor(DS.onSurface)
                            Text("今天也要加油哦 💪")
                                .bodyLg()
                                .foregroundColor(DS.onSurfaceVariant)
                        }
                        
                        Spacer()
                        
                        // Month Display
                        Text(monthString(for: selectedDate))
                            .font(.system(size: 16, weight: .bold))
                            .foregroundColor(DS.onSurfaceVariant)
                            .padding(.bottom, 2)
                    }
                    .padding(.horizontal, DS.spacingL)
                    .padding(.top, DS.spacingM)
                    
                    // Weekly Calendar Slider
                    WeeklySlider(selectedDate: $selectedDate, checkins: checkins)
                    
                    // Bento Grid for Habits
                    if habits.isEmpty {
                        Spacer(minLength: 0)
                        EmptyHabitsView()
                            .frame(maxWidth: .infinity)
                        Spacer(minLength: 0)
                    } else {
                        LazyVGrid(columns: columns, spacing: DS.spacingM) {
                            ForEach(habits) { habit in
                                BentoHabitCard(
                                    habit: habit,
                                    selectedDate: selectedDate,
                                    checkins: checkins,
                                    onTap: { handleCheckinTap(habit: habit) },
                                    onUndo: { undoCheckin(habit: habit) },
                                    onEditAmount: { editAmount(habit: habit) }
                                )
                            }
                        }
                        .padding(.horizontal, DS.spacingL)
                        
                        Spacer(minLength: 16)
                        
                        // Motivational Banner
                        VStack {
                            Text("\"Small steps, big changes.\"".tr(appSettings.resolvedLanguage))
                                .font(.system(size: 20, weight: .bold, design: .rounded).italic())
                                .foregroundStyle(
                                    LinearGradient(
                                        colors: [DS.primary, DS.secondary],
                                        startPoint: .leading,
                                        endPoint: .trailing
                                    )
                                )
                                .opacity(0.8)
                                .padding(.bottom, 20)
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
            Text("对 \(formatDate(selectedDate)) 补卡？")
        }
        .sheet(isPresented: $showingAmountSheet) {
            if let habit = selectedHabit {
                AmountCheckinSheet(habit: habit, selectedDate: selectedDate, initialAmount: initialAmountForSheet) {
                    let wasNewCheckin = (initialAmountForSheet == nil)
                    initialAmountForSheet = nil
                    showingAmountSheet = false
                    if wasNewCheckin { triggerSuccessSequence() }
                }
                .presentationDetents([.height(680)])
                .presentationDragIndicator(.visible)
            }
        }
        .onAppear {
            selectedDate = Date()
        }
    }
    
    private func handleCheckinTap(habit: Habit) {
        let dateString = formatDate(selectedDate)
        let todayString = formatDate(Date())
        if selectedDate > Date() && dateString != todayString { return }
        selectedHabit = habit
        processCheckin()
    }
    
    private func undoCheckin(habit: Habit) {
        let dateString = formatDate(selectedDate)
        if let existing = checkins.first(where: { $0.habit?.id == habit.id && $0.dateString == dateString }) {
            withAnimation {
                modelContext.delete(existing)
            }
        }
    }
    
    private func editAmount(habit: Habit) {
        let dateString = formatDate(selectedDate)
        selectedHabit = habit
        if let existing = checkins.first(where: { $0.habit?.id == habit.id && $0.dateString == dateString }) {
            initialAmountForSheet = existing.amount
            showingAmountSheet = true
        }
    }
    
    private func processCheckin() {
        let dateString = formatDate(selectedDate)
        let todayString = formatDate(Date())
        guard let habit = selectedHabit else { return }
        if dateString != todayString && selectedDate < Date() {
            showingMakeupAlert = true
        } else {
            executeCheckin(habit: habit)
        }
    }
    
    private func executeCheckin(habit: Habit) {
        if habit.goalType == "amount" {
            initialAmountForSheet = nil
            showingAmountSheet = true
        } else {
            let newCheckin = Checkin(dateString: formatDate(selectedDate), amount: 1)
            newCheckin.habit = habit
            modelContext.insert(newCheckin)
            triggerSuccessSequence()
        }
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

// MARK: - Bento Habit Card
struct BentoHabitCard: View {
    let habit: Habit
    let selectedDate: Date
    let checkins: [Checkin]
    @EnvironmentObject private var appSettings: AppSettings
    let onTap: () -> Void
    let onUndo: () -> Void
    let onEditAmount: () -> Void
    
    @State private var showingConfirm = false
    
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
        
        let uniqueDays = Set(validCheckins.map { $0.dateString })
        return uniqueDays.count
    }
    
    var progressFraction: Double {
        if habit.goalType == "amount" {
            let formatter = DateFormatter()
            formatter.dateFormat = "yyyy-MM-dd"
            let dateString = formatter.string(from: selectedDate)
            let hCheckins = checkins.filter { $0.habit?.id == habit.id && $0.dateString == dateString }
            let target = habit.amountValue
            let sum = hCheckins.reduce(0) { $0 + $1.amount }
            return target > 0 ? min(sum / target, 1.0) : 0
        } else {
            let target = periodTarget
            return target > 0 ? min(Double(periodCompleted) / Double(target), 1.0) : 0
        }
    }
    
    var progressText: String {
        if habit.goalType == "amount" {
            let formatter = DateFormatter()
            formatter.dateFormat = "yyyy-MM-dd"
            let dateString = formatter.string(from: selectedDate)
            let hCheckins = checkins.filter { $0.habit?.id == habit.id && $0.dateString == dateString }
            let target = habit.amountValue
            let sum = hCheckins.reduce(0) { $0 + $1.amount }
            return "\(Int(sum))/\(Int(target)) \(habit.amountUnit)"
        } else {
            return "\(periodCompleted)/\(periodTarget)\(" times".tr(appSettings.resolvedLanguage))"
        }
    }
    
    var body: some View {
        Button(action: {
            if isChecked {
                withAnimation(.spring()) { showingConfirm.toggle() }
            } else {
                onTap()
            }
        }) {
            if showingConfirm {
                VStack(spacing: DS.spacingS) {
                    Text("Undo Check-in?".tr(appSettings.resolvedLanguage))
                        .font(.system(size: 14, weight: .bold))
                        .foregroundColor(DS.onSurface)
                        .padding(.bottom, 4)
                    
                    Button(action: {
                        withAnimation { showingConfirm = false }
                        onUndo()
                    }) {
                        Text("Undo".tr(appSettings.resolvedLanguage))
                            .font(.system(size: 13, weight: .semibold))
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 8)
                            .background(Color.red.opacity(0.8))
                            .cornerRadius(8)
                    }
                    
                    if habit.goalType == "amount" {
                        Button(action: {
                            withAnimation { showingConfirm = false }
                            onEditAmount()
                        }) {
                            Text("Edit Amount".tr(appSettings.resolvedLanguage))
                                .font(.system(size: 13, weight: .semibold))
                                .foregroundColor(.white)
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 8)
                                .background(DS.primary.opacity(0.8))
                                .cornerRadius(8)
                        }
                    }
                    
                    Button(action: {
                        withAnimation { showingConfirm = false }
                    }) {
                        Text("Cancel".tr(appSettings.resolvedLanguage))
                            .font(.system(size: 13, weight: .semibold))
                            .foregroundColor(DS.onSurfaceVariant)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 8)
                            .background(DS.surfaceVariant)
                            .cornerRadius(8)
                    }
                }
                .padding(DS.spacingL)
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .background(
                    ZStack {
                        Color.white.opacity(0.7)
                        Circle()
                            .fill(Color(hex: habit.color).opacity(0.15))
                            .frame(width: 120, height: 120)
                            .blur(radius: 40)
                            .padding(12)
                    }
                )
                .background(.ultraThinMaterial)
                .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
                .overlay(
                    RoundedRectangle(cornerRadius: 16, style: .continuous)
                        .stroke(Color.white, lineWidth: 1)
                )
                .shadow(color: Color(hex: habit.color).opacity(0.08), radius: 20, x: 0, y: 10)
            } else {
                VStack(alignment: .leading, spacing: 0) {
                    HStack(alignment: .top) {
                        ZStack {
                            Circle()
                                .fill(isChecked ? Color(hex: "#4CD964") : Color(hex: habit.color).opacity(0.1))
                                .frame(width: 36, height: 36)
                            
                            if isChecked {
                                Image(systemName: "checkmark")
                                    .font(.system(size: 16, weight: .bold))
                                    .foregroundColor(.white)
                                    .transition(
                                        AnyTransition.asymmetric(
                                            insertion: .scale(scale: 1.5).combined(with: .opacity).animation(.spring(response: 0.3, dampingFraction: 0.4, blendDuration: 0.5)),
                                            removal: .scale.combined(with: .opacity)
                                        ))
                            } else {
                                Image(systemName: habit.icon)
                                    .font(.system(size: 16))
                                    .foregroundColor(Color(hex: habit.color))
                                    .transition(.scale.combined(with: .opacity))
                            }
                        }
                        .animation(.spring(response: 0.3, dampingFraction: 0.5, blendDuration: 0.5), value: isChecked)
                        Spacer()
                        // Time Tag & Progress
                        VStack(alignment: .trailing, spacing: 4) {
                            Text(habit.frequencyType == "weekly" ? "Weekly".tr(appSettings.resolvedLanguage) : "Monthly".tr(appSettings.resolvedLanguage))
                                .font(.system(size: 10))
                                .foregroundColor(Color(hex: habit.color))
                                .padding(.horizontal, 8)
                                .padding(.vertical, 4)
                                .background(Color(hex: habit.color).opacity(0.1))
                                .clipShape(Capsule())
                            
                            Text(progressText)
                                .font(.system(size: 10, weight: .semibold))
                                .foregroundColor(Color(hex: habit.color).opacity(0.8))
                        }
                    }
                    .padding(.bottom, 12)
                    
                    Text(habit.name)
                        .font(.system(size: 14, weight: .bold))
                        .foregroundColor(DS.onSurface)
                        .lineLimit(1)
                        .padding(.bottom, 12)
                    
                    // Progress Bar Area
                    VStack(spacing: 8) {
                        HStack {
                            Text("Goal".tr(appSettings.resolvedLanguage))
                                .labelMd()
                                .foregroundColor(DS.onSurfaceVariant)
                            Spacer()
                            Text("\(Int(progressFraction * 100))%")
                                .labelMd()
                                .bold()
                                .foregroundColor(Color(hex: habit.color))
                        }
                        
                        GeometryReader { geo in
                            ZStack(alignment: .leading) {
                                RoundedRectangle(cornerRadius: 4)
                                    .fill(DS.surfaceVariant)
                                    .frame(height: 8)
                                
                                RoundedRectangle(cornerRadius: 4)
                                    .fill(Color(hex: habit.color))
                                    .frame(width: geo.size.width * CGFloat(progressFraction), height: 8)
                                    .animation(.spring(), value: progressFraction)
                            }
                        }
                        .frame(height: 8)
                    }
                }
                .padding(DS.spacingL)
                .frame(maxWidth: .infinity, alignment: .leading)
                .background(
                    ZStack {
                        // Glass background
                        Color.white.opacity(0.7)
                        
                        // Blur radial at top right
                        Circle()
                            .fill(Color(hex: habit.color).opacity(0.15))
                            .frame(width: 120, height: 120)
                            .blur(radius: 40)
                            .padding(12)
                    }
                )
                .background(.ultraThinMaterial)
                .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
                .overlay(
                    RoundedRectangle(cornerRadius: 16, style: .continuous)
                        .stroke(Color.white, lineWidth: 1)
                )
                .opacity(isChecked ? 0.85 : 1.0)
                .shadow(color: Color(hex: habit.color).opacity(0.08), radius: 20, x: 0, y: 10)
            }
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
        .frame(height: 100)
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
        
        return HStack(spacing: 0) {
            ForEach(days, id: \.self) { date in
                let isSelected = calendar.isDate(date, inSameDayAs: selectedDate)
                let isToday = calendar.isDateInToday(date)
                let dayStr = shortDayString(for: date)
                let dayNum = calendar.component(.day, from: date)
                let isCheckedIn = checkins.contains(where: { $0.dateString == formatDate(date) })
                
                Button(action: {
                    withAnimation { selectedDate = date }
                }) {
                    VStack(spacing: 6) {
                        Text(dayStr.tr(appSettings.resolvedLanguage))
                            .font(.system(size: 11))
                            .foregroundColor(isSelected ? .white : (isToday ? DS.primary : DS.onSurfaceVariant))
                        
                        Text("\(dayNum)")
                            .font(.system(size: 15, weight: isToday ? .heavy : .bold))
                            .foregroundColor(isSelected ? .white : (isToday ? DS.primary : DS.onSurface))
                        
                        Circle()
                            .fill(isSelected ? (isCheckedIn ? .white : .clear) : (isCheckedIn ? DS.primary : .clear))
                            .frame(width: 4, height: 4)
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 10)
                    .background(
                        Group {
                            if isSelected {
                                DS.primary
                            } else {
                                Color.clear
                            }
                        }
                    )
                    .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
                    .overlay(
                        Group {
                            if isToday && !isSelected {
                                RoundedRectangle(cornerRadius: 16, style: .continuous)
                                    .stroke(DS.primary, lineWidth: 1.5)
                            }
                        }
                    )
                    .shadow(color: isSelected ? DS.primary.opacity(0.3) : .clear, radius: 10, x: 0, y: 5)
                    .scaleEffect(isSelected ? 1.05 : 1.0)
                    .padding(.horizontal, 4)
                }
                .buttonStyle(PlainButtonStyle())
            }
        }
        .padding(.vertical, 15)
        .padding(.horizontal, DS.spacingL - 4)
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

// Ensure EmptyHabitsView matches the glassmorphism
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
        .card()
        .padding(.horizontal, DS.spacingL)
    }
}
