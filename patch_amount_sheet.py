import re

with open('Sources/AmountCheckinSheet.swift', 'r') as f:
    content = f.read()

# 1. Update the title logic
old_title = 'Text(initialAmount != nil ? "修改打卡数据" : "录入打卡数据")'
new_title = 'Text(isEditing ? "修改打卡数据" : "录入打卡数据")'
content = content.replace(old_title, new_title)

# Add isEditing variable
is_editing_var = """    private var isEditing: Bool {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        let dateString = formatter.string(from: selectedDate)
        return allCheckins.contains(where: { $0.habit?.id == habit.id && $0.dateString == dateString })
    }
    
    var body: some View {"""
content = content.replace("    var body: some View {", is_editing_var)

# 2. Update the button title logic
old_btn_title = 'Text(initialAmount != nil ? "保存修改" : "完成打卡")'
new_btn_title = 'Text(isEditing ? "保存修改" : "完成打卡")'
content = content.replace(old_btn_title, new_btn_title)

# 3. Update the button color
old_btn_color = '.background(Color(hex: "#5856D6"))'
new_btn_color = '.background(DS.primary)'
content = content.replace(old_btn_color, new_btn_color)

# 4. Update the submit logic (UPSERT)
old_submit = """            if initialAmount != nil {
                let targetId = habit.id
                let descriptor = FetchDescriptor<Checkin>(predicate: #Predicate { $0.dateString == dateString && $0.habit?.id == targetId })
                if let existing = try? modelContext.fetch(descriptor).first {
                    existing.amount = val
                }
            } else {
                let newCheckin = Checkin(dateString: dateString, amount: val)
                newCheckin.habit = habit
                modelContext.insert(newCheckin)
            }"""

new_submit = """            let targetId = habit.id
            let descriptor = FetchDescriptor<Checkin>(predicate: #Predicate { $0.dateString == dateString && $0.habit?.id == targetId })
            if let existing = try? modelContext.fetch(descriptor).first {
                existing.amount = val
            } else {
                let newCheckin = Checkin(dateString: dateString, amount: val)
                newCheckin.habit = habit
                modelContext.insert(newCheckin)
            }"""
content = content.replace(old_submit, new_submit)

# 5. Add presentation detent
old_end = """        }
        .background(Color.white)
        .onAppear {"""

new_end = """        }
        .background(Color.white)
        .presentationDetents([.height(440)])
        .onAppear {"""
content = content.replace(old_end, new_end)


with open('Sources/AmountCheckinSheet.swift', 'w') as f:
    f.write(content)
