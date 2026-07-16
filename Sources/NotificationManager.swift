import Foundation
import UserNotifications
import SwiftUI
import SwiftData
import UIKit

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
        cancelReminder(forHabitId: habit.id)
    }

    func cancelReminder(forHabitId habitId: String) {
        let center = UNUserNotificationCenter.current()
        let exactIds = (0..<60).map { "habit_\(habitId)_day_\($0)" } + ["habit_\(habitId)"]
        center.removePendingNotificationRequests(withIdentifiers: exactIds)
        center.removeDeliveredNotifications(withIdentifiers: exactIds)

        center.getPendingNotificationRequests { requests in
            let staleIds = requests
                .map(\.identifier)
                .filter { $0.hasPrefix("habit_\(habitId)_") }
            if !staleIds.isEmpty {
                center.removePendingNotificationRequests(withIdentifiers: staleIds)
            }
        }

        center.getDeliveredNotifications { notifications in
            let staleIds = notifications
                .map { $0.request.identifier }
                .filter { $0.hasPrefix("habit_\(habitId)_") }
            if !staleIds.isEmpty {
                center.removeDeliveredNotifications(withIdentifiers: staleIds)
            }
        }
    }

    func cancelAllHabitReminders() {
        let center = UNUserNotificationCenter.current()
        center.getPendingNotificationRequests { requests in
            let ids = requests.map(\.identifier).filter { $0.hasPrefix("habit_") }
            if !ids.isEmpty {
                center.removePendingNotificationRequests(withIdentifiers: ids)
            }
        }
        center.getDeliveredNotifications { notifications in
            let ids = notifications.map { $0.request.identifier }.filter { $0.hasPrefix("habit_") }
            if !ids.isEmpty {
                center.removeDeliveredNotifications(withIdentifiers: ids)
            }
        }
    }
    
    func scheduleReminder(for habit: Habit) {
        cancelReminder(for: habit)
        
        guard habit.isReminderEnabled && !habit.isArchived else {
            return
        }
        
        requestAuthorization { _ in }
        
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        let todayStr = formatter.string(from: Date())
        let isCheckedInToday = habit.checkinDates.contains(todayStr)
        
        let calendar = Calendar.current
        let now = Date()
        let rTime = habit.reminderTime ?? Date()
        let hour = calendar.component(.hour, from: rTime)
        let minute = calendar.component(.minute, from: rTime)
        
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
            let defaultMsg = L10n.timeToCheckInKeepItUp.tr(resolvedLanguage)
            let rText = habit.reminderText ?? ""
            content.body = (rText.isEmpty || rText == "该打卡啦！坚持就是胜利～" || rText == "Time to check in! Keep it up~") ? defaultMsg : rText
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

    private func appIconAttachment() -> UNNotificationAttachment? {
        let fileManager = FileManager.default
        let cacheURL = fileManager.temporaryDirectory.appendingPathComponent("tickday_notification_icon.png")
        if fileManager.fileExists(atPath: cacheURL.path) {
            return try? UNNotificationAttachment(identifier: "tickday_app_icon", url: cacheURL)
        }

        let image = UIImage(named: "app_logo")
            ?? UIImage(named: "AppIcon")
            ?? Bundle.main.url(forResource: "AppIcon60x60@2x", withExtension: "png").flatMap { UIImage(contentsOfFile: $0.path) }

        guard let data = image?.pngData() else {
            return nil
        }

        do {
            try data.write(to: cacheURL, options: .atomic)
            return try UNNotificationAttachment(identifier: "tickday_app_icon", url: cacheURL)
        } catch {
            print("Notification icon attachment error: \(error)")
            return nil
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
