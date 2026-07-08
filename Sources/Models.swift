import Foundation
import SwiftData

@Model
final class Habit {
    var id: String = UUID().uuidString
    var name: String = ""
    var color: String = "#8B5CF6"
    var icon: String = "star.fill"
    
    var goalType: String = "frequency" // "frequency" or "amount"
    var frequencyType: String = "weekly" // "weekly" or "monthly"
    
    var weeklyTarget: Int = 3
    var monthlyTarget: Int = 10
    
    var amountValue: Double = 0.0
    var amountUnit: String = ""
    
    var order: Int = 0
    var isArchived: Bool = false
    
    var createdAt: Date = Date()
    
    var isReminderEnabled: Bool = false
    var reminderTime: Date = Calendar.current.date(from: DateComponents(hour: 20, minute: 0)) ?? Date()
    var reminderText: String = ""
    
    // CloudKit requires relationships to be optional
    @Relationship(deleteRule: .cascade) var checkins: [Checkin]?
    @Relationship(deleteRule: .cascade) var moodRecords: [MoodRecord]?
    
    init(name: String, color: String = "#8B5CF6", icon: String = "star.fill") {
        self.name = name
        self.color = color
        self.icon = icon
    }
}

@Model
final class Checkin {
    var id: String = UUID().uuidString
    var dateString: String = "" // "YYYY-MM-DD"
    var timestamp: Date = Date()
    var amount: Double = 0.0
    
    @Relationship(inverse: \Habit.checkins) var habit: Habit?
    
    init(dateString: String, amount: Double = 1.0) {
        self.dateString = dateString
        self.amount = amount
    }
}

@Model
final class MoodRecord {
    var id: String = UUID().uuidString
    var type: String = "normal" // "excited", "happy", "normal", "down", "angry"
    var text: String = ""
    var timestamp: Date = Date()
    
    @Attribute(.externalStorage) var imageData: Data?
    
    @Relationship(inverse: \Habit.moodRecords) var habit: Habit?
    
    init(type: String, text: String = "") {
        self.type = type
        self.text = text
    }
}
import Foundation
import SwiftData

struct SharedFormatters {
    private static let _yyyyMMdd: DateFormatter = {
        let df = DateFormatter()
        df.dateFormat = "yyyy-MM-dd"
        return df
    }()
    
    private static let _yyyyMM: DateFormatter = {
        let df = DateFormatter()
        df.dateFormat = "yyyy-MM"
        return df
    }()
    
    static func dateString(from date: Date) -> String {
        return _yyyyMMdd.string(from: date)
    }
    
    static func date(from string: String) -> Date? {
        return _yyyyMMdd.date(from: string)
    }
    
    static func yearMonthString(from date: Date) -> String {
        return _yyyyMM.string(from: date)
    }
}

extension Habit {
    var checkinDates: Set<String> {
        Set((checkins ?? []).map { $0.dateString })
    }
    
    var totalCheckins: Int {
        checkins?.count ?? 0
    }
    
    var checkinCountLast30Days: Int {
        var calendar = Calendar.current
        calendar.firstWeekday = UserDefaults.standard.integer(forKey: "firstWeekday") == 0 ? 2 : UserDefaults.standard.integer(forKey: "firstWeekday")
        let today = Date()
        var count = 0
        let dates = checkinDates
        if dates.isEmpty { return 0 }
        
        for i in 0..<30 {
            if let date = calendar.date(byAdding: .day, value: -i, to: today) {
                let dateStr = SharedFormatters.dateString(from: date)
                if dates.contains(dateStr) {
                    count += 1
                }
            }
        }
        return count
    }
    
    var currentStreak: Int {
        var calendar = Calendar.current
        calendar.firstWeekday = UserDefaults.standard.integer(forKey: "firstWeekday") == 0 ? 2 : UserDefaults.standard.integer(forKey: "firstWeekday")
        let today = Date()
        let dates = checkinDates
        if dates.isEmpty { return 0 }
        
        var streak = 0
        var i = 0
        
        // Check today
        let todayStr = SharedFormatters.dateString(from: today)
        let hasToday = dates.contains(todayStr)
        
        // Check yesterday
        guard let yesterday = calendar.date(byAdding: .day, value: -1, to: today) else { return 0 }
        let yesterdayStr = SharedFormatters.dateString(from: yesterday)
        let hasYesterday = dates.contains(yesterdayStr)
        
        if !hasToday && !hasYesterday {
            return 0
        }
        
        if hasToday {
            streak += 1
            i = 1
        } else if hasYesterday {
            i = 1
        }
        
        while true {
            if let date = calendar.date(byAdding: .day, value: -i, to: today) {
                let dateStr = SharedFormatters.dateString(from: date)
                if dates.contains(dateStr) {
                    streak += 1
                    i += 1
                } else {
                    break
                }
            } else {
                break
            }
        }
        
        return streak
    }
    
    var longestStreak: Int {
        let dates = checkinDates
        if dates.isEmpty { return 0 }
        
        let sortedDates = dates.compactMap { SharedFormatters.date(from: $0) }.sorted()
        if sortedDates.isEmpty { return 0 }
        
        var maxStreak = 1
        var currentStreak = 1
        
        var calendar = Calendar.current
        calendar.firstWeekday = UserDefaults.standard.integer(forKey: "firstWeekday") == 0 ? 2 : UserDefaults.standard.integer(forKey: "firstWeekday")
        for i in 1..<sortedDates.count {
            let diff = calendar.dateComponents([.day], from: calendar.startOfDay(for: sortedDates[i-1]), to: calendar.startOfDay(for: sortedDates[i])).day ?? 0
            
            if diff == 1 {
                currentStreak += 1
                maxStreak = max(maxStreak, currentStreak)
            } else if diff > 1 {
                currentStreak = 1
            }
        }
        
        return maxStreak
    }
    
    var last154DaysCheckins: [Bool] {
        var calendar = Calendar.current
        calendar.firstWeekday = UserDefaults.standard.integer(forKey: "firstWeekday") == 0 ? 2 : UserDefaults.standard.integer(forKey: "firstWeekday")
        let today = Date()
        let dates = checkinDates
        if dates.isEmpty { return [Bool](repeating: false, count: 154) }
        
        var result = [Bool](repeating: false, count: 154)
        for i in 0..<154 {
            let daysAgo = 153 - i
            if let date = calendar.date(byAdding: .day, value: -daysAgo, to: today) {
                let dateStr = SharedFormatters.dateString(from: date)
                result[i] = dates.contains(dateStr)
            }
        }
        return result
    }
    
    var last182DaysCheckins: [Bool] {
        var calendar = Calendar.current
        calendar.firstWeekday = UserDefaults.standard.integer(forKey: "firstWeekday") == 0 ? 2 : UserDefaults.standard.integer(forKey: "firstWeekday")
        let today = Date()
        let dates = checkinDates
        if dates.isEmpty { return [Bool](repeating: false, count: 182) }
        
        var result = [Bool](repeating: false, count: 182)
        for i in 0..<182 {
            let daysAgo = 181 - i
            if let date = calendar.date(byAdding: .day, value: -daysAgo, to: today) {
                let dateStr = SharedFormatters.dateString(from: date)
                result[i] = dates.contains(dateStr)
            }
        }
        return result
    }
}
