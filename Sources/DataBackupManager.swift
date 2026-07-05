import Foundation
import SwiftData

struct BackupData: Codable {
    var habits: [BackupHabit]
    var checkins: [BackupCheckin]
    var moodRecords: [BackupMoodRecord]
}

struct BackupHabit: Codable {
    var id: String
    var name: String
    var color: String
    var icon: String
    var order: Int
    var isArchived: Bool
    var frequencyType: String
    var goalType: String
    var weeklyTarget: Int
    var monthlyTarget: Int
    var amountValue: Double
    var amountUnit: String
}

struct BackupCheckin: Codable {
    var id: String
    var habitId: String
    var dateString: String
    var amount: Double
}

struct BackupMoodRecord: Codable {
    var id: String
    var habitId: String
    var type: String
    var text: String
    var imageData: Data?
    var timestamp: Date
}

class DataBackupManager {
    static let shared = DataBackupManager()
    
    func exportData(modelContext: ModelContext) -> URL? {
        do {
            let habits = try modelContext.fetch(FetchDescriptor<Habit>())
            let checkins = try modelContext.fetch(FetchDescriptor<Checkin>())
            let moodRecords = try modelContext.fetch(FetchDescriptor<MoodRecord>())
            
            let backupHabits = habits.map { BackupHabit(id: $0.id, name: $0.name, color: $0.color, icon: $0.icon, order: $0.order, isArchived: $0.isArchived, frequencyType: $0.frequencyType, goalType: $0.goalType, weeklyTarget: $0.weeklyTarget, monthlyTarget: $0.monthlyTarget, amountValue: $0.amountValue, amountUnit: $0.amountUnit) }
            
            let backupCheckins = checkins.compactMap { c -> BackupCheckin? in
                guard let h = c.habit else { return nil }
                return BackupCheckin(id: c.id, habitId: h.id, dateString: c.dateString, amount: c.amount)
            }
            
            let backupMoods = moodRecords.compactMap { m -> BackupMoodRecord? in
                guard let h = m.habit else { return nil }
                return BackupMoodRecord(id: m.id, habitId: h.id, type: m.type, text: m.text, imageData: m.imageData, timestamp: m.timestamp)
            }
            
            let backup = BackupData(habits: backupHabits, checkins: backupCheckins, moodRecords: backupMoods)
            
            let encoder = JSONEncoder()
            let data = try encoder.encode(backup)
            
            let url = FileManager.default.temporaryDirectory.appendingPathComponent("LittleHabitBackup.json")
            try data.write(to: url)
            return url
        } catch {
            print("Export error: \(error)")
            return nil
        }
    }
    
    func importData(from url: URL, modelContext: ModelContext) {
        guard url.startAccessingSecurityScopedResource() else { return }
        defer { url.stopAccessingSecurityScopedResource() }
        
        do {
            let data = try Data(contentsOf: url)
            let decoder = JSONDecoder()
            let backup = try decoder.decode(BackupData.self, from: data)
            
            // Delete existing
            try modelContext.delete(model: Habit.self)
            try modelContext.delete(model: Checkin.self)
            try modelContext.delete(model: MoodRecord.self)
            
            // Re-insert
            var habitMap: [String: Habit] = [:]
            
            for bh in backup.habits {
                let habit = Habit(name: bh.name, color: bh.color, icon: bh.icon)
                habit.id = bh.id
                habit.order = bh.order
                habit.isArchived = bh.isArchived
                habit.frequencyType = bh.frequencyType
                habit.goalType = bh.goalType
                habit.weeklyTarget = bh.weeklyTarget
                habit.monthlyTarget = bh.monthlyTarget
                habit.amountValue = bh.amountValue
                habit.amountUnit = bh.amountUnit
                modelContext.insert(habit)
                habitMap[bh.id] = habit
            }
            
            for bc in backup.checkins {
                if let h = habitMap[bc.habitId] {
                    let checkin = Checkin(dateString: bc.dateString, amount: bc.amount)
                    checkin.id = bc.id
                    checkin.habit = h
                    modelContext.insert(checkin)
                }
            }
            
            for bm in backup.moodRecords {
                if let h = habitMap[bm.habitId] {
                    let mood = MoodRecord(type: bm.type, text: bm.text)
                    mood.id = bm.id
                    mood.timestamp = bm.timestamp
                    mood.imageData = bm.imageData
                    mood.habit = h
                    modelContext.insert(mood)
                }
            }
            
            try modelContext.save()
            
        } catch {
            print("Import error: \(error)")
        }
    }
}
