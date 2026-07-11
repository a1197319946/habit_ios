import SwiftUI
import SwiftData

enum AppLanguage: String, CaseIterable, Identifiable {
    case system = "system"
    case english = "en"
    case chinese = "zh"
    
    var id: String { self.rawValue }
    
    var displayName: String {
        switch self {
        case .system: return "系统"
        case .english: return "EN"
        case .chinese: return "中文"
        }
    }
}

enum AppTheme: String, CaseIterable, Identifiable {
    case system = "system"
    case light = "light"
    case dark = "dark"
    
    var id: String { self.rawValue }
    
    func displayName(in language: AppLanguage) -> String {
        switch self {
        case .system: return "System".tr(language)
        case .light: return "Light".tr(language)
        case .dark: return "Dark".tr(language)
        }
    }
}

class AppSettings: ObservableObject {
    @AppStorage("isPremium", store: UserDefaults(suiteName: "group.com.littlehabit.tracker")) var isPremium: Bool = false
    @AppStorage("appLockEnabled", store: UserDefaults(suiteName: "group.com.littlehabit.tracker")) var appLockEnabled: Bool = false
    @AppStorage("iCloudSyncEnabled", store: UserDefaults(suiteName: "group.com.littlehabit.tracker")) var iCloudSyncEnabled: Bool = false
    
    @Published var showPaywall: Bool = false
    @Published var showPaywallFromSettings: Bool = false
    @Published var showRetentionOffer: Bool = false
    @Published var openCheckinHabitId: String? = nil
    @AppStorage("hasSeenRetentionOffer", store: UserDefaults(suiteName: "group.com.littlehabit.tracker")) var hasSeenRetentionOffer: Bool = false

    @AppStorage("appLanguage", store: UserDefaults(suiteName: "group.com.littlehabit.tracker")) var language: AppLanguage = .system
    @AppStorage("themeColorHex", store: UserDefaults(suiteName: "group.com.littlehabit.tracker")) var themeColorHex: String = "#5e4dbb"
    @AppStorage("themeMode", store: UserDefaults(suiteName: "group.com.littlehabit.tracker")) var themeMode: AppTheme = .system
    @AppStorage("firstWeekday", store: UserDefaults(suiteName: "group.com.littlehabit.tracker")) var firstWeekday: Int = 2 // 2 = Monday, 1 = Sunday
    
    
    var colorScheme: ColorScheme? {
        switch themeMode {
        case .system: return nil
        case .light: return .light
        case .dark: return .dark
        }
    }
    
    init() {
        if !isPremium {
            resetPremiumSettingsToDefault()
        }
    }
    
    func resetPremiumSettingsToDefault() {
        appLockEnabled = false
        iCloudSyncEnabled = false
        themeColorHex = "#5e4dbb"
        themeMode = .system
        applyTheme()
    }
    
    func applyTheme() {
        DispatchQueue.main.async {
            for scene in UIApplication.shared.connectedScenes {
                if let windowScene = scene as? UIWindowScene {
                    for window in windowScene.windows {
                        switch self.themeMode {
                        case .system: window.overrideUserInterfaceStyle = .unspecified
                        case .light: window.overrideUserInterfaceStyle = .light
                        case .dark: window.overrideUserInterfaceStyle = .dark
                        }
                    }
                }
            }
        }
    }

    var locale: Locale? {
        if language == .system {
            return nil
        }
        return Locale(identifier: language.rawValue)
    }
    
    var customCalendar: Calendar {
        var cal = Calendar.current
        cal.firstWeekday = firstWeekday
        return cal
    }
    
    var resolvedLanguage: AppLanguage {
        if language == .system {
            if let firstLang = Locale.preferredLanguages.first {
                if firstLang.hasPrefix("zh") { return .chinese }
            }
            return .english
        }
        return language
    }
}
// 新增多语言的时候务必查询 是否已经有了这个多语言标签，如有则用现有的，没有再新增！
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
            "记录心情": [.chinese: "记录心情", .english: "Record Mood"],
            "当前心情": [.chinese: "当前心情", .english: "Current Mood"],
            "想法 (选填)": [.chinese: "想法 (选填)", .english: "Thoughts (Optional)"],
            "写下这一刻的想法...": [.chinese: "写下这一刻的想法...", .english: "Write down your thoughts..."],
            "图片 (选填)": [.chinese: "图片 (选填)", .english: "Image (Optional)"],
            "添加图片": [.chinese: "添加图片", .english: "Add Image"],
            "记录": [.chinese: "记录", .english: "Save"],
            "激动": [.chinese: "激动", .english: "Excited"],
            "开心": [.chinese: "开心", .english: "Happy"],
            "一般": [.chinese: "一般", .english: "Normal"],
            "失落": [.chinese: "失落", .english: "Down"],
            "愤怒": [.chinese: "愤怒", .english: "Angry"],
            "兑换码 / Redeem Code": [.chinese: "使用兑换码兑换会员", .english: "Redeem Offer Code"],
            "Track your daily progress": [.chinese: "记录你的每日进步", .english: "Track your daily progress"],
            "Generate Sharing Image": [.chinese: "生成分享图", .english: "Generate Sharing Image"],
            "公里": [.chinese: "公里", .english: "km"],
            "米": [.chinese: "米", .english: "m"],
            "分钟": [.chinese: "分钟", .english: "mins"],
            "小时": [.chinese: "小时", .english: "hours"],
            "次": [.chinese: "次", .english: "times"],
            "页": [.chinese: "页", .english: "pages"],
            "天": [.chinese: "天", .english: "days"],
            "周": [.chinese: "周", .english: "week"],
            "本周": [.chinese: "本周", .english: "This Week"],
            "本月": [.chinese: "本月", .english: "This Month"],
            "周目标": [.chinese: "周目标", .english: "Weekly Target"],
            "月目标": [.chinese: "月目标", .english: "Monthly Target"],
            "月": [.chinese: "月", .english: "month"],
            "App Locked": [.chinese: "应用已锁定", .english: "App Locked"],
            "Unlock": [.chinese: "解锁", .english: "Unlock"],
            "Unlock Little Habit": [.chinese: "解锁 TickDay", .english: "Unlock TickDay"],
            "Restore Purchase": [.chinese: "恢复购买", .english: "Restore"],
            "Monthly Card": [.chinese: "月度卡", .english: "Monthly Card"],
            "Yearly Card": [.chinese: "年度卡", .english: "Yearly Card"],
            "Lifetime Card": [.chinese: "终身卡", .english: "Lifetime Card"],
            "Start Free Trial": [.chinese: "开始免费试用", .english: "Start Free Trial"],
            "Purchase Now": [.chinese: "立即购买", .english: "Purchase Now"],
            "Wait, a special offer!": [.chinese: "等一下，送您一份专属优惠！", .english: "Wait, a special offer!"],
            "Claim Yearly Discount": [.chinese: "领取年度卡折扣", .english: "Claim Yearly Discount"],
            "No, thanks": [.chinese: "残忍拒绝", .english: "No, thanks"],
            "Cancel anytime during trial": [.chinese: "试用期间随时取消", .english: "Cancel anytime during trial"],
            "Ad-Free Experience": [.chinese: "纯净无广告", .english: "Ad-Free Experience"],
            "Reduce the resistance to your daily habits.": [.chinese: "降低坚持的阻力", .english: "Reduce the resistance to your daily habits."],
            "Enter Data": [.chinese: "录入打卡数据", .english: "Enter Data"],
            "Edit Data": [.chinese: "修改打卡数据", .english: "Edit Data"],
            "Period Target: ": [.chinese: "本周期目标: ", .english: "Period Target: "],
            "Period Total: ": [.chinese: "本周期已累计: ", .english: "Period Total: "],
            "Amount Completed": [.chinese: "本次完成量", .english: "Amount Completed"],
            "Undo Check-in": [.chinese: "撤销打卡", .english: "Undo Check-in"],
            "Edit Amount": [.chinese: "修改数值", .english: "Edit Amount"],
                        " Total": [.chinese: "累计", .english: " Total"],
            " Achieved!": [.chinese: "已达成！", .english: " Achieved!"],
                        "Options": [.chinese: "操作", .english: "Options"],
                        "Check-in Successful": [.chinese: "打卡成功", .english: "Check-in Successful"],

            "Hide Archived": [.chinese: "隐藏归档", .english: "Hide Archived"],
            "Statistics Overview": [.chinese: "统计概览", .english: "Statistics Overview"],
            "统计概览": [.chinese: "统计概览", .english: "Statistics Overview"],
            "15 天免费试用": [.chinese: "15 天免费试用", .english: "15-Day Free Trial"],
            "习惯名称": [.chinese: "习惯名称", .english: "Habit Name"],
            "颜色和图标": [.chinese: "颜色和图标", .english: "Color and Icon"],
            "颜色": [.chinese: "颜色", .english: "Color"],
            "图标": [.chinese: "图标", .english: "Icon"],
            "选择图标": [.chinese: "选择图标", .english: "Choose an Icon"],
            "目标规则": [.chinese: "目标规则", .english: "Goal Rules"],
            " Times": [.chinese: "次", .english: " Times"],
            " Month": [.chinese: "月", .english: " Month"],
            " Year": [.chinese: " 年", .english: " Year"],
            "Target: ": [.chinese: "目标: ", .english: "Target: "],
            " Times/Week": [.chinese: "次/周", .english: " Times/Week"],
            "Statistics": [.chinese: "统计数据", .english: "Statistics"],
            "Yearly Calendar": [.chinese: "年度日历", .english: "Yearly Calendar"],
            "Data irrecoverable after deletion.": [.chinese: "删除后所有相关打卡数据将无法恢复。", .english: "Data irrecoverable after deletion."],
            "Check-in Days": [.chinese: "打卡天数", .english: "Check-in Days"],
            "Check-in Amount": [.chinese: "打卡数量", .english: "Check-in Amount"],
            "Check-in Records": [.chinese: "打卡记录", .english: "Check-in Records"],
            "No check-in records": [.chinese: "暂无打卡记录", .english: "No check-in records"],
            "No check-ins on this day": [.chinese: "当日无打卡记录", .english: "No check-ins on this day"],
            "No data": [.chinese: "暂无数据", .english: "No data"],
            "No data for this week.": [.chinese: "本周暂无数据", .english: "No data for this week."],
            "美好的改变，从今天开始": [.chinese: "美好的改变，从今天开始", .english: "Beautiful changes begin today"],
            "开启你的第一个小习惯吧": [.chinese: "开启你的第一个小习惯吧", .english: "Let's create your first habit"],
            "创建第一个习惯": [.chinese: "创建第一个习惯", .english: "Create First Habit"],
            "Help & Support": [.chinese: "帮助与反馈", .english: "Help & Support"],
            "Habit Details": [.chinese: "习惯详情", .english: "Habit Details"],
            "Redeem Offer Code": [.chinese: "使用兑换码", .english: "Redeem Offer Code"],
            
            "Features": [.chinese: "功能", .english: "Features"],
            "Widgets": [.chinese: "小组件", .english: "Widgets"],
            "Add to Home Screen": [.chinese: "添加到主屏幕", .english: "Add to Home Screen"],
            "How to add Widgets": [.chinese: "如何添加小组件", .english: "How to add Widgets"],
            "Go to your Home Screen.": [.chinese: "回到手机主屏幕", .english: "Go to your Home Screen."],
            "Long press any empty space until apps jiggle.": [.chinese: "长按主屏幕空白处，直到应用图标开始抖动", .english: "Long press any empty space until apps jiggle."],
            "Tap the '+' button in the top left corner.": [.chinese: "点击左上角的“+”按钮", .english: "Tap the '+' button in the top left corner."],
            "Search for 'Little Habit' and add your favorite widget.": [.chinese: "搜索“Little Habit”，选择并添加你喜欢的小组件", .english: "Search for 'Little Habit' and add your favorite widget."],
            "Got it": [.chinese: "我知道了", .english: "Got it"],

            "Frequency Goal": [.chinese: "次数目标", .english: "Frequency Goal"],
            "Amount Goal": [.chinese: "总量目标", .english: "Amount Goal"],
            "次数目标": [.chinese: "次数目标", .english: "Frequency Goal"],
            "总量目标": [.chinese: "总量目标", .english: "Amount Goal"],

            "打卡天数": [.chinese: "打卡天数", .english: "Check-in Days"],
            "总数值": [.chinese: "总数值", .english: "Total Amount"],
            "Monthly Trend": [.chinese: "月度趋势", .english: "Monthly Trend"],
            "Monthly Details": [.chinese: "月度详情", .english: "Monthly Details"],
            "Check-in Days Trend": [.chinese: "打卡次数趋势", .english: "Check-in Days Trend"],
            "Total Amount Trend": [.chinese: "打卡总量趋势", .english: "Total Amount Trend"],
            "Total Days": [.chinese: "累计打卡", .english: "Total Days"],

            "System": [.chinese: "系统", .english: "System"],
            "Light": [.chinese: "浅色", .english: "Light"],
            "Dark": [.chinese: "深色", .english: "Dark"],
            "Appearance": [.chinese: "外观", .english: "Appearance"],
            "Start of Week": [.chinese: "一周开始", .english: "Start of Week"],
            "Monday": [.chinese: "周一", .english: "Monday"],
            "Sunday": [.chinese: "周日", .english: "Sunday"],
            "Cancel": [.chinese: "取消", .english: "Cancel"],
            "Close": [.chinese: "关闭", .english: "Close"],
            "Show Completed": [.chinese: "显示已打卡", .english: "Show Completed"],
            "Hide Completed": [.chinese: "隐藏已打卡", .english: "Hide Completed"],
            "This Week": [.chinese: "本周", .english: "This Week"],
            "This Month": [.chinese: "本月", .english: "This Month"],
            "Week": [.chinese: "本周", .english: "Week"],
            " times": [.chinese: "次", .english: " times"],
            " time": [.chinese: "次", .english: " time"],
            "Cancel Check-in?": [.chinese: "操作", .english: "Options"],

            "Generating...": [.chinese: "生成中...", .english: "Generating..."],
            "Today": [.chinese: "今日", .english: "Today"],
            "Total": [.chinese: "累计", .english: "Total"],
            "Little Habit Tracker": [.chinese: "TickDay", .english: "TickDay"],
            "TickDay": [.chinese: "TickDay", .english: "TickDay"],
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
            "Weekly View": [.chinese: "周视图", .english: "Weekly View"],
            "Monthly View": [.chinese: "月视图", .english: "Monthly View"],
            "Yearly View": [.chinese: "年视图", .english: "Yearly View"],
            "All View": [.chinese: "全部视图", .english: "All View"],
            "times": [.chinese: "次", .english: "times"],
            "Delete Habit?": [.chinese: "确认删除?", .english: "Delete Habit?"],
            "Saved to Album": [.chinese: "已保存到相册", .english: "Saved to Album"],
            "OK": [.chinese: "好的", .english: "OK"],
            "Tap '+' in top left, search 'Little Habit', and tap 'Add Widget'.": [.chinese: "点击左上角的“+”按钮，搜索“Little Habit”，点击“添加小组件”按钮", .english: "Tap '+' in top left, search 'Little Habit', and tap 'Add Widget'."],
            "Choose your favorite widget size and place it on your Home Screen.": [.chinese: "选择合适的小组件样式并放置到主屏幕上", .english: "Choose your favorite widget size and place it on your Home Screen."],
            "Basic Info": [.chinese: "基本信息", .english: "Basic Info"],
            "Goal Rules": [.chinese: "目标规则", .english: "Goal Rules"],
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
            "Developer (Test Only)": [.chinese: "开发者 (仅供测试)", .english: "Developer (Test Only)"],
            "Mock Premium Status": [.chinese: "模拟高级版状态", .english: "Mock Premium Status"],
            "Little Habit Premium": [.chinese: "TickDay 高级版", .english: "TickDay Premium"],
            "Unlock your full potential": [.chinese: "解锁所有特权与功能", .english: "Unlock your full potential"],
            "Theme Colors": [.chinese: "自定义主题", .english: "Theme Colors"],
            "Personalize your app with custom colors": [.chinese: "丰富的主题色彩个性化你的应用", .english: "Personalize your app with custom colors"],
            "Dark Mode": [.chinese: "深色模式", .english: "Dark Mode"],
            "Reduce eye strain with a sleek dark theme": [.chinese: "时尚的深色主题，缓解眼睛疲劳", .english: "Reduce eye strain with a sleek dark theme"],
            "Protect your habits with Face ID / Touch ID": [.chinese: "使用 Face ID 或 Touch ID 保护你的隐私", .english: "Protect your habits with Face ID / Touch ID"],
            "Unlimited Habits": [.chinese: "无限习惯", .english: "Unlimited Habits"],
            "Create as many habits as you want": [.chinese: "突破限制，创建任意数量的习惯（免费版最多5个）", .english: "Create as many habits as you want (Free version max 5)"],
            "Import / Export Data": [.chinese: "导入 / 导出数据", .english: "Import / Export Data"],
            "Backup to Excel & Import": [.chinese: "备份到 Excel 文件，并支持导入其他 app 打卡记录", .english: "Backup to Excel & import from other apps"],
            "Keep your habits synced across all devices": [.chinese: "让你的习惯在所有设备上保持同步", .english: "Keep your habits synced across all devices"],
            "Billed monthly": [.chinese: "按月扣款", .english: "Billed monthly"],
            "Billed yearly": [.chinese: "按年扣款", .english: "Billed yearly"],
            "15 天免费试用，结束后按 ¥29.9/年收费": [.chinese: "15 天免费试用，结束后按 ¥29.9/年收费", .english: "15-day free trial, then ¥29.9/year"],
            "试用期间可以随时取消，不扣费": [.chinese: "试用期间可以随时取消，不扣费", .english: "Cancel anytime during trial, no charge"],
            "POPULAR": [.chinese: "最受欢迎", .english: "POPULAR"],
            "Lifetime": [.chinese: "终身买断", .english: "Lifetime"],
            "Limited Time Offer": [.chinese: "限时特惠", .english: "Limited Time Offer"],
            "One-time payment": [.chinese: "一次性买断", .english: "One-time payment"],
            "BEST VALUE": [.chinese: "最超值", .english: "BEST VALUE"],
            "Continue": [.chinese: "继续", .english: "Continue"],
            "By continuing, you agree to our": [.chinese: "继续即表示您同意我们的", .english: "By continuing, you agree to our"],
            "and": [.chinese: "和", .english: "and"],
            "App Lock": [.chinese: "应用锁", .english: "App Lock"],
            "Data": [.chinese: "数据", .english: "Data"],
            "iCloud Sync": [.chinese: "iCloud 同步", .english: "iCloud Sync"],
            "Import Data": [.chinese: "导入数据", .english: "Import Data"],
            "Export Data": [.chinese: "导出数据", .english: "Export Data"],
            "Export Excel Data": [.chinese: "导出数据", .english: "Export Data"],
            "导出成功！": [.chinese: "导出成功！", .english: "Export Successful!"],
            "Export Successful!": [.chinese: "导出成功！", .english: "Export Successful!"],
            "Terms of Service": [.chinese: "使用条款", .english: "Terms of Service"],
            "Privacy Policy": [.chinese: "隐私政策", .english: "Privacy Policy"],
            "On": [.chinese: "开启", .english: "On"],
            "Off": [.chinese: "关闭", .english: "Off"],
            "Upgrade to Premium": [.chinese: "升级至高级版", .english: "Upgrade to Premium"],
            "Unlock all features": [.chinese: "解锁全部特权与功能", .english: "Unlock all features"],
            "Premium Member": [.chinese: "高级版会员", .english: "Premium Member"],
            "All features unlocked": [.chinese: "已解锁全部特权与功能", .english: "All features unlocked"],

            "Archived Habits": [.chinese: "已归档习惯", .english: "Archived Habits"],
            "Show Archived": [.chinese: "显示归档", .english: "Show Archived"],
            "No archived habits.": [.chinese: "暂无已归档的习惯。", .english: "No archived habits."],
            "This action will permanently delete this habit and all its check-in records. It cannot be recovered.": [.chinese: "此操作将永久删除该习惯及其所有打卡记录，且不可恢复。", .english: "This action will permanently delete this habit and all its check-in records. It cannot be recovered."],
            "This Session": [.chinese: "本次", .english: "This Session"],
            "Undo Check-in?": [.chinese: "撤销打卡？", .english: "Undo Check-in?"],
            "Undo": [.chinese: "撤销打卡", .english: "Undo"],
            "Share": [.chinese: "分享", .english: "Share"],
            "Save": [.chinese: "保存", .english: "Save"],
            "Saved to Photos": [.chinese: "已保存到相册", .english: "Saved to Photos"],
            "Check-in Success": [.chinese: "打卡成功", .english: "Check-in Success"],
            "W:": [.chinese: "周：", .english: "W:"],
            "M:": [.chinese: "月：", .english: "M:"],
            
            // Notification & Reminder
            "打卡提醒": [.chinese: "打卡提醒", .english: "Reminder"],
            "提醒时间": [.chinese: "提醒时间", .english: "Time"],
            "自定义文案": [.chinese: "自定义文案", .english: "Custom Message"],
            "该打卡啦！坚持就是胜利～": [.chinese: "该打卡啦！坚持就是胜利～", .english: "Time to check in! Keep it up~"],
            "未开启提醒": [.chinese: "未开启提醒", .english: "Reminder Disabled"],
            
            // StoreKit & Paywall
            "恢复购买成功": [.chinese: "恢复购买成功", .english: "Restore Successful"],
            "没有可恢复的购买项": [.chinese: "没有可恢复的购买项", .english: "No Purchases to Restore"],
            "获取产品列表失败：": [.chinese: "获取产品列表失败：", .english: "Failed to fetch products: "],
            "正在购买...": [.chinese: "正在购买...", .english: "Purchasing..."],
            "恢复中...": [.chinese: "恢复中...", .english: "Restoring..."],
            "购买成功！": [.chinese: "购买成功！", .english: "Purchase Successful!"],
            "购买被取消": [.chinese: "购买被取消", .english: "Purchase Cancelled"],
            "购买失败": [.chinese: "购买失败", .english: "Purchase Failed"],
            "恢复购买": [.chinese: "恢复购买", .english: "Restore Purchases"],
            "TickDay 尊享会员": [.chinese: "TickDay 尊享会员", .english: "TickDay Premium Member"],
            "您已是尊享会员": [.chinese: "您已是尊享会员", .english: "You are a Premium Member"],
            "到期时间：永久有效 (终身会员)": [.chinese: "到期时间：永久有效 (终身会员)", .english: "Valid until: Lifetime Access"],
            "状态：已激活尊享会员": [.chinese: "状态：已激活尊享会员", .english: "Status: Active Premium"],
            "到期时间：": [.chinese: "到期时间：", .english: "Valid until: "],
            "无法从 App Store 获取产品价格与配置，请检查网络连接或确认苹果后台产品已生效。": [.chinese: "无法从 App Store 获取产品价格与配置，请检查网络连接或确认苹果后台产品已生效。", .english: "Unable to fetch product pricing from App Store. Please check network or App Store Connect status."],
            "按月扣费": [.chinese: "按月扣费", .english: "Billed monthly"],
            "按年扣费": [.chinese: "按年扣费", .english: "Billed yearly"],
            "一次性付费": [.chinese: "一次性付费", .english: "One-time payment"],
            "提示": [.chinese: "提示", .english: "Notice"],
            "确定": [.chinese: "确定", .english: "OK"],
            "无法从苹果后台获取订阅价格，当前显示默认参考价。请检查：1) 苹果后台内购项目状态不为“缺少元数据”；2) App Store Connect 付费协议已生效；3) 产品 ID 匹配。": [.chinese: "无法从苹果后台获取订阅价格，当前显示默认参考价。请检查：1) 苹果后台内购项目状态不为“缺少元数据”；2) App Store Connect 付费协议已生效；3) 产品 ID 匹配。", .english: "Unable to fetch subscription pricing from App Store Connect. Showing default reference prices. Please check: 1) In-App Purchase status is not 'Missing Metadata'; 2) Paid Applications Agreement is Active; 3) Product IDs match exactly."],
            "一键生成今年模拟打卡数据": [.chinese: "一键生成今年模拟打卡数据", .english: "Generate Mock Data for This Year"],
            "为现有习惯随机填充今年打卡与情绪记录": [.chinese: "为现有习惯随机填充今年打卡与情绪记录", .english: "Populate realistic 2026 check-ins and mood records"],
            "已为所有习惯成功生成今年全套模拟打卡与情绪数据！": [.chinese: "已为所有习惯成功生成今年全套模拟打卡与情绪数据！", .english: "Successfully generated mock check-ins & mood records for this year!"],
            
            // CloudKit & Sync
            "iCloud 账号正常连接": [.chinese: "iCloud 账号正常连接", .english: "iCloud Connected"],
            "未登录，请在系统设置中登录您的 Apple ID": [.chinese: "未登录，请在系统设置中登录您的 Apple ID", .english: "Not logged in. Please sign in to iCloud in Settings."],
            "iCloud 访问受限": [.chinese: "iCloud 访问受限", .english: "iCloud Access Restricted"],
            "无法确定 iCloud 状态": [.chinese: "无法确定 iCloud 状态", .english: "Could Not Determine iCloud Status"],
            "iCloud 服务暂不可用": [.chinese: "iCloud 服务暂不可用", .english: "iCloud Temporarily Unavailable"],
            "未知状态": [.chinese: "未知状态", .english: "Unknown Status"],
            "iCloud 状态": [.chinese: "iCloud 状态", .english: "iCloud Status"],
            "立即检查同步": [.chinese: "立即检查同步", .english: "Check Sync Now"],
            "状态检查中...": [.chinese: "状态检查中...", .english: "Checking Status..."],
            "数据已完全保存在本地数据库，支持极速离线读取与打卡。开启 iCloud 仅在后台同步备份，关闭不会丢失任何本地已有记录，重新连接后自动增量双向合并。": [.chinese: "数据已完全保存在本地数据库，支持极速离线读取与打卡。开启 iCloud 仅在后台同步备份，关闭不会丢失任何本地已有记录，重新连接后自动增量双向合并。", .english: "Data is fully stored locally for instant offline access. Enabling iCloud backs up in background; disabling preserves all local records. Reconnecting merges offline updates automatically."],
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
        guard let groupURL = FileManager.default.containerURL(forSecurityApplicationGroupIdentifier: "group.com.littlehabit.tracker") else {
            print("LittleHabitTrackerApp: App Group container URL is nil! Using fallback.")
            return getAppGroupModelContainer()
        }
        let sharedStoreURL = groupURL.appendingPathComponent("shared.store")
        
        // Data Migration: move from old default.store to shared App Group store
        let defaultURL = URL.applicationSupportDirectory.appending(path: "default.store")
        let fileManager = FileManager.default
        
        let hasMigrated = UserDefaults.standard.bool(forKey: "didMigrateToAppGroup2")
        if !hasMigrated && fileManager.fileExists(atPath: defaultURL.path) {
            do {
                if fileManager.fileExists(atPath: sharedStoreURL.path) {
                    try fileManager.removeItem(at: sharedStoreURL)
                }
                try fileManager.copyItem(at: defaultURL, to: sharedStoreURL)
                
                let defaultShmURL = URL.applicationSupportDirectory.appending(path: "default.store-shm")
                let sharedShmURL = groupURL.appendingPathComponent("shared.store-shm")
                if fileManager.fileExists(atPath: sharedShmURL.path) { try fileManager.removeItem(at: sharedShmURL) }
                if fileManager.fileExists(atPath: defaultShmURL.path) {
                    try fileManager.copyItem(at: defaultShmURL, to: sharedShmURL)
                }
                
                let defaultWalURL = URL.applicationSupportDirectory.appending(path: "default.store-wal")
                let sharedWalURL = groupURL.appendingPathComponent("shared.store-wal")
                if fileManager.fileExists(atPath: sharedWalURL.path) { try fileManager.removeItem(at: sharedWalURL) }
                if fileManager.fileExists(atPath: defaultWalURL.path) {
                    try fileManager.copyItem(at: defaultWalURL, to: sharedWalURL)
                }
                UserDefaults.standard.set(true, forKey: "didMigrateToAppGroup2")
                print("Successfully migrated SwiftData to App Group container.")
            } catch {
                print("Migration failed: \(error)")
            }
        }
        return getAppGroupModelContainer()
    }()

    @StateObject private var appSettings = AppSettings()

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(appSettings)
                .environment(\.locale, appSettings.locale ?? Locale.current)
                .preferredColorScheme(appSettings.colorScheme)
                
                
        }
        .modelContainer(sharedModelContainer)
    }
}

import AppIntents

struct LittleHabitAppShortcuts: AppShortcutsProvider {
    static var appShortcuts: [AppShortcut] {
        return [
            AppShortcut(
                intent: CheckinHabitIntent(habitId: ""),
                phrases: ["Check in habit in \(.applicationName)"],
                shortTitle: "Check in Habit",
                systemImageName: "checkmark.circle.fill"
            )
        ]
    }
}
