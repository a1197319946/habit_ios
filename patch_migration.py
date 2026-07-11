with open('Sources/LittleHabitTrackerApp.swift', 'r') as f:
    content = f.read()

migration_code = """        let sharedStoreURL = FileManager.default.containerURL(forSecurityApplicationGroupIdentifier: "group.com.littlehabit.tracker")!.appendingPathComponent("shared.store")
        
        // Data Migration: move from old default.store to shared App Group store
        let defaultURL = URL.applicationSupportDirectory.appending(path: "default.store")
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
        }
        
        let modelConfiguration = ModelConfiguration(schema: schema, url: sharedStoreURL)"""

old_code = """        let sharedStoreURL = FileManager.default.containerURL(forSecurityApplicationGroupIdentifier: "group.com.littlehabit.tracker")!.appendingPathComponent("shared.store")
        let modelConfiguration = ModelConfiguration(schema: schema, url: sharedStoreURL)"""

content = content.replace(old_code, migration_code)

with open('Sources/LittleHabitTrackerApp.swift', 'w') as f:
    f.write(content)
