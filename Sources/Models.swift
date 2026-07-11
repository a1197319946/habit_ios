import Foundation
import CoreData

@objc(Habit)
public class Habit: NSManagedObject, Identifiable {
    @NSManaged public var id: String
    @NSManaged public var name: String
    @NSManaged public var color: String
    @NSManaged public var icon: String
    
    @NSManaged public var goalType: String
    @NSManaged public var frequencyType: String
    
    @NSManaged public var weeklyTarget: Int
    @NSManaged public var monthlyTarget: Int
    
    @NSManaged public var amountValue: Double
    @NSManaged public var amountUnit: String
    
    @NSManaged public var order: Int
    @NSManaged public var isArchived: Bool
    
    @NSManaged public var createdAt: Date
    
    @NSManaged public var isReminderEnabled: Bool
    @NSManaged public var reminderTime: Date
    @NSManaged public var reminderText: String
    
    @NSManaged public var checkins: NSSet?
    @NSManaged public var moodRecords: NSSet?
    
    public override func awakeFromInsert() {
        super.awakeFromInsert()
        self.id = UUID().uuidString
        self.color = "#8B5CF6"
        self.icon = "star.fill"
        self.goalType = "frequency"
        self.frequencyType = "weekly"
        self.weeklyTarget = 3
        self.monthlyTarget = 10
        self.amountValue = 0.0
        self.amountUnit = ""
        self.order = 0
        self.isArchived = false
        self.createdAt = Date()
        self.isReminderEnabled = false
        self.reminderTime = Calendar.current.date(from: DateComponents(hour: 20, minute: 0)) ?? Date()
        self.reminderText = ""
    }
}

@objc(Checkin)
public class Checkin: NSManagedObject, Identifiable {
    @NSManaged public var id: String
    @NSManaged public var dateString: String
    @NSManaged public var timestamp: Date
    @NSManaged public var amount: Double
    
    @NSManaged public var habit: Habit?
    
    public override func awakeFromInsert() {
        super.awakeFromInsert()
        self.id = UUID().uuidString
        self.timestamp = Date()
        self.amount = 0.0
        self.dateString = ""
    }
}

@objc(MoodRecord)
public class MoodRecord: NSManagedObject, Identifiable {
    @NSManaged public var id: String
    @NSManaged public var type: String
    @NSManaged public var text: String
    @NSManaged public var timestamp: Date
    @NSManaged public var imageData: Data?
    
    @NSManaged public var habit: Habit?
    
    public override func awakeFromInsert() {
        super.awakeFromInsert()
        self.id = UUID().uuidString
        self.type = "normal"
        self.text = ""
        self.timestamp = Date()
    }
}

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
    var checkinsArray: [Checkin] {
        let set = checkins as? Set<Checkin> ?? []
        return set.sorted { $0.timestamp < $1.timestamp }
    }
    
    var moodRecordsArray: [MoodRecord] {
        let set = moodRecords as? Set<MoodRecord> ?? []
        return set.sorted { $0.timestamp < $1.timestamp }
    }
    
    var checkinDates: Set<String> {
        Set(checkinsArray.map { $0.dateString })
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
    
    var last182DaysCheckins: [Bool] {
        var calendar = Calendar.current
        calendar.firstWeekday = UserDefaults.standard.integer(forKey: "firstWeekday") == 0 ? 2 : UserDefaults.standard.integer(forKey: "firstWeekday")
        let dates = checkinDates
        var result: [Bool] = Array(repeating: false, count: 182)
        
        let today = Date()
        
        for i in 0..<182 {
            if let date = calendar.date(byAdding: .day, value: -i, to: today) {
                let dateStr = SharedFormatters.dateString(from: date)
                result[181 - i] = dates.contains(dateStr)
            }
        }
        return result
    }
}

extension Habit {
    @nonobjc public class func fetchRequest() -> NSFetchRequest<Habit> {
        return NSFetchRequest<Habit>(entityName: "Habit")
    }
}

extension Checkin {
    @nonobjc public class func fetchRequest() -> NSFetchRequest<Checkin> {
        return NSFetchRequest<Checkin>(entityName: "Checkin")
    }
}

extension MoodRecord {
    @nonobjc public class func fetchRequest() -> NSFetchRequest<MoodRecord> {
        return NSFetchRequest<MoodRecord>(entityName: "MoodRecord")
    }
}
import Foundation
import CoreData

class PersistenceController {
    static let shared = PersistenceController()
    
    let container: NSPersistentContainer
    
    init(inMemory: Bool = false) {
        let model = PersistenceController.createModel()
        container = NSPersistentContainer(name: "LittleHabitTracker", managedObjectModel: model)
        
        if inMemory {
            container.persistentStoreDescriptions.first!.url = URL(fileURLWithPath: "/dev/null")
        } else {
            if let groupURL = FileManager.default.containerURL(forSecurityApplicationGroupIdentifier: "group.com.littlehabit.tracker") {
                let storeURL = groupURL.appendingPathComponent("LittleHabitTracker.sqlite")
                let description = NSPersistentStoreDescription(url: storeURL)
                description.shouldMigrateStoreAutomatically = true
                description.shouldInferMappingModelAutomatically = true
                description.setOption(true as NSNumber, forKey: NSPersistentHistoryTrackingKey)
                description.setOption(true as NSNumber, forKey: NSPersistentStoreRemoteChangeNotificationPostOptionKey)
                container.persistentStoreDescriptions = [description]
            }
        }
        
        container.loadPersistentStores { (storeDescription, error) in
            if let error = error as NSError? {
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        }
        
        container.viewContext.automaticallyMergesChangesFromParent = true
        container.viewContext.mergePolicy = NSMergeByPropertyObjectTrumpMergePolicy
    }
    
    static func createModel() -> NSManagedObjectModel {
        let model = NSManagedObjectModel()
        
        let habitEntity = NSEntityDescription()
        habitEntity.name = "Habit"
        habitEntity.managedObjectClassName = "Habit"
        
        let checkinEntity = NSEntityDescription()
        checkinEntity.name = "Checkin"
        checkinEntity.managedObjectClassName = "Checkin"
        
        let moodRecordEntity = NSEntityDescription()
        moodRecordEntity.name = "MoodRecord"
        moodRecordEntity.managedObjectClassName = "MoodRecord"
        
        // Habit Attributes
        let hId = NSAttributeDescription(); hId.name = "id"; hId.attributeType = .stringAttributeType; hId.isOptional = false
        let hName = NSAttributeDescription(); hName.name = "name"; hName.attributeType = .stringAttributeType; hName.isOptional = false
        let hColor = NSAttributeDescription(); hColor.name = "color"; hColor.attributeType = .stringAttributeType; hColor.isOptional = false; hColor.defaultValue = "#8B5CF6"
        let hIcon = NSAttributeDescription(); hIcon.name = "icon"; hIcon.attributeType = .stringAttributeType; hIcon.isOptional = false; hIcon.defaultValue = "star.fill"
        let hGoalType = NSAttributeDescription(); hGoalType.name = "goalType"; hGoalType.attributeType = .stringAttributeType; hGoalType.isOptional = false; hGoalType.defaultValue = "frequency"
        let hFreqType = NSAttributeDescription(); hFreqType.name = "frequencyType"; hFreqType.attributeType = .stringAttributeType; hFreqType.isOptional = false; hFreqType.defaultValue = "weekly"
        let hWeekTarget = NSAttributeDescription(); hWeekTarget.name = "weeklyTarget"; hWeekTarget.attributeType = .integer64AttributeType; hWeekTarget.isOptional = false; hWeekTarget.defaultValue = 3
        let hMonthTarget = NSAttributeDescription(); hMonthTarget.name = "monthlyTarget"; hMonthTarget.attributeType = .integer64AttributeType; hMonthTarget.isOptional = false; hMonthTarget.defaultValue = 10
        let hAmtValue = NSAttributeDescription(); hAmtValue.name = "amountValue"; hAmtValue.attributeType = .doubleAttributeType; hAmtValue.isOptional = false; hAmtValue.defaultValue = 0.0
        let hAmtUnit = NSAttributeDescription(); hAmtUnit.name = "amountUnit"; hAmtUnit.attributeType = .stringAttributeType; hAmtUnit.isOptional = false; hAmtUnit.defaultValue = ""
        let hOrder = NSAttributeDescription(); hOrder.name = "order"; hOrder.attributeType = .integer64AttributeType; hOrder.isOptional = false; hOrder.defaultValue = 0
        let hArchived = NSAttributeDescription(); hArchived.name = "isArchived"; hArchived.attributeType = .booleanAttributeType; hArchived.isOptional = false; hArchived.defaultValue = false
        let hCreated = NSAttributeDescription(); hCreated.name = "createdAt"; hCreated.attributeType = .dateAttributeType; hCreated.isOptional = false
        let hRemindEn = NSAttributeDescription(); hRemindEn.name = "isReminderEnabled"; hRemindEn.attributeType = .booleanAttributeType; hRemindEn.isOptional = false; hRemindEn.defaultValue = false
        let hRemindTime = NSAttributeDescription(); hRemindTime.name = "reminderTime"; hRemindTime.attributeType = .dateAttributeType; hRemindTime.isOptional = false
        let hRemindText = NSAttributeDescription(); hRemindText.name = "reminderText"; hRemindText.attributeType = .stringAttributeType; hRemindText.isOptional = false; hRemindText.defaultValue = ""
        
        habitEntity.properties = [hId, hName, hColor, hIcon, hGoalType, hFreqType, hWeekTarget, hMonthTarget, hAmtValue, hAmtUnit, hOrder, hArchived, hCreated, hRemindEn, hRemindTime, hRemindText]
        
        // Checkin Attributes
        let cId = NSAttributeDescription(); cId.name = "id"; cId.attributeType = .stringAttributeType; cId.isOptional = false
        let cDateStr = NSAttributeDescription(); cDateStr.name = "dateString"; cDateStr.attributeType = .stringAttributeType; cDateStr.isOptional = false
        let cTime = NSAttributeDescription(); cTime.name = "timestamp"; cTime.attributeType = .dateAttributeType; cTime.isOptional = false
        let cAmt = NSAttributeDescription(); cAmt.name = "amount"; cAmt.attributeType = .doubleAttributeType; cAmt.isOptional = false; cAmt.defaultValue = 0.0
        
        // MoodRecord Attributes
        let mId = NSAttributeDescription(); mId.name = "id"; mId.attributeType = .stringAttributeType; mId.isOptional = false
        let mType = NSAttributeDescription(); mType.name = "type"; mType.attributeType = .stringAttributeType; mType.isOptional = false; mType.defaultValue = "normal"
        let mText = NSAttributeDescription(); mText.name = "text"; mText.attributeType = .stringAttributeType; mText.isOptional = false; mText.defaultValue = ""
        let mTime = NSAttributeDescription(); mTime.name = "timestamp"; mTime.attributeType = .dateAttributeType; mTime.isOptional = false
        let mImg = NSAttributeDescription(); mImg.name = "imageData"; mImg.attributeType = .binaryDataAttributeType; mImg.isOptional = true; mImg.allowsExternalBinaryDataStorage = true
        
        // Relationships
        let habitToCheckins = NSRelationshipDescription()
        habitToCheckins.name = "checkins"
        habitToCheckins.destinationEntity = checkinEntity
        habitToCheckins.maxCount = 0 // to-many
        habitToCheckins.deleteRule = .cascadeDeleteRule
        habitToCheckins.isOptional = true
        
        let checkinToHabit = NSRelationshipDescription()
        checkinToHabit.name = "habit"
        checkinToHabit.destinationEntity = habitEntity
        checkinToHabit.maxCount = 1
        checkinToHabit.deleteRule = .nullifyDeleteRule
        checkinToHabit.isOptional = true
        
        habitToCheckins.inverseRelationship = checkinToHabit
        checkinToHabit.inverseRelationship = habitToCheckins
        
        let habitToMoods = NSRelationshipDescription()
        habitToMoods.name = "moodRecords"
        habitToMoods.destinationEntity = moodRecordEntity
        habitToMoods.maxCount = 0
        habitToMoods.deleteRule = .cascadeDeleteRule
        habitToMoods.isOptional = true
        
        let moodToHabit = NSRelationshipDescription()
        moodToHabit.name = "habit"
        moodToHabit.destinationEntity = habitEntity
        moodToHabit.maxCount = 1
        moodToHabit.deleteRule = .nullifyDeleteRule
        moodToHabit.isOptional = true
        
        habitToMoods.inverseRelationship = moodToHabit
        moodToHabit.inverseRelationship = habitToMoods
        
        checkinEntity.properties = [cId, cDateStr, cTime, cAmt, checkinToHabit]
        moodRecordEntity.properties = [mId, mType, mText, mTime, mImg, moodToHabit]
        habitEntity.properties.append(contentsOf: [habitToCheckins, habitToMoods])
        
        model.entities = [habitEntity, checkinEntity, moodRecordEntity]
        return model
    }
}
