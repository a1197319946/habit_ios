import Foundation
let dcf = DateComponentsFormatter()
dcf.unitsStyle = .full
var cal = Calendar.current
for loc in ["zh_CN", "en_US", "ja_JP", "ko_KR", "es_ES", "de_DE", "ru_RU", "it_IT"] {
    cal.locale = Locale(identifier: loc)
    dcf.calendar = cal
    var dc = DateComponents()
    dc.month = 1
    print("\(loc) 1 month:", dcf.string(from: dc)!)
    dc.month = 3
    print("\(loc) 3 months:", dcf.string(from: dc)!)
}
