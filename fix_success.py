import re

with open('Sources/CheckinSuccessView.swift', 'r') as f:
    content = f.read()

# Remove Text("打卡成功")
old_text = """                    Text("打卡成功")
                        .font(.system(size: 22, weight: .bold, design: .rounded))
                        .foregroundColor(DS.textPrimary)
                    
                    Text(habit.name)"""
new_text = """                    Text(habit.name)"""
content = content.replace(old_text, new_text)

# Remove navigation title and toolbar, and add navigationBarHidden(true)
old_nav = """            .navigationTitle("Check-in Success".tr(appSettings.resolvedLanguage))
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: { dismiss() }) {
                        Image(systemName: "xmark.circle.fill")
                            .foregroundColor(DS.textSecondary)
                            .font(.system(size: 24))
                    }
                }
            }"""
new_nav = """            .navigationBarHidden(true)"""
content = content.replace(old_nav, new_nav)

with open('Sources/CheckinSuccessView.swift', 'w') as f:
    f.write(content)
