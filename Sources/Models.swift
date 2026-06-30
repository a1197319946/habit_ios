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
    
    var createdAt: Date = Date()
    
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
    
    init(dateString: String, amount: Double = 0.0) {
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
