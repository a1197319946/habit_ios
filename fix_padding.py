import re

with open('Sources/HabitMonthDetailView.swift', 'r') as f:
    content = f.read()

# Remove the inner padding on "打卡记录"
old_header = """                        HStack {
                            Text("打卡记录")
                                .font(.system(size: 18, weight: .bold))
                                .foregroundColor(DS.onSurface)
                            Spacer()
                        }
                        .padding(.horizontal, 16)"""
new_header = """                        HStack {
                            Text("打卡记录")
                                .font(.system(size: 18, weight: .bold))
                                .foregroundColor(DS.onSurface)
                            Spacer()
                        }"""
content = content.replace(old_header, new_header)

old_empty = """                        if currentMonthCheckins.isEmpty {
                            Text("暂无打卡记录")
                                .font(.system(size: 14))
                                .foregroundColor(DS.onSurfaceVariant)
                                .padding(.horizontal, 16)
                        }"""
new_empty = """                        if currentMonthCheckins.isEmpty {
                            Text("暂无打卡记录")
                                .font(.system(size: 14))
                                .foregroundColor(DS.onSurfaceVariant)
                        }"""
content = content.replace(old_empty, new_empty)

with open('Sources/HabitMonthDetailView.swift', 'w') as f:
    f.write(content)
