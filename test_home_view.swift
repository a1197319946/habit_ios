import Foundation

var cal = Calendar.current
cal.firstWeekday = 2

let today = Date()
let targetDate = cal.date(byAdding: .weekOfYear, value: 0, to: today) ?? Date()
let weekInterval = cal.dateInterval(of: .weekOfYear, for: targetDate)!
print("Start when firstWeekday=2: \(weekInterval.start)")

cal.firstWeekday = 1
let targetDate2 = cal.date(byAdding: .weekOfYear, value: 0, to: today) ?? Date()
let weekInterval2 = cal.dateInterval(of: .weekOfYear, for: targetDate2)!
print("Start when firstWeekday=1: \(weekInterval2.start)")
