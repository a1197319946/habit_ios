import Foundation
let dcf = DateComponentsFormatter()
dcf.unitsStyle = .full

var cal = Calendar.current
cal.locale = Locale(identifier: "zh_CN")
dcf.calendar = cal
var dc = DateComponents()
dc.month = 1
print("zh:", dcf.string(from: dc)!)
dc.month = 3
print("zh:", dcf.string(from: dc)!)

cal.locale = Locale(identifier: "en_US")
dcf.calendar = cal
dc.month = 1
print("en:", dcf.string(from: dc)!)
dc.month = 3
print("en:", dcf.string(from: dc)!)

cal.locale = Locale(identifier: "ru_RU")
dcf.calendar = cal
dc.month = 3
print("ru:", dcf.string(from: dc)!)
