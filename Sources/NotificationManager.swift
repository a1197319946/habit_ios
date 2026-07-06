import Foundation
import UserNotifications
import SwiftUI
import SwiftData

class NotificationManager: NSObject, ObservableObject, UNUserNotificationCenterDelegate {
    static let shared = NotificationManager()
    
    private var resolvedLanguage: AppLanguage {
        let langStr = UserDefaults(suiteName: "group.com.littlehabit.tracker")?.string(forKey: "appLanguage") ?? "system"
        let lang = AppLanguage(rawValue: langStr) ?? .system
        if lang == .system {
            if let firstLang = Locale.preferredLanguages.first {
                if firstLang.hasPrefix("zh") { return .chinese }
            }
            return .english
        }
        return lang
    }
    
    private override init() {
        super.init()
        UNUserNotificationCenter.current().delegate = self
    }
    
    func requestAuthorization(completion: @escaping (Bool) -> Void) {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge]) { granted, error in
            DispatchQueue.main.async {
                if let error = error {
                    print("Notification auth error: \(error)")
                }
                completion(granted)
            }
        }
    }
    
    func checkAuthorizationStatus(completion: @escaping (UNAuthorizationStatus) -> Void) {
        UNUserNotificationCenter.current().getNotificationSettings { settings in
            DispatchQueue.main.async {
                completion(settings.authorizationStatus)
            }
        }
    }
    
    func cancelReminder(for habit: Habit) {
        let ids = (0..<30).map { "habit_\(habit.id)_day_\($0)" } + ["habit_\(habit.id)"]
        UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: ids)
    }
    
    func scheduleReminder(for habit: Habit) {
        cancelReminder(for: habit)
        
        guard habit.isReminderEnabled && !habit.isArchived else {
            return
        }
        
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        let todayStr = formatter.string(from: Date())
        let isCheckedInToday = habit.checkinDates.contains(todayStr)
        
        let calendar = Calendar.current
        let now = Date()
        let hour = calendar.component(.hour, from: habit.reminderTime)
        let minute = calendar.component(.minute, from: habit.reminderTime)
        
        for offset in 0..<14 {
            if offset == 0 && isCheckedInToday {
                // 如果今天已完成打卡，则无需在今天推送
                continue
            }
            
            guard let targetDay = calendar.date(byAdding: .day, value: offset, to: now) else { continue }
            var components = calendar.dateComponents([.year, .month, .day], from: targetDay)
            components.hour = hour
            components.minute = minute
            components.second = 0
            
            guard let triggerDate = calendar.date(from: components) else { continue }
            if triggerDate <= now {
                // 如果今天设定的推送时间已经过了，跳过今天
                continue
            }
            
            let content = UNMutableNotificationContent()
            content.title = habit.name
            let defaultMsg = "该打卡啦！坚持就是胜利～".tr(resolvedLanguage)
            content.body = (habit.reminderText.isEmpty || habit.reminderText == "该打卡啦！坚持就是胜利～" || habit.reminderText == "Time to check in! Keep it up~") ? defaultMsg : habit.reminderText
            content.sound = .default
            content.userInfo = ["habitId": habit.id]
            
            let trigger = UNCalendarNotificationTrigger(dateMatching: components, repeats: false)
            let request = UNNotificationRequest(identifier: "habit_\(habit.id)_day_\(offset)", content: content, trigger: trigger)
            UNUserNotificationCenter.current().add(request) { error in
                if let error = error {
                    print("Failed to schedule reminder for habit \(habit.name) on day \(offset): \(error)")
                }
            }
        }
    }
    
    func updateAllReminders(habits: [Habit]) {
        for habit in habits {
            scheduleReminder(for: habit)
        }
    }
    
    // MARK: - UNUserNotificationCenterDelegate
    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        completionHandler([.banner, .sound])
    }
    
    func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {
        completionHandler()
    }
}
