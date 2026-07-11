import Foundation

var cal = Calendar.current
cal.firstWeekday = 2 // Monday
let today = Date()
let start1 = cal.dateInterval(of: .weekOfYear, for: today)!.start
print("Start when firstWeekday=2: \(start1)")

cal.firstWeekday = 1 // Sunday
let start2 = cal.dateInterval(of: .weekOfYear, for: today)!.start
print("Start when firstWeekday=1: \(start2)")
