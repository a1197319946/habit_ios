import re

with open('Sources/HomeView.swift', 'r') as f:
    content = f.read()

# 1. Fix spacing around "Hide completed"
old_header = """                        // Top Actions
                        HStack {
                            Spacer()
                            
                            Button(action: {
                                withAnimation { hideCompleted.toggle() }
                            }) {
                                Text(hideCompleted ? "显示已打卡" : "隐藏已打卡")
                                    .font(.system(size: 12, weight: .bold))
                                    .foregroundColor(hideCompleted ? DS.onPrimary : DS.primary)
                                    .padding(.horizontal, 12)
                                    .padding(.vertical, 6)
                                    .background(hideCompleted ? DS.primary : Color.clear)
                                    .overlay(
                                        Capsule()
                                            .stroke(DS.primary, lineWidth: hideCompleted ? 0 : 1)
                                    )
                                    .clipShape(Capsule())
                            }
                        }
                        .padding(.horizontal, DS.spacingL)
                        .padding(.bottom, 4)
                        
                        LazyVStack(spacing: 12) {"""

new_header = """                        // Top Actions
                        HStack {
                            Spacer()
                            
                            Button(action: {
                                withAnimation { hideCompleted.toggle() }
                            }) {
                                Text(hideCompleted ? "显示已打卡" : "隐藏已打卡")
                                    .font(.system(size: 12, weight: .bold))
                                    .foregroundColor(hideCompleted ? DS.onPrimary : DS.primary)
                                    .padding(.horizontal, 12)
                                    .padding(.vertical, 6)
                                    .background(hideCompleted ? DS.primary : Color.clear)
                                    .overlay(
                                        Capsule()
                                            .stroke(DS.primary, lineWidth: hideCompleted ? 0 : 1)
                                    )
                                    .clipShape(Capsule())
                            }
                        }
                        .padding(.horizontal, DS.spacingL)
                        .padding(.bottom, 0)
                        
                        LazyVStack(spacing: 10) {"""

content = content.replace(old_header, new_header)

# 2. Fix the card layout (title + progress text, tag + progress bar)
old_details = """                // Details
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
                }"""

new_details = """                // Details
                VStack(alignment: .leading, spacing: 8) {
                    HStack(alignment: .lastTextBaseline, spacing: 6) {
                        Text(habit.name)
                            .font(.system(size: 16, weight: .bold))
                            .foregroundColor(DS.onSurface)
                            .lineLimit(1)
                        
                        Text(progressText)
                            .font(.system(size: 12, weight: .medium))
                            .foregroundColor(DS.onSurfaceVariant)
                    }
                    
                    HStack(spacing: 8) {
                        Text(habit.frequencyType == "weekly" ? "本周" : "本月")
                            .font(.system(size: 10, weight: .semibold))
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
                    }
                }"""

content = content.replace(old_details, new_details)

# Update progressText generation slightly to fit user request "次"
# old: return "\(periodCompleted)/\(periodTarget)\(" times".tr(appSettings.resolvedLanguage))"
old_progress = """        } else {
            return "\\(periodCompleted)/\\(periodTarget)\\(" times".tr(appSettings.resolvedLanguage))"
        }"""
new_progress = """        } else {
            return "\\(periodCompleted)/\\(periodTarget)次"
        }"""
content = content.replace(old_progress, new_progress)


with open('Sources/HomeView.swift', 'w') as f:
    f.write(content)
