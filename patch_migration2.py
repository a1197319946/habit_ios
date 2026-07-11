with open('Sources/LittleHabitTrackerApp.swift', 'r') as f:
    content = f.read()

import re

old_migration = """        let defaultURL = URL.applicationSupportDirectory.appending(path: "default.store")
        let fileManager = FileManager.default
        if fileManager.fileExists(atPath: defaultURL.path) && !fileManager.fileExists(atPath: sharedStoreURL.path) {
            do {
                try fileManager.copyItem(at: defaultURL, to: sharedStoreURL)
                let defaultShmURL = URL.applicationSupportDirectory.appending(path: "default.store-shm")
                let sharedShmURL = FileManager.default.containerURL(forSecurityApplicationGroupIdentifier: "group.com.littlehabit.tracker")!.appendingPathComponent("shared.store-shm")
                if fileManager.fileExists(atPath: defaultShmURL.path) {
                    try fileManager.copyItem(at: defaultShmURL, to: sharedShmURL)
                }
                
                let defaultWalURL = URL.applicationSupportDirectory.appending(path: "default.store-wal")
                let sharedWalURL = FileManager.default.containerURL(forSecurityApplicationGroupIdentifier: "group.com.littlehabit.tracker")!.appendingPathComponent("shared.store-wal")
                if fileManager.fileExists(atPath: defaultWalURL.path) {
                    try fileManager.copyItem(at: defaultWalURL, to: sharedWalURL)
                }
                print("Successfully migrated SwiftData to App Group container.")
            } catch {
                print("Migration failed: \\(error)")
            }
        }"""

new_migration = """        let defaultURL = URL.applicationSupportDirectory.appending(path: "default.store")
        let fileManager = FileManager.default
        
        let hasMigrated = UserDefaults.standard.bool(forKey: "didMigrateToAppGroup2")
        if !hasMigrated && fileManager.fileExists(atPath: defaultURL.path) {
            do {
                if fileManager.fileExists(atPath: sharedStoreURL.path) {
                    try fileManager.removeItem(at: sharedStoreURL)
                }
                try fileManager.copyItem(at: defaultURL, to: sharedStoreURL)
                
                let defaultShmURL = URL.applicationSupportDirectory.appending(path: "default.store-shm")
                let sharedShmURL = FileManager.default.containerURL(forSecurityApplicationGroupIdentifier: "group.com.littlehabit.tracker")!.appendingPathComponent("shared.store-shm")
                if fileManager.fileExists(atPath: sharedShmURL.path) { try fileManager.removeItem(at: sharedShmURL) }
                if fileManager.fileExists(atPath: defaultShmURL.path) {
                    try fileManager.copyItem(at: defaultShmURL, to: sharedShmURL)
                }
                
                let defaultWalURL = URL.applicationSupportDirectory.appending(path: "default.store-wal")
                let sharedWalURL = FileManager.default.containerURL(forSecurityApplicationGroupIdentifier: "group.com.littlehabit.tracker")!.appendingPathComponent("shared.store-wal")
                if fileManager.fileExists(atPath: sharedWalURL.path) { try fileManager.removeItem(at: sharedWalURL) }
                if fileManager.fileExists(atPath: defaultWalURL.path) {
                    try fileManager.copyItem(at: defaultWalURL, to: sharedWalURL)
                }
                UserDefaults.standard.set(true, forKey: "didMigrateToAppGroup2")
                print("Successfully migrated SwiftData to App Group container.")
            } catch {
                print("Migration failed: \\(error)")
            }
        }"""

content = content.replace(old_migration, new_migration)

with open('Sources/LittleHabitTrackerApp.swift', 'w') as f:
    f.write(content)
