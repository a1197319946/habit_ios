import re

with open('Sources/CheckinSuccessView.swift', 'r') as f:
    content = f.read()

# 1. Update Title
content = content.replace('Text("Target Achieved!".tr(appSettings.resolvedLanguage))', 'Text("Check-in Successful".tr(appSettings.resolvedLanguage))')

# 2. Update currentTotal logic
old_total = """    private var currentTotal: Double {
        let periodCheckins = checkins.filter { $0.habit?.id == habit.id }
        return isAmount ? periodCheckins.reduce(0) { $0 + $1.amount } : Double(periodCheckins.count)
    }"""

new_total = """    private var currentTotal: Double {
        let calendar = Calendar.current
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        
        let periodCheckins = checkins.filter { checkin in
            guard checkin.habit?.id == habit.id,
                  let cDate = formatter.date(from: checkin.dateString) else { return false }
            
            if habit.frequencyType == "weekly" {
                return calendar.isDate(cDate, equalTo: date, toGranularity: .weekOfYear)
            } else {
                return calendar.isDate(cDate, equalTo: date, toGranularity: .month)
            }
        }
        
        return isAmount ? periodCheckins.reduce(0) { $0 + $1.amount } : Double(periodCheckins.count)
    }"""
content = content.replace(old_total, new_total)

with open('Sources/CheckinSuccessView.swift', 'w') as f:
    f.write(content)

# 3. Add Translation for Check-in Successful
with open('Sources/LittleHabitTrackerApp.swift', 'r') as f:
    app_content = f.read()

if '"Check-in Successful": [' not in app_content:
    app_content = app_content.replace('"Cancel": [', '            "Check-in Successful": [.chinese: "打卡成功", .english: "Check-in Successful"],\n            "Cancel": [')
    with open('Sources/LittleHabitTrackerApp.swift', 'w') as f:
        f.write(app_content)

