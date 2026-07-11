import Foundation
import CoreData
import WidgetKit

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
    
    func exportData(modelContext: NSManagedObjectContext) -> URL? {
        do {
            let habits = try modelContext.fetch(Habit.fetchRequest()) as! [Habit]
            let checkins = try modelContext.fetch(Checkin.fetchRequest()) as! [Checkin]
            let moodRecords = try modelContext.fetch(MoodRecord.fetchRequest()) as! [MoodRecord]
            
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
    
    func exportExcelData(modelContext: NSManagedObjectContext, language: AppLanguage) -> URL? {
        do {
            let habits = try modelContext.fetch(Habit.fetchRequest()) as! [Habit]
            let checkins = try modelContext.fetch(Checkin.fetchRequest()) as! [Checkin]
            
            let isCN = (language == .chinese)
            
            var csvString = "\u{FEFF}"
            if isCN {
                csvString += "习惯名称,颜色编号,图标编号,频率类型,目标类型,打卡日期,打卡数值\n"
            } else {
                csvString += "Habit Name,Color Hex,Icon Name,Frequency Type,Goal Type,Check-in Date,Amount\n"
            }
            
            for habit in habits {
                let habitCheckins = checkins.filter { $0.habit?.id == habit.id }
                if habitCheckins.isEmpty {
                    let name = csvEscape(habit.name)
                    let status = isCN ? "暂无记录" : "No records"
                    csvString += "\(name),\(habit.color),\(habit.icon),\(habit.frequencyType),\(habit.goalType),\(status),0\n"
                } else {
                    for checkin in habitCheckins.sorted(by: { $0.dateString > $1.dateString }) {
                        let name = csvEscape(habit.name)
                        csvString += "\(name),\(habit.color),\(habit.icon),\(habit.frequencyType),\(habit.goalType),\(checkin.dateString),\(checkin.amount)\n"
                    }
                }
            }
            
            let url = FileManager.default.temporaryDirectory.appendingPathComponent("LittleHabit_Excel_Data.csv")
            try csvString.write(to: url, atomically: true, encoding: .utf8)
            return url
        } catch {
            print("Export Excel error: \(error)")
            return nil
        }
    }
    
    private func csvEscape(_ string: String) -> String {
        if string.contains(",") || string.contains("\"") || string.contains("\n") {
            return "\"\(string.replacingOccurrences(of: "\"", with: "\"\""))\""
        }
        return string
    }
    
    func importData(from url: URL, modelContext: NSManagedObjectContext) {
        guard url.startAccessingSecurityScopedResource() else { return }
        defer { url.stopAccessingSecurityScopedResource() }
        
        do {
            let data = try Data(contentsOf: url)
            let decoder = JSONDecoder()
            let backup = try decoder.decode(BackupData.self, from: data)
            
            NotificationManager.shared.cancelAllHabitReminders()
            let fetchHabits = NSFetchRequest<NSFetchRequestResult>(entityName: "Habit")
            let deleteHabits = NSBatchDeleteRequest(fetchRequest: fetchHabits)
            let fetchCheckins = NSFetchRequest<NSFetchRequestResult>(entityName: "Checkin")
            let deleteCheckins = NSBatchDeleteRequest(fetchRequest: fetchCheckins)
            let fetchMoods = NSFetchRequest<NSFetchRequestResult>(entityName: "MoodRecord")
            let deleteMoods = NSBatchDeleteRequest(fetchRequest: fetchMoods)
            
            try modelContext.execute(deleteHabits)
            try modelContext.execute(deleteCheckins)
            try modelContext.execute(deleteMoods)
            
            var habitMap: [String: Habit] = [:]
            
            for bh in backup.habits {
                let habit = Habit(context: modelContext)
                habit.name = bh.name
                habit.color = bh.color
                habit.icon = bh.icon
                habit.id = bh.id
                habit.order = bh.order
                habit.isArchived = bh.isArchived
                habit.frequencyType = bh.frequencyType
                habit.goalType = bh.goalType
                habit.weeklyTarget = bh.weeklyTarget
                habit.monthlyTarget = bh.monthlyTarget
                habit.amountValue = bh.amountValue
                habit.amountUnit = bh.amountUnit
                habitMap[bh.id] = habit
            }
            
            for bc in backup.checkins {
                if let h = habitMap[bc.habitId] {
                    let checkin = Checkin(context: modelContext)
                    checkin.dateString = bc.dateString
                    checkin.amount = bc.amount
                    checkin.id = bc.id
                    checkin.habit = h
                }
            }
            
            for bm in backup.moodRecords {
                if let h = habitMap[bm.habitId] {
                    let mood = MoodRecord(context: modelContext)
                    mood.type = bm.type
                    mood.text = bm.text
                    mood.id = bm.id
                    mood.timestamp = bm.timestamp
                    mood.imageData = bm.imageData
                    mood.habit = h
                }
            }
            
            try modelContext.save()
            WidgetCenter.shared.reloadAllTimelines()
            
        } catch {
            print("Import error: \(error)")
        }
    }
}
