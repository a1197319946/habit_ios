import Foundation
let df = DateFormatter()
df.locale = Locale(identifier: "zh_CN")
df.setLocalizedDateFormatFromTemplate("yyyyMMMM")
print("zh_CN:", df.string(from: Date()))

df.locale = Locale(identifier: "en_US")
df.setLocalizedDateFormatFromTemplate("yyyyMMMM")
print("en_US:", df.string(from: Date()))

df.locale = Locale(identifier: "es_ES")
df.setLocalizedDateFormatFromTemplate("yyyyMMMM")
print("es_ES:", df.string(from: Date()))
