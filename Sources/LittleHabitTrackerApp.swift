import SwiftUI
import SwiftData

enum AppLanguage: String, CaseIterable, Identifiable {
    case system = "system"
    case english = "en"
    case chinese = "zh"
    
    var id: String { self.rawValue }
    
    var displayName: String {
        switch self {
        case .system: return "跟随系统 (System)"
        case .english: return "English"
        case .chinese: return "中文 (Chinese)"
        }
    }
}

class AppSettings: ObservableObject {
    @AppStorage("appLanguage") var language: AppLanguage = .system
    @AppStorage("themeColorHex") var themeColorHex: String = "#5e4dbb"
    
    var locale: Locale? {
        if language == .system {
            return nil
        }
        return Locale(identifier: language.rawValue)
    }
    
    var resolvedLanguage: AppLanguage {
        if language == .system {
            if let langCode = Locale.current.language.languageCode?.identifier {
                if langCode.hasPrefix("zh") { return .chinese }
            }
            return .english
        }
        return language
    }
}

extension String {
    func tr(_ lang: AppLanguage) -> String {
        let translations: [String: [AppLanguage: String]] = [
            "Home": [.chinese: "首页", .english: "Home"],
            "Habits": [.chinese: "习惯", .english: "Habits"],
            "Stats": [.chinese: "统计", .english: "Stats"],
            "Profile": [.chinese: "我的", .english: "Profile"],
            "Manage Habits": [.chinese: "管理习惯", .english: "Manage Habits"],
            "You have ": [.chinese: "你当前有 ", .english: "You have "],
            " habits.": [.chinese: " 个习惯。", .english: " habits."],
            "Good Morning.": [.chinese: "早上好。", .english: "Good Morning."],
            "Here is your focus for today.": [.chinese: "这是你今天的目标。", .english: "Here is your focus for today."],
            "Daily": [.chinese: "每天", .english: "Daily"],
            "Progress": [.chinese: "进度", .english: "Progress"],
            "Goal": [.chinese: "目标", .english: "Goal"],
            "What do you want to build?": [.chinese: "你想养成什么习惯？", .english: "What do you want to build?"],
            "e.g. Read 10 pages, Drink water...": [.chinese: "例如：阅读10页、喝水...", .english: "e.g. Read 10 pages, Drink water..."],
            "Pick a Theme Color": [.chinese: "主题颜色", .english: "Theme Color"],
            "Theme Color": [.chinese: "主题颜色", .english: "Theme Color"],
            "Choose an Icon": [.chinese: "选择一个图标", .english: "Choose an Icon"],
            "Goal Type": [.chinese: "目标类型", .english: "Goal Type"],
            "Frequency": [.chinese: "频率", .english: "Frequency"],
            "Total Amount": [.chinese: "总计数量", .english: "Total Amount"],
            "Target (per week)": [.chinese: "目标 (每周)", .english: "Target (per week)"],
            "Target Amount (per week)": [.chinese: "目标数量 (每周)", .english: "Target Amount (per week)"],
            "Times": [.chinese: "次", .english: "Times"],
            "Create Habit": [.chinese: "创建习惯", .english: "Create Habit"],
            "Save Changes": [.chinese: "保存修改", .english: "Save Changes"],
            "Creating...": [.chinese: "保存中...", .english: "Creating..."],
            "Per Week": [.chinese: "按周", .english: "Per Week"],
            "Per Month": [.chinese: "按月", .english: "Per Month"],
            "Weekly Target": [.chinese: "每周目标次数", .english: "Weekly Target"],
            "Monthly Target": [.chinese: "每月目标次数", .english: "Monthly Target"],
            "Weekly Target Amount": [.chinese: "每周目标总量", .english: "Weekly Target Amount"],
            "Monthly Target Amount": [.chinese: "每月目标总量", .english: "Monthly Target Amount"],
            "Language": [.chinese: "多语言 / Language", .english: "Language / 多语言"],
            "Share with Friends": [.chinese: "分享给朋友", .english: "Share with Friends"],
            "Mood History": [.chinese: "心情日记", .english: "Mood History"],
            "Feedback": [.chinese: "意见反馈", .english: "Feedback"],
            "About": [.chinese: "关于", .english: "About"],
            "Contact Support": [.chinese: "联系客服", .english: "Contact Support"],
            "Tap to set name": [.chinese: "点击设置昵称", .english: "Tap to set name"],
            "Exploring mindfulness and building better habits, one day at a time.": [.chinese: "每天进步一点点。", .english: "Exploring mindfulness and building better habits, one day at a time."],
            "No habits yet": [.chinese: "没有习惯", .english: "No habits yet"],
            "Click the + button to add your first habit": [.chinese: "点击进入习惯管理页添加你的第一个习惯吧", .english: "Click the + button to add your first habit"],
            "Pending": [.chinese: "未完成", .english: "Pending"],
            "Completed": [.chinese: "已完成", .english: "Completed"],
            "\"Small steps, big changes.\"": [.chinese: "\"不积跬步，无以至千里。\"", .english: "\"Small steps, big changes.\""],
            "No moments recorded yet.": [.chinese: "暂无心情记录。", .english: "No moments recorded yet."],
            "Your Journey": [.chinese: "你的旅程", .english: "Your Journey"],
            "A reflective look back at your moods and moments.": [.chinese: "回顾你的心情与点滴时刻。", .english: "A reflective look back at your moods and moments."],
            "Check in": [.chinese: "记录", .english: "Check in"],
            "Edit": [.chinese: "修改", .english: "Edit"],
            "Check In": [.chinese: "完成打卡", .english: "Check In"],
            "Target Achieved!": [.chinese: "目标已达成！", .english: "Target Achieved!"],
            "New Habit": [.chinese: "新增习惯", .english: "New Habit"],
            "Edit Habit": [.chinese: "编辑习惯", .english: "Edit Habit"],
            "Record Mood": [.chinese: "记录心情", .english: "Record Mood"],
            "Generate Sharing Image": [.chinese: "生成分享图", .english: "Generate Sharing Image"],
            "Generating...": [.chinese: "生成中...", .english: "Generating..."],
            "Today": [.chinese: "今日", .english: "Today"],
            "Total": [.chinese: "累计", .english: "Total"],
            "Little Habit Tracker": [.chinese: "小习惯", .english: "Little Habit Tracker"],
            "Today,": [.chinese: "今天，", .english: "Today,"],
            "Yesterday,": [.chinese: "昨天，", .english: "Yesterday,"],
            "excited": [.chinese: "激动", .english: "Excited"],
            "happy": [.chinese: "开心", .english: "Happy"],
            "normal": [.chinese: "平静", .english: "Normal"],
            "down": [.chinese: "低落", .english: "Down"],
            "angry": [.chinese: "生气", .english: "Angry"],
            "Reports": [.chinese: "报告", .english: "Reports"],
            "Met": [.chinese: "达成率", .english: "Met"],
            "Best Day": [.chinese: "最佳单日", .english: "Best Day"],
            "Longest Streak": [.chinese: "最长连续", .english: "Longest Streak"],
            "Done": [.chinese: "打卡", .english: "Done"],
            "Streak": [.chinese: "连续", .english: "Streak"],
            "Weekly Grid": [.chinese: "本周网格", .english: "Weekly Grid"],
            "Your Progress": [.chinese: "你的进度", .english: "Your Progress"],
            "A detailed look at your journey.": [.chinese: "详细回顾你的成长之旅。", .english: "A detailed look at your journey."],
            "Month": [.chinese: "本月", .english: "Month"],
            "Year": [.chinese: "本年", .english: "Year"],
            "Weekly": [.chinese: "周", .english: "Weekly"],
            "Monthly": [.chinese: "月", .english: "Monthly"],
            "Yearly": [.chinese: "年", .english: "Yearly"],
            "All": [.chinese: "全部", .english: "All"],
            "Habit": [.chinese: "习惯", .english: "Habit"],
            "No habits found.": [.chinese: "暂无习惯", .english: "No habits found."],
            "Cumulative Streak": [.chinese: "累计连续打卡", .english: "Cumulative Streak"],
            "Top 5%": [.chinese: "前 5%", .english: "Top 5%"],
            "Days of continuous growth": [.chinese: "天连续成长", .english: "Days of continuous growth"],
            "Consistency Map": [.chinese: "连续性热力图", .english: "Consistency Map"],
            "Less": [.chinese: "少", .english: "Less"],
            "More": [.chinese: "多", .english: "More"],
            "Habit Distribution": [.chinese: "习惯分布", .english: "Habit Distribution"],
            "Mind": [.chinese: "心灵", .english: "Mind"],
            "Body": [.chinese: "身体", .english: "Body"],
            "Soul": [.chinese: "灵魂", .english: "Soul"],
            "Mon": [.chinese: "一", .english: "Mon"],
            "Tue": [.chinese: "二", .english: "Tue"],
            "Wed": [.chinese: "三", .english: "Wed"],
            "Thu": [.chinese: "四", .english: "Thu"],
            "Fri": [.chinese: "五", .english: "Fri"],
            "Sat": [.chinese: "六", .english: "Sat"],
            "Sun": [.chinese: "日", .english: "Sun"],
            "Days Streak": [.chinese: "天连续", .english: "Days Streak"],
            "30 Days": [.chinese: "近30天", .english: "30 Days"],
            "Delete": [.chinese: "删除", .english: "Delete"],
            "Archive": [.chinese: "归档", .english: "Archive"],
            "Restore": [.chinese: "恢复", .english: "Restore"],
            "Settings": [.chinese: "设置", .english: "Settings"],
            "Archived Habits": [.chinese: "已归档习惯", .english: "Archived Habits"],
            "Show Archived": [.chinese: "显示归档", .english: "Show Archived"],
            "No archived habits.": [.chinese: "暂无已归档的习惯。", .english: "No archived habits."],
            "This action will permanently delete this habit and all its check-in records. It cannot be recovered.": [.chinese: "此操作将永久删除该习惯及其所有打卡记录，且不可恢复。", .english: "This action will permanently delete this habit and all its check-in records. It cannot be recovered."],
            "This Week": [.chinese: "本周", .english: "This Week"],
            "This Month": [.chinese: "本月", .english: "This Month"],
            "This Session": [.chinese: "本次", .english: "This Session"],
            "Undo Check-in?": [.chinese: "撤销打卡？", .english: "Undo Check-in?"],
            "Cancel": [.chinese: "取消", .english: "Cancel"],
            "Undo": [.chinese: "撤销打卡", .english: "Undo"],
            "Edit Amount": [.chinese: "修改数据", .english: "Edit Amount"],
            "Share": [.chinese: "分享", .english: "Share"],
            "Save": [.chinese: "保存", .english: "Save"],
            "Saved to Photos": [.chinese: "已保存到相册", .english: "Saved to Photos"],
            "Check-in Success": [.chinese: "打卡成功", .english: "Check-in Success"],
            "W:": [.chinese: "周：", .english: "W:"],
            "M:": [.chinese: "月：", .english: "M:"],
            " times": [.chinese: " 次", .english: " times"]
        ]
        
        if let entry = translations[self] {
            if let translation = entry[lang] {
                return translation
            }
        }
        return self
    }
}

@main
struct LittleHabitTrackerApp: App {
    var sharedModelContainer: ModelContainer = {
        let schema = Schema([
            Habit.self,
            Checkin.self,
            MoodRecord.self
        ])
        let modelConfiguration = ModelConfiguration(schema: schema, isStoredInMemoryOnly: false)

        do {
            return try ModelContainer(for: schema, configurations: [modelConfiguration])
        } catch {
            fatalError("Could not create ModelContainer: \(error)")
        }
    }()

    @StateObject private var appSettings = AppSettings()

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(appSettings)
                .environment(\.locale, appSettings.locale ?? Locale.current)
                .id(appSettings.themeColorHex) // Global reload on theme change
        }
        .modelContainer(sharedModelContainer)
    }
}
