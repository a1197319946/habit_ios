import SwiftUI
import SwiftData

struct HomeView: View {
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \Habit.order) private var habits: [Habit]
    @Query private var checkins: [Checkin]
    
    @State private var selectedDate: Date = Date()
    @State private var icloudEnabled: Bool = true
    
    @State private var showingAmountSheet = false
    @State private var showingMoodSheet = false
    @State private var showingSuccessModal = false
    @State private var showingMakeupAlert = false
    @State private var showHabitActionSheet = false
    
    @State private var selectedHabit: Habit?
    @State private var initialAmountForSheet: Double?
    @State private var showConfetti = false
    
    // Computed
    private var todayDateString: String { formatDate(Date()) }
    private var selectedDateString: String { formatDate(selectedDate) }
    
    private var completedToday: Int {
        habits.filter { habit in
            checkins.contains { $0.habit?.id == habit.id && $0.dateString == selectedDateString }
        }.count
    }
    
    private var progressFraction: CGFloat {
        guard !habits.isEmpty else { return 0 }
        return CGFloat(completedToday) / CGFloat(habits.count)
    }
    
    var body: some View {
        NavigationView {
            ZStack {
                DS.bgPrimary.edgesIgnoringSafeArea(.all)
                
                ScrollView {
                    VStack(spacing: 0) {
                        
                        // ── Top Bar ──
                        HStack(alignment: .center) {
                            HStack(spacing: 10) {
                                Image("app_logo")
                                    .resizable()
                                    .scaledToFit()
                                    .frame(width: 28, height: 28)
                                    .clipShape(Circle())
                                Text("小习惯")
                                    .font(.system(size: 20, weight: .bold, design: .rounded))
                                    .foregroundColor(DS.textPrimary)
                            }
                            
                            Spacer()
                            
                            NavigationLink(destination: HabitListView()) {
                                Text("管理")
                                    .font(.system(size: 15, weight: .medium))
                                    .foregroundColor(DS.textSecondary)
                                    .padding(.horizontal, 14)
                                    .padding(.vertical, 7)
                                    .background(DS.bgSubtle)
                                    .cornerRadius(DS.cornerPill)
                            }
                        }
                        .padding(.horizontal, DS.spacingL)
                        .padding(.top, 60)
                        .padding(.bottom, DS.spacingM)
                        
                        // ── iCloud Banner ──
                        if !icloudEnabled {
                            HStack(spacing: 8) {
                                Image(systemName: "exclamationmark.circle")
                                    .foregroundColor(DS.accent)
                                    .font(.system(size: 14))
                                Text("未开启 iCloud，数据将无法跨设备同步")
                                    .font(.system(size: 13))
                                    .foregroundColor(DS.textSecondary)
                            }
                            .padding(.horizontal, DS.spacingM)
                            .padding(.vertical, 10)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .background(DS.accentMuted)
                            .cornerRadius(DS.cornerSmall)
                            .padding(.horizontal, DS.spacingL)
                            .padding(.bottom, DS.spacingM)
                        }
                        
                        // ── Week Calendar ──
                        WeeklyCalendarView(selectedDate: $selectedDate, checkins: checkins)
                            .padding(.horizontal, DS.spacingL)
                            .padding(.bottom, DS.spacingL)
                        
                        // ── Hero Stats ──
                        if !habits.isEmpty {
                            HeroStatsView(
                                completed: completedToday,
                                total: habits.count,
                                progress: progressFraction,
                                date: selectedDate
                            )
                            .padding(.horizontal, DS.spacingL)
                            .padding(.bottom, DS.spacingL)
                        }
                        
                        // ── Habits List ──
                        if habits.isEmpty {
                            EmptyHabitsView()
                                .padding(.top, DS.spacingXL)
                        } else {
                            VStack(spacing: 0) {
                                ForEach(Array(habits.enumerated()), id: \.element.id) { index, habit in
                                    HabitRow(
                                        habit: habit,
                                        selectedDate: selectedDate,
                                        checkins: checkins,
                                        onCheckin: { handleCheckinTap(habit: habit) }
                                    )
                                    
                                    if index < habits.count - 1 {
                                        JDivider()
                                            .padding(.horizontal, DS.spacingL)
                                    }
                                }
                            }
                            .card(cornerRadius: DS.cornerCard)
                            .padding(.horizontal, DS.spacingL)
                        }
                        
                        Spacer().frame(height: 100)
                    }
                }
                
                // Confetti
                if showConfetti {
                    ConfettiView()
                }
            }
            .navigationBarHidden(true)
            .sheet(isPresented: $showingSuccessModal) {
                if let selectedHabit = selectedHabit {
                    CheckinSuccessView(
                        habit: selectedHabit,
                        date: selectedDate,
                        checkins: checkins,
                        onRecordMood: { showingMoodSheet = true }
                    )
                    .presentationDetents([.fraction(0.65)])
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
            .confirmationDialog("管理打卡", isPresented: $showHabitActionSheet, titleVisibility: .hidden) {
                if let habit = selectedHabit {
                    if let existing = checkins.first(where: { $0.habit?.id == habit.id && $0.dateString == selectedDateString }) {
                        if habit.goalType == "amount" {
                            Button("修改数据") {
                                initialAmountForSheet = existing.amount
                                showingAmountSheet = true
                            }
                        }
                        Button("撤销打卡", role: .destructive) { modelContext.delete(existing) }
                    } else {
                        Button("打卡") { processCheckin() }
                    }
                }
            }
            .sheet(isPresented: $showingAmountSheet) {
                if let habit = selectedHabit {
                    AmountCheckinSheet(habit: habit, selectedDate: selectedDate, initialAmount: initialAmountForSheet) {
                        showingAmountSheet = false
                        if initialAmountForSheet == nil { triggerSuccessSequence() }
                    }
                    .presentationDetents([.fraction(0.6)])
                }
            }
            .sheet(isPresented: $showingMoodSheet) {
                if let habit = selectedHabit {
                    MoodRecorderView(habit: habit)
                        .presentationDetents([.medium, .large])
                }
            }
        }
    }
    
    private func handleCheckinTap(habit: Habit) {
        let dateString = formatDate(selectedDate)
        let todayString = formatDate(Date())
        if selectedDate > Date() && dateString != todayString { return }
        selectedHabit = habit
        if checkins.contains(where: { $0.habit?.id == habit.id && $0.dateString == dateString }) {
            showHabitActionSheet = true
        } else {
            processCheckin()
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
}

// MARK: - Hero Stats

struct HeroStatsView: View {
    let completed: Int
    let total: Int
    let progress: CGFloat
    let date: Date
    
    private var isToday: Bool { Calendar.current.isDateInToday(date) }
    
    var body: some View {
        VStack(alignment: .leading, spacing: DS.spacingM) {
            // Date label
            Text(isToday ? "今天" : shortDateLabel(date))
                .font(.system(size: 13, weight: .medium))
                .foregroundColor(DS.textSecondary)
            
            // Big number
            HStack(alignment: .lastTextBaseline, spacing: 4) {
                Text("\(completed)")
                    .font(.system(size: 56, weight: .heavy, design: .rounded))
                    .foregroundColor(DS.accent)
                Text("/ \(total)")
                    .font(.system(size: 22, weight: .semibold, design: .rounded))
                    .foregroundColor(DS.textSecondary)
                Spacer()
                
                if completed == total && total > 0 {
                    Text("全部完成 🎉")
                        .font(.system(size: 13, weight: .semibold))
                        .foregroundColor(DS.success)
                        .padding(.horizontal, 12)
                        .padding(.vertical, 6)
                        .background(DS.successMuted)
                        .cornerRadius(DS.cornerPill)
                }
            }
            
            // Progress bar
            GeometryReader { geo in
                ZStack(alignment: .leading) {
                    RoundedRectangle(cornerRadius: 4)
                        .fill(DS.border)
                        .frame(height: 4)
                    
                    RoundedRectangle(cornerRadius: 4)
                        .fill(completed == total && total > 0 ? DS.success : DS.accent)
                        .frame(width: geo.size.width * progress, height: 4)
                        .animation(.spring(response: 0.5, dampingFraction: 0.8), value: progress)
                }
            }
            .frame(height: 4)
        }
        .padding(DS.spacingL)
        .card()
    }
    
    private func shortDateLabel(_ date: Date) -> String {
        let f = DateFormatter()
        f.dateFormat = "M月d日"
        return f.string(from: date)
    }
}

// MARK: - Empty State

struct EmptyHabitsView: View {
    var body: some View {
        VStack(spacing: DS.spacingL) {
            Text("还没有习惯")
                .font(.system(size: 22, weight: .bold, design: .rounded))
                .foregroundColor(DS.textPrimary)
            
            Text("点击下方按钮，开始你的第一个习惯吧")
                .font(.system(size: 15))
                .foregroundColor(DS.textSecondary)
                .multilineTextAlignment(.center)
            
            NavigationLink(destination: HabitDetailView(habit: nil)) {
                HStack(spacing: 6) {
                    Image(systemName: "plus")
                        .font(.system(size: 15, weight: .bold))
                    Text("创建习惯")
                        .font(.system(size: 16, weight: .semibold))
                }
                .foregroundColor(.white)
                .padding(.horizontal, DS.spacingXL)
                .padding(.vertical, DS.spacingM)
                .background(DS.accent)
                .cornerRadius(DS.cornerPill)
            }
        }
        .padding(.horizontal, DS.spacingXL)
    }
}

// MARK: - Habit Row (Single column list)

struct HabitRow: View {
    let habit: Habit
    let selectedDate: Date
    let checkins: [Checkin]
    let onCheckin: () -> Void
    
    @State private var isPressed = false
    
    var isChecked: Bool {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        let dateString = formatter.string(from: selectedDate)
        return checkins.contains(where: { $0.habit?.id == habit.id && $0.dateString == dateString })
    }
    
    var progressText: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        let dateString = formatter.string(from: selectedDate)
        let hCheckins = checkins.filter { $0.habit?.id == habit.id }
        let freqLabel = habit.frequencyType == "weekly" ? "周" : "月"
        if habit.goalType == "amount" {
            let target = habit.amountValue
            let sum = hCheckins.filter { $0.dateString == dateString }.reduce(0) { $0 + $1.amount }
            return "\(freqLabel) · \(Int(sum))/\(Int(target)) \(habit.amountUnit)"
        } else {
            let target = habit.frequencyType == "weekly" ? habit.weeklyTarget : habit.monthlyTarget
            let count = hCheckins.filter { $0.dateString == dateString }.count
            return "\(freqLabel) · \(count)/\(target) 次"
        }
    }
    
    var body: some View {
        HStack(spacing: DS.spacingM) {
            // Color dot + icon
            ZStack {
                Circle()
                    .fill(isChecked ? DS.successMuted : Color(hex: habit.color).opacity(0.12))
                    .frame(width: 44, height: 44)
                
                Image(systemName: isChecked ? "checkmark" : habit.icon)
                    .font(.system(size: isChecked ? 16 : 18, weight: .semibold))
                    .foregroundColor(isChecked ? DS.success : Color(hex: habit.color))
            }
            
            // Text
            VStack(alignment: .leading, spacing: 3) {
                Text(habit.name)
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(isChecked ? DS.textSecondary : DS.textPrimary)
                    .strikethrough(isChecked, color: DS.textSecondary)
                
                Text(progressText)
                    .font(.system(size: 12, weight: .medium))
                    .foregroundColor(DS.textTertiary)
            }
            
            Spacer()
            
            // Check button
            Button(action: {
                let impact = UIImpactFeedbackGenerator(style: .medium)
                impact.impactOccurred()
                onCheckin()
            }) {
                if isChecked {
                    Text("已打卡")
                        .font(.system(size: 13, weight: .semibold))
                        .foregroundColor(DS.success)
                        .padding(.horizontal, 14)
                        .padding(.vertical, 7)
                        .background(DS.successMuted)
                        .cornerRadius(DS.cornerPill)
                } else {
                    Text("打卡")
                        .font(.system(size: 13, weight: .semibold))
                        .foregroundColor(.white)
                        .padding(.horizontal, 14)
                        .padding(.vertical, 7)
                        .background(DS.accent)
                        .cornerRadius(DS.cornerPill)
                }
            }
        }
        .padding(.horizontal, DS.spacingL)
        .padding(.vertical, DS.spacingM)
        .scaleEffect(isPressed ? 0.98 : 1.0)
        .animation(.spring(response: 0.2, dampingFraction: 0.8), value: isPressed)
        .contentShape(Rectangle())
    }
}

// MARK: - Weekly Calendar

struct WeeklyCalendarView: View {
    @Binding var selectedDate: Date
    var checkins: [Checkin]
    
    @State private var weeks: [[Date]] = []
    @State private var currentWeekIndex: Int = 1
    
    init(selectedDate: Binding<Date>, checkins: [Checkin]) {
        self._selectedDate = selectedDate
        self.checkins = checkins
    }
    
    var body: some View {
        VStack(spacing: DS.spacingM) {
            TabView(selection: $currentWeekIndex) {
                ForEach(0..<weeks.count, id: \.self) { index in
                    HStack(spacing: 0) {
                        ForEach(weeks[index], id: \.self) { date in
                            DayCell(date: date, selectedDate: selectedDate, checkins: checkins)
                                .onTapGesture {
                                    withAnimation(.spring(response: 0.3, dampingFraction: 0.8)) {
                                        selectedDate = date
                                    }
                                }
                        }
                    }
                    .tag(index)
                }
            }
            .tabViewStyle(PageTabViewStyle(indexDisplayMode: .never))
            .frame(height: 72)
        }
        .onAppear { setupWeeks() }
        .onChange(of: currentWeekIndex) { _, newIndex in
            if newIndex == 0 { shiftWeeks(by: -1) }
            else if newIndex == 2 { shiftWeeks(by: 1) }
        }
    }
    
    private func setupWeeks() {
        let current = week(for: Date())
        let past = week(for: Calendar.current.date(byAdding: .day, value: -7, to: Date())!)
        let future = week(for: Calendar.current.date(byAdding: .day, value: 7, to: Date())!)
        weeks = [past, current, future]
        currentWeekIndex = 1
    }
    
    private func shiftWeeks(by offset: Int) {
        let centerDate = weeks[1][0]
        let newCenter = Calendar.current.date(byAdding: .day, value: offset * 7, to: centerDate)!
        weeks = [
            week(for: Calendar.current.date(byAdding: .day, value: -7, to: newCenter)!),
            week(for: newCenter),
            week(for: Calendar.current.date(byAdding: .day, value: 7, to: newCenter)!)
        ]
        currentWeekIndex = 1
    }
    
    private func week(for date: Date) -> [Date] {
        var cal = Calendar.current
        cal.firstWeekday = 2
        let comp = cal.dateComponents([.yearForWeekOfYear, .weekOfYear], from: date)
        let startOfWeek = cal.date(from: comp)!
        return (0..<7).compactMap { cal.date(byAdding: .day, value: $0, to: startOfWeek) }
    }
}

// MARK: - Day Cell

struct DayCell: View {
    let date: Date
    let selectedDate: Date
    let checkins: [Checkin]
    
    private let weekdays = ["日", "一", "二", "三", "四", "五", "六"]
    private var isSelected: Bool { Calendar.current.isDate(date, inSameDayAs: selectedDate) }
    private var isToday: Bool { Calendar.current.isDateInToday(date) }
    private var isFuture: Bool { date > Date() && !isToday }
    
    private var hasCheckin: Bool {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        let dateString = formatter.string(from: date)
        return checkins.contains { $0.dateString == dateString }
    }
    
    var body: some View {
        VStack(spacing: 6) {
            Text(weekdays[Calendar.current.component(.weekday, from: date) - 1])
                .font(.system(size: 11, weight: .medium))
                .foregroundColor(isSelected ? DS.accent : DS.textTertiary)
            
            ZStack {
                if isSelected {
                    RoundedRectangle(cornerRadius: 10)
                        .fill(DS.accent)
                        .frame(width: 36, height: 36)
                } else if isToday {
                    RoundedRectangle(cornerRadius: 10)
                        .fill(DS.accentMuted)
                        .frame(width: 36, height: 36)
                }
                
                VStack(spacing: 2) {
                    Text("\(Calendar.current.component(.day, from: date))")
                        .font(.system(size: 16, weight: isSelected ? .bold : .medium))
                        .foregroundColor(
                            isSelected ? .white :
                            (isFuture ? DS.textTertiary :
                            (isToday ? DS.accent : DS.textPrimary))
                        )
                    
                    if hasCheckin {
                        Circle()
                            .fill(isSelected ? .white : DS.success)
                            .frame(width: 4, height: 4)
                    } else {
                        Circle()
                            .fill(Color.clear)
                            .frame(width: 4, height: 4)
                    }
                }
            }
            .frame(width: 36, height: 36)
        }
        .frame(maxWidth: .infinity)
        .contentShape(Rectangle())
    }
}

// MARK: - Custom Top Corners

struct CustomTopCorners: Shape {
    var radius: CGFloat
    func path(in rect: CGRect) -> Path {
        var path = Path()
        path.move(to: CGPoint(x: 0, y: rect.maxY))
        path.addLine(to: CGPoint(x: 0, y: radius))
        path.addArc(center: CGPoint(x: radius, y: radius), radius: radius, startAngle: Angle(degrees: 180), endAngle: Angle(degrees: 270), clockwise: false)
        path.addLine(to: CGPoint(x: rect.maxX - radius, y: 0))
        path.addArc(center: CGPoint(x: rect.maxX - radius, y: radius), radius: radius, startAngle: Angle(degrees: -90), endAngle: Angle(degrees: 0), clockwise: false)
        path.addLine(to: CGPoint(x: rect.maxX, y: rect.maxY))
        path.closeSubpath()
        return path
    }
}

// MARK: - Amount Checkin Sheet

struct AmountCheckinSheet: View {
    @Environment(\.modelContext) private var modelContext
    let habit: Habit
    let selectedDate: Date
    let initialAmount: Double?
    let onComplete: () -> Void
    
    @State private var amountString: String = "0"
    
    let pad = [
        ["1", "2", "3"],
        ["4", "5", "6"],
        ["7", "8", "9"],
        [".", "0", "DEL"]
    ]
    
    var body: some View {
        VStack(spacing: DS.spacingL) {
            Text(initialAmount != nil ? "修改 \(habit.name)" : "记录 \(habit.name)")
                .font(.system(size: 18, weight: .bold, design: .rounded))
                .foregroundColor(DS.textPrimary)
                .padding(.top, DS.spacingL)
            
            HStack(alignment: .lastTextBaseline, spacing: 6) {
                Text(amountString)
                    .font(.system(size: 56, weight: .heavy, design: .rounded))
                    .foregroundColor(Color(hex: habit.color))
                Text(habit.amountUnit)
                    .font(.system(size: 22, weight: .medium))
                    .foregroundColor(DS.textSecondary)
            }
            .frame(height: 70)
            
            VStack(spacing: DS.spacingS) {
                ForEach(pad, id: \.self) { row in
                    HStack(spacing: DS.spacingS) {
                        ForEach(row, id: \.self) { key in
                            Button(action: { handleKey(key) }) {
                                ZStack {
                                    RoundedRectangle(cornerRadius: DS.cornerSmall)
                                        .fill(DS.bgSubtle)
                                        .frame(height: 54)
                                    
                                    if key == "DEL" {
                                        Image(systemName: "delete.left")
                                            .foregroundColor(DS.textSecondary)
                                            .font(.system(size: 18, weight: .medium))
                                    } else {
                                        Text(key)
                                            .font(.system(size: 22, weight: .semibold))
                                            .foregroundColor(DS.textPrimary)
                                    }
                                }
                            }
                        }
                    }
                }
            }
            .padding(.horizontal, DS.spacingL)
            
            Button(action: submit) {
                Text(initialAmount != nil ? "保存修改" : "完成打卡")
                    .font(.system(size: 17, weight: .bold))
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .frame(height: 54)
                    .background(DS.accent)
                    .cornerRadius(DS.cornerPill)
            }
            .padding(.horizontal, DS.spacingL)
            .disabled(Double(amountString) == nil || Double(amountString) == 0)
            
            Spacer()
        }
        .background(DS.bgPrimary)
        .onAppear {
            if let initial = initialAmount {
                amountString = floor(initial) == initial ? String(Int(initial)) : String(initial)
            }
        }
    }
    
    private func handleKey(_ key: String) {
        if key == "DEL" {
            if amountString.count > 1 { amountString.removeLast() } else { amountString = "0" }
        } else if key == "." {
            if !amountString.contains(".") { amountString += "." }
        } else {
            if amountString == "0" { amountString = key }
            else if amountString.count < 6 { amountString += key }
        }
    }
    
    private func submit() {
        let val = Double(amountString) ?? 0.0
        if val > 0 {
            let formatter = DateFormatter()
            formatter.dateFormat = "yyyy-MM-dd"
            let dateString = formatter.string(from: selectedDate)
            
            if initialAmount != nil {
                let targetId = habit.id
                let descriptor = FetchDescriptor<Checkin>(predicate: #Predicate { $0.dateString == dateString && $0.habit?.id == targetId })
                if let existing = try? modelContext.fetch(descriptor).first {
                    existing.amount = val
                }
            } else {
                let newCheckin = Checkin(dateString: dateString, amount: val)
                newCheckin.habit = habit
                modelContext.insert(newCheckin)
            }
            onComplete()
        }
    }
}

// MARK: - Confetti

struct ConfettiView: View {
    @State private var animate = false
    let colors: [Color] = [DS.accent, DS.success, Color(hex: "#F7C59F"), Color(hex: "#5B8A6E"), Color(hex: "#E8845C")]
    
    var body: some View {
        GeometryReader { geometry in
            ZStack {
                ForEach(0..<40, id: \.self) { i in
                    ConfettiParticle(
                        color: colors.randomElement()!,
                        animate: $animate,
                        screenSize: geometry.size
                    )
                }
            }
        }
        .allowsHitTesting(false)
        .onAppear { animate = true }
    }
}

struct ConfettiParticle: View {
    let color: Color
    @Binding var animate: Bool
    let screenSize: CGSize
    
    @State private var xOffset: CGFloat = 0
    @State private var yOffset: CGFloat = 0
    @State private var rotation: Double = 0
    
    let startX = CGFloat.random(in: 0.2...0.8)
    
    var body: some View {
        RoundedRectangle(cornerRadius: 2)
            .fill(color)
            .frame(width: CGFloat.random(in: 6...10), height: CGFloat.random(in: 6...10))
            .position(x: screenSize.width * startX, y: screenSize.height * 0.4)
            .offset(x: xOffset, y: yOffset)
            .rotationEffect(.degrees(rotation))
            .opacity(animate ? 0 : 1)
            .onAppear {
                withAnimation(.easeOut(duration: Double.random(in: 1.2...2.0))) {
                    xOffset = CGFloat.random(in: -180...180)
                    yOffset = CGFloat.random(in: -280...280)
                    rotation = Double.random(in: 360...1080)
                }
            }
    }
}
