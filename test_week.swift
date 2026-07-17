import Foundation
var cal = Calendar.current
cal.locale = Locale(identifier: "zh_CN")
print("zh:", cal.shortWeekdaySymbols)
cal.locale = Locale(identifier: "en_US")
print("en:", cal.shortWeekdaySymbols)
