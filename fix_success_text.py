import re

with open('Sources/CheckinSuccessView.swift', 'r') as f:
    content = f.read()

old_vstack = """        VStack(spacing: 0) {
            Spacer().frame(height: 32)
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
                    Text(habit.name)"""
                    
new_vstack = """        VStack(spacing: 0) {
            Spacer().frame(height: 32)
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
                    
                    Text(habit.name)"""

content = content.replace(old_vstack, new_vstack)

with open('Sources/CheckinSuccessView.swift', 'w') as f:
    f.write(content)
