import re

with open('Sources/HomeView.swift', 'r') as f:
    content = f.read()

# Replace LazyVStack with LazyVGrid
old_list = """                    if habits.isEmpty {
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
                        .padding(.horizontal, DS.spacingL)"""

new_list = """                    if habits.isEmpty {
                        Spacer(minLength: 0)
                        EmptyHabitsView()
                            .frame(maxWidth: .infinity)
                        Spacer(minLength: 0)
                    } else {
                        let columns = [
                            GridItem(.flexible(), spacing: DS.spacingM),
                            GridItem(.flexible(), spacing: DS.spacingM)
                        ]
                        LazyVGrid(columns: columns, spacing: DS.spacingM) {
                            ForEach(habits) { habit in
                                GridHabitCard(
                                    habit: habit,
                                    selectedDate: selectedDate,
                                    checkins: checkins,
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
                        .padding(.horizontal, DS.spacingL)"""

content = content.replace(old_list, new_list)

# Find ListHabitCard and replace it completely with GridHabitCard
# Since it's from `// MARK: - List Habit Card` to `// MARK: - Weekly Slider`
start_idx = content.find("// MARK: - List Habit Card")
end_idx = content.find("// MARK: - Weekly Slider")

if start_idx != -1 and end_idx != -1:
    new_card_code = """// MARK: - Grid Habit Card
struct GridHabitCard: View {
    let habit: Habit
    let selectedDate: Date
    let checkins: [Checkin]
    @EnvironmentObject private var appSettings: AppSettings
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
            let uniqueDays = Set(validCheckins.map { $0.dateString })
            return uniqueDays.count
        } else {
            return validCheckins.count
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
            
            let sumFormatted = sum.truncatingRemainder(dividingBy: 1) == 0 ? String(format: "%.0f", sum) : String(format: "%.1f", sum)
            let targetFormatted = target.truncatingRemainder(dividingBy: 1) == 0 ? String(format: "%.0f", target) : String(format: "%.1f", target)
            
            return "\\(sumFormatted)/\\(targetFormatted) \\(habit.amountUnit)"
        } else {
            return "\\(periodCompleted)/\\(periodTarget)"
        }
    }
    
    var body: some View {
        Button(action: {
            onTapCard()
        }) {
            VStack(spacing: 12) {
                // Icon Area
                ZStack {
                    if isChecked {
                        Image(systemName: "checkmark.circle.fill")
                            .font(.system(size: 46))
                            .foregroundColor(Color(hex: "#4CD964"))
                            .transition(.scale.combined(with: .opacity))
                    } else {
                        Image(systemName: habit.icon)
                            .font(.system(size: 44))
                            .foregroundColor(Color(hex: habit.color))
                            .transition(.scale.combined(with: .opacity))
                    }
                }
                .frame(height: 50)
                
                // Text Area
                VStack(spacing: 6) {
                    Text(habit.name)
                        .font(.system(size: 16, weight: .bold))
                        .foregroundColor(isChecked ? Color(hex: "#2E7D32") : DS.onSurface)
                        .lineLimit(1)
                    
                    Text(progressText)
                        .font(.system(size: 13, weight: .medium))
                        .foregroundColor(isChecked ? Color(hex: "#388E3C").opacity(0.8) : DS.onSurfaceVariant)
                }
            }
            .frame(maxWidth: .infinity)
            .aspectRatio(1.0, contentMode: .fill)
            .background(
                Group {
                    if isChecked {
                        Color(hex: "#E8F5E9") // Pale green
                    } else {
                        Color.white
                    }
                }
            )
            .clipShape(RoundedRectangle(cornerRadius: 24, style: .continuous))
            .shadow(color: isChecked ? .clear : Color.black.opacity(0.04), radius: 10, x: 0, y: 5)
            .animation(.spring(response: 0.4, dampingFraction: 0.6, blendDuration: 0.5), value: isChecked)
        }
        .buttonStyle(PlainButtonStyle())
    }
}

"""
    content = content[:start_idx] + new_card_code + content[end_idx:]
    
with open('Sources/HomeView.swift', 'w') as f:
    f.write(content)
