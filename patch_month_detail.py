import re

with open('Sources/HabitMonthDetailView.swift', 'r') as f:
    content = f.read()

# Replace Navigation Title
content = content.replace(
    '.navigationTitle("月视图")',
    '.navigationTitle("\\(String(format: "%04d", year))年 \\(String(format: "%02d", month))月 ｜ \\(habit.name)")'
)

# Replace stats summary
old_stats = """                    let currentMonthCheckins = checkinsForCurrentMonth()
                    let completedDaysCount = Set(currentMonthCheckins.map { $0.dateString }).count
                    let daysInMonth = calendar.range(of: .day, in: .month, for: currentMonthDate)?.count ?? 30
                    let completionRate = daysInMonth > 0 ? Int((Double(completedDaysCount) / Double(daysInMonth)) * 100) : 0
                    let totalAmount = currentMonthCheckins.reduce(0) { $0 + $1.amount }
                    
                    HStack {
                        statItem(value: "\\(completedDaysCount)", label: "打卡天数")
                        Spacer()
                        if habit.goalType == "amount" {
                            statItem(value: "\\(Int(totalAmount))", label: "打卡数量")
                            Spacer()
                        }
                        statItem(value: "\\(completionRate)%", label: "完成率")
                    }
                    .padding(16)
                    .background(Color.white)
                    .clipShape(RoundedRectangle(cornerRadius: 24, style: .continuous))
                    .shadow(color: Color.black.opacity(0.02), radius: 10, x: 0, y: 4)
                    .padding(.horizontal, 16)"""

new_stats = """                    let currentMonthCheckins = checkinsForCurrentMonth()
                    let completedDaysCount = Set(currentMonthCheckins.map { $0.dateString }).count
                    let totalAmount = currentMonthCheckins.reduce(0) { $0 + $1.amount }
                    
                    HStack(spacing: 12) {
                        // Days card
                        VStack(spacing: 4) {
                            Text("\\(completedDaysCount)")
                                .font(.system(size: 24, weight: .bold))
                                .foregroundColor(DS.onSurface)
                            Text("打卡天数")
                                .font(.system(size: 12))
                                .foregroundColor(DS.onSurfaceVariant)
                        }
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 16)
                        .background(Color.white.opacity(0.7))
                        .background(.ultraThinMaterial)
                        .clipShape(RoundedRectangle(cornerRadius: 20))
                        .overlay(RoundedRectangle(cornerRadius: 20).stroke(Color.white, lineWidth: 1))
                        .shadow(color: Color.black.opacity(0.03), radius: 10, x: 0, y: 4)
                        
                        // Total card
                        if habit.goalType == "amount" {
                            VStack(spacing: 4) {
                                Text("\\(String(format: "%.1f", totalAmount).replacingOccurrences(of: ".0", with: ""))")
                                    .font(.system(size: 24, weight: .bold))
                                    .foregroundColor(DS.onSurface)
                                Text("打卡数量")
                                    .font(.system(size: 12))
                                    .foregroundColor(DS.onSurfaceVariant)
                            }
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 16)
                            .background(Color.white.opacity(0.7))
                            .background(.ultraThinMaterial)
                            .clipShape(RoundedRectangle(cornerRadius: 20))
                            .overlay(RoundedRectangle(cornerRadius: 20).stroke(Color.white, lineWidth: 1))
                            .shadow(color: Color.black.opacity(0.03), radius: 10, x: 0, y: 4)
                        }
                    }
                    .padding(.horizontal, 16)"""

content = content.replace(old_stats, new_stats)

# Replace Timeline Item
old_timeline_item_pattern = r'@ViewBuilder\s+private func timelineItem\(checkin: Checkin, isLast: Bool\) -> some View \{[\s\S]*?\.padding\(\.bottom, isLast \? 0 : 20\)\n        \}\n    \}'
new_timeline_item = """@ViewBuilder
    private func timelineItem(checkin: Checkin, isLast: Bool) -> some View {
        HStack(alignment: .top, spacing: 0) {
            // Timeline Node
            ZStack(alignment: .top) {
                if !isLast {
                    Rectangle()
                        .fill(Color(hex: habit.color).opacity(0.2))
                        .frame(width: 2)
                        .padding(.top, 24)
                }
                
                Circle()
                    .fill(Color(hex: habit.color).opacity(0.15))
                    .frame(width: 12, height: 12)
                    .overlay(Circle().stroke(Color(hex: habit.color), lineWidth: 2))
                    .padding(.top, 4)
            }
            .frame(width: 32)
            
            // Content Card
            VStack(alignment: .leading, spacing: 12) {
                // Header (Date and Time)
                HStack(alignment: .center) {
                    Text(formattedDisplayDate(checkin.timestamp))
                        .font(.system(size: 15, weight: .semibold))
                        .foregroundColor(DS.onSurface)
                    
                    Spacer()
                    
                    if habit.goalType == "amount" && checkin.amount > 0 {
                        Text("+\(String(format: "%.1f", checkin.amount).replacingOccurrences(of: ".0", with: "")) \(habit.amountUnit)")
                            .font(.system(size: 13, weight: .bold))
                            .foregroundColor(Color(hex: habit.color))
                            .padding(.horizontal, 8)
                            .padding(.vertical, 4)
                            .background(Color(hex: habit.color).opacity(0.1))
                            .clipShape(Capsule())
                    } else {
                        Image(systemName: "checkmark.circle.fill")
                            .foregroundColor(Color(hex: habit.color))
                            .font(.system(size: 16))
                    }
                }
                
                // Mood Log (if exists)
                if let mood = getMoodForDate(checkin.dateString) {
                    HStack(alignment: .top, spacing: 10) {
                        Text(emoji(for: mood.type))
                            .font(.system(size: 20))
                            
                        if !mood.text.isEmpty {
                            Text(mood.text)
                                .font(.system(size: 13))
                                .foregroundColor(DS.onSurfaceVariant)
                                .fixedSize(horizontal: false, vertical: true)
                        }
                        Spacer()
                    }
                    .padding(10)
                    .background(Color.black.opacity(0.02))
                    .clipShape(RoundedRectangle(cornerRadius: 12))
                }
            }
            .padding(16)
            .background(Color.white)
            .clipShape(RoundedRectangle(cornerRadius: 16))
            .shadow(color: Color.black.opacity(0.02), radius: 6, x: 0, y: 2)
            .padding(.bottom, isLast ? 0 : 16)
            .padding(.leading, 8)
        }
    }"""

content = re.sub(old_timeline_item_pattern, new_timeline_item, content)

with open('Sources/HabitMonthDetailView.swift', 'w') as f:
    f.write(content)
