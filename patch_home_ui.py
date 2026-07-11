import re

# 1. Update AmountCheckinSheet height
with open('Sources/AmountCheckinSheet.swift', 'r') as f:
    content = f.read()
content = content.replace('.presentationDetents([.height(440)])', '.presentationDetents([.height(500)])')
with open('Sources/AmountCheckinSheet.swift', 'w') as f:
    f.write(content)

# 2. Update HomeView
with open('Sources/HomeView.swift', 'r') as f:
    content = f.read()

# Revert isHabitChecked
old_is_habit_checked = """    private func isHabitChecked(habit: Habit) -> Bool {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        let dateString = formatter.string(from: selectedDate)
        if habit.goalType == "amount" {
            let hCheckins = checkins.filter { $0.habit?.id == habit.id && $0.dateString == dateString }
            let sum = hCheckins.reduce(0) { $0 + $1.amount }
            return sum >= habit.amountValue
        } else {
            return checkins.contains(where: { $0.habit?.id == habit.id && $0.dateString == dateString })
        }
    }"""

new_is_habit_checked = """    private func isHabitChecked(habit: Habit) -> Bool {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        let dateString = formatter.string(from: selectedDate)
        return checkins.contains(where: { $0.habit?.id == habit.id && $0.dateString == dateString })
    }"""
content = content.replace(old_is_habit_checked, new_is_habit_checked)

# Revert isChecked in ListHabitCard
old_is_checked = """    var isChecked: Bool {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        let dateString = formatter.string(from: selectedDate)
        if habit.goalType == "amount" {
            let hCheckins = checkins.filter { $0.habit?.id == habit.id && $0.dateString == dateString }
            let sum = hCheckins.reduce(0) { $0 + $1.amount }
            return sum >= habit.amountValue
        } else {
            return checkins.contains(where: { $0.habit?.id == habit.id && $0.dateString == dateString })
        }
    }"""

new_is_checked = """    var isChecked: Bool {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        let dateString = formatter.string(from: selectedDate)
        return checkins.contains(where: { $0.habit?.id == habit.id && $0.dateString == dateString })
    }"""
content = content.replace(old_is_checked, new_is_checked)

# Update layout
old_details = """                // Details
                VStack(alignment: .leading, spacing: 8) {
                    HStack(alignment: .lastTextBaseline, spacing: 6) {
                        Text(habit.name)
                            .font(.system(size: 16, weight: .bold))
                            .foregroundColor(DS.onSurface)
                            .lineLimit(1)
                        
                        Text(progressText)
                            .font(.system(size: 12, weight: .medium))
                            .foregroundColor(DS.onSurfaceVariant)
                        
                        Spacer()
                        
                        Text(habit.frequencyType == "weekly" ? "本周" : "本月")
                            .font(.system(size: 10, weight: .semibold))
                            .foregroundColor(Color(hex: habit.color))
                            .padding(.horizontal, 6)
                            .padding(.vertical, 3)
                            .background(Color(hex: habit.color).opacity(0.1))
                            .clipShape(Capsule())
                    }
                    
                    HStack(spacing: 8) {
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
                        
                        Text("\\(Int(progressFraction * 100))%")
                            .font(.system(size: 11, weight: .bold))
                            .foregroundColor(DS.onSurfaceVariant)
                    }
                }"""

new_details = """                // Details
                VStack(alignment: .leading, spacing: 8) {
                    HStack(alignment: .lastTextBaseline, spacing: 6) {
                        Text(habit.name)
                            .font(.system(size: 16, weight: .bold))
                            .foregroundColor(DS.onSurface)
                            .lineLimit(1)
                        
                        Spacer(minLength: 8)
                        
                        Text(progressText)
                            .font(.system(size: 12, weight: .bold))
                            .foregroundColor(DS.onSurfaceVariant)
                        
                        Text(habit.frequencyType == "weekly" ? "本周" : "本月")
                            .font(.system(size: 10, weight: .semibold))
                            .foregroundColor(Color(hex: habit.color))
                            .padding(.horizontal, 6)
                            .padding(.vertical, 3)
                            .background(Color(hex: habit.color).opacity(0.1))
                            .clipShape(Capsule())
                    }
                    
                    HStack(spacing: 8) {
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
                        
                        Text("\\(Int(progressFraction * 100))%")
                            .font(.system(size: 11, weight: .bold))
                            .foregroundColor(DS.onSurfaceVariant)
                            .frame(width: 36, alignment: .trailing)
                    }
                }"""
content = content.replace(old_details, new_details)

with open('Sources/HomeView.swift', 'w') as f:
    f.write(content)
