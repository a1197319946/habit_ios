import re

with open('Sources/CheckinSuccessView.swift', 'r') as f:
    content = f.read()

# Replace the Icon + Name section to be in an HStack and pushed further down
old_icon_section = """            Spacer().frame(height: 32)
            // Icon + name
            VStack(spacing: DS.spacingM) {
                ZStack {
                    Circle()
                        .fill(DS.successMuted)
                        .frame(width: 72, height: 72)
                    
                    Image(systemName: habit.icon)
                        .font(.system(size: 30, weight: .semibold))
                        .foregroundColor(DS.success)
                }
                .scaleEffect(appeared ? 1.0 : 0.6)
                .animation(.spring(response: 0.4, dampingFraction: 0.65), value: appeared)
                
                VStack(spacing: 4) {
                    Text("打卡成功")
                        .font(.system(size: 22, weight: .bold, design: .rounded))
                        .foregroundColor(DS.textPrimary)
                    
                    Text(habit.name)
                        .font(.system(size: 15))
                        .foregroundColor(DS.textSecondary)
                }
                .opacity(appeared ? 1 : 0)
                .animation(.easeOut(duration: 0.3).delay(0.1), value: appeared)
            }
            .padding(.bottom, DS.spacingL)"""

new_icon_section = """            Spacer().frame(height: 64)
            // Header + Icon + Name
            VStack(spacing: 16) {
                Text("Target Achieved!".tr(appSettings.resolvedLanguage))
                    .font(.system(size: 24, weight: .bold, design: .rounded))
                    .foregroundColor(DS.textPrimary)
                
                HStack(spacing: 12) {
                    ZStack {
                        Circle()
                            .fill(DS.successMuted)
                            .frame(width: 48, height: 48)
                        
                        Image(systemName: habit.icon)
                            .font(.system(size: 22, weight: .semibold))
                            .foregroundColor(DS.success)
                    }
                    
                    Text(habit.name)
                        .font(.system(size: 18, weight: .semibold))
                        .foregroundColor(DS.textSecondary)
                }
                .scaleEffect(appeared ? 1.0 : 0.6)
                .animation(.spring(response: 0.4, dampingFraction: 0.65), value: appeared)
            }
            .padding(.bottom, 32)"""
content = content.replace(old_icon_section, new_icon_section)

# Fix translations in Stats
content = content.replace('Text("\\(targetLabel)已达成！")', 'Text("\\(targetLabel)\\(" Achieved!".tr(appSettings.resolvedLanguage))")')
content = content.replace('StatCell(label: "本次完成"', 'StatCell(label: "Amount Completed".tr(appSettings.resolvedLanguage)')
content = content.replace('StatCell(label: "\\(label)累计"', 'StatCell(label: "\\(label)\\(" Total".tr(appSettings.resolvedLanguage))"')

# Also we need to add "Total" and " Achieved!" to translations if not there
with open('Sources/CheckinSuccessView.swift', 'w') as f:
    f.write(content)

with open('Sources/LittleHabitTrackerApp.swift', 'r') as f:
    app = f.read()

if '" Total"' not in app:
    app = app.replace('"Cancel": [', '            " Total": [.chinese: "累计", .english: " Total"],\n            " Achieved!": [.chinese: "已达成！", .english: " Achieved!"],\n            "Cancel": [')
    with open('Sources/LittleHabitTrackerApp.swift', 'w') as f:
        f.write(app)

