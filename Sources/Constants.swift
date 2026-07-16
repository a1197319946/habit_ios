import Foundation
import SwiftUI

struct Constants {
    static let allColors: [String] = [
        // Page 1: Vibrant Rainbow
        "#FF3B30", "#FF9500", "#FFCC00", "#34C759", "#00C7BE", "#32ADE6",
        "#007AFF", "#5856D6", "#AF52DE", "#FF2D55", "#FF453A", "#FF9F0A",
        "#FFD60A", "#32D74B", "#64D2FF", "#0A84FF", "#BF5AF2", "#FF375F",

        // Page 2: Macaron & Medium Soft
        "#FF6B6B", "#FFA069", "#FFD166", "#06D6A0", "#48CAE4", "#9D4EDD",
        "#F15BB5", "#F77F00", "#E9C46A", "#2A9D8F", "#00B4D8", "#8338EC",
        "#EF476F", "#F4A261", "#8AB4F8", "#2EC4B6", "#4DA8DA", "#7209B7",

        // Page 3: Jewel Tones (Rich & Saturated)
        "#C62828", "#AD1457", "#6A1B9A", "#4527A0", "#283593", "#1565C0",
        "#0277BD", "#00838F", "#00695C", "#2E7D32", "#558B2F", "#9E9D24",
        "#F9A825", "#FF8F00", "#EF6C00", "#D84315", "#4E342E", "#37474F",

        // Page 4: Natural & Muted (Earth & Morandi)
        "#D4A373", "#CCD5AE", "#C8D5B9", "#E2C4A5", "#81B29A", "#F28482",
        "#E07A5F", "#3D405B", "#A8DADC", "#457B9D", "#1D3557", "#6A4C93",
        "#CB997E", "#DDBEA9", "#9B9B7A", "#B7B7A4", "#A5A58D", "#6B705C"
    ]
    
    static let allIcons: [String] = [
        // Page 1: Fitness & Sports
        "figure.run", "figure.walk", "figure.pool.swim", "figure.dance", "figure.gymnastics", "figure.martial.arts",
        "figure.badminton", "figure.tennis", "figure.basketball", "figure.volleyball", "figure.soccer", "figure.hiking",
        "figure.core.training", "figure.strengthtraining.traditional", "dumbbell.fill", "sportscourt.fill", "trophy.fill", "medal.fill",

        // Page 2: Health, Mind & Body
        "heart.fill", "cross.case.fill", "pills.fill", "bandage.fill", "brain.head.profile", "lungs.fill",
        "eye.fill", "figure.yoga", "figure.mind.and.body", "waterbottle.fill", "drop.fill", "flame.fill",
        "bed.double.fill", "moon.fill", "zzz", "sun.max.fill", "leaf.fill", "carrot.fill",

        // Page 3: Productivity, Learning & Hobbies
        "book.fill", "books.vertical.fill", "magazine.fill", "graduationcap.fill", "macwindow", "laptopcomputer",
        "pencil", "highlighter", "scissors", "paintbrush.fill", "paintpalette.fill", "hammer.fill",
        "clock.fill", "alarm.fill", "timer", "stopwatch.fill", "bell.fill", "gamecontroller.fill",

        // Page 4: Food, Lifestyle & Finance
        "cup.and.saucer.fill", "mug.fill", "fork.knife", "wineglass.fill", "birthday.cake.fill", "applelogo",
        "tv.fill", "headphones", "music.note", "guitars.fill", "camera.fill", "photo.fill",
        "cart.fill", "bag.fill", "creditcard.fill", "banknote.fill", "dollarsign.circle.fill", "gift.fill",

        // Page 5: Travel, Transport & Misc
        "airplane", "car.fill", "bus.fill", "tram.fill", "scooter", "bicycle",
        "suitcase.fill", "map.fill", "globe.americas.fill", "tent.fill", "mountain.2.fill", "pawprint.fill",
        "tree.fill", "bird.fill", "fish.fill", "house.fill", "star.fill", "sparkles"
    ]
}

import Foundation

enum AppLanguage: String, CaseIterable, Identifiable {
    case system = "system"
    case english = "en"
    case chinese = "zh"
    var id: String { self.rawValue }
    
    var displayName: String {
        switch self {
        case .system: return L10n.system.tr(.system) // Assuming system uses English fallback or similar. It's tricky to pass language here, wait!
        case .english: return "English"
        case .chinese: return "中文"
        }
    }
}

enum L10n {
    static let smallStepsBigChanges = "\"Small steps, big changes.\""
    static let home = "Home"
    static let habits = "Habits"
    static let stats = "Stats"
    static let profile = "Profile"
    static let manageHabits = "Manage Habits"
    static let youHave = "You have "
    static let habits1 = " habits."
    static let goodMorning = "Good Morning."
    static let hereIsYourFocusForToday = "Here is your focus for today."
    static let daily = "Daily"
    static let progress = "Progress"
    static let goal = "Goal"
    static let whatDoYouWantToBuild = "What do you want to build?"
    static let eGRead10PagesDrinkWater = "e.g. Read 10 pages, Drink water..."
    static let themeColor = "Theme Color"
    static let chooseAnIcon = "Choose an Icon"
    static let goalType = "Goal Type"
    static let frequency = "Frequency"
    static let totalAmount = "Total Amount"
    static let targetPerWeek = "Target (per week)"
    static let targetAmountPerWeek = "Target Amount (per week)"
    static let times = "Times"
    static let createHabit = "Create Habit"
    static let saveChanges = "Save Changes"
    static let creating = "Creating..."
    static let perWeek = "Per Week"
    static let perMonth = "Per Month"
    static let weeklyTarget = "Weekly Target"
    static let monthlyTarget = "Monthly Target"
    static let weeklyTargetAmount = "Weekly Target Amount"
    static let monthlyTargetAmount = "Monthly Target Amount"
    static let language = "Language / 多语言"
    static let shareWithFriends = "Share with Friends"
    static let moodHistory = "Mood History"
    static let feedback = "Feedback"
    static let about = "About"
    static let contactSupport = "Contact Support"
    static let tapToSetName = "Tap to set name"
    static let exploringMindfulnessAndBuildingBetterHabitsOneDayAtATime = "Exploring mindfulness and building better habits, one day at a time."
    static let noHabitsYet = "No habits yet"
    static let clickTheButtonToAddYourFirstHabit = "Click the + button to add your first habit"
    static let pending = "Pending"
    static let completed = "Completed"
    static let noMomentsRecordedYet = "No moments recorded yet."
    static let yourJourney = "Your Journey"
    static let aReflectiveLookBackAtYourMoodsAndMoments = "A reflective look back at your moods and moments."
    static let checkIn = "Check in"
    static let edit = "Edit"
    static let checkIn1 = "Check In"
    static let targetAchieved = "Target Achieved!"
    static let newHabit = "New Habit"
    static let editHabit = "Edit Habit"
    static let recordMood = "Record Mood"
    static let currentMood = "Current Mood"
    static let thoughtsOptional = "Thoughts (Optional)"
    static let writeDownYourThoughts = "Write down your thoughts..."
    static let imageOptional = "Image (Optional)"
    static let addImage = "Add Image"
    static let save = "Save"
    static let excited = "Excited"
    static let happy = "Happy"
    static let normal = "Normal"
    static let down = "Down"
    static let angry = "Angry"
    static let redeemOfferCode = "Redeem Offer Code"
    static let trackYourDailyProgress = "Track your daily progress"
    static let generateSharingImage = "Generate Sharing Image"
    static let km = "km"
    static let m = "m"
    static let mins = "mins"
    static let hours = "hours"
    static let times1 = "times"
    static let pages = "pages"
    static let days = "days"
    static let week = "week"
    static let thisWeek = "This Week"
    static let thisMonth = "This Month"
    static let weeklyTarget1 = "Weekly Target"
    static let monthlyTarget1 = "Monthly Target"
    static let month = "month"
    static let appLocked = "App Locked"
    static let unlock = "Unlock"
    static let unlockTickday = "Unlock TickDay"
    static let restore = "Restore"
    static let monthlyCard = "Monthly Card"
    static let yearlyCard = "Yearly Card"
    static let lifetimeCard = "Lifetime Card"
    static let startFreeTrial = "Start Free Trial"
    static let purchaseNow = "Purchase Now"
    static let waitASpecialOffer = "Wait, a special offer!"
    static let claimYearlyDiscount = "Claim Yearly Discount"
    static let noThanks = "No, thanks"
    static let cancelAnytimeDuringTrial = "Cancel anytime during trial"
    static let adFreeExperience = "Ad-Free Experience"
    static let reduceTheResistanceToYourDailyHabits = "Reduce the resistance to your daily habits."
    static let enterData = "Enter Data"
    static let editData = "Edit Data"
    static let periodTarget = "Period Target: "
    static let periodTotal = "Period Total: "
    static let amountCompleted = "Amount Completed"
    static let undoCheckIn = "Undo Check-in"
    static let editAmount = "Edit Amount"
    static let total = " Total"
    static let achieved = " Achieved!"
    static let options = "Options"
    static let checkInSuccessful = "Check-in Successful"
    static let hideArchived = "Hide Archived"
    static let statisticsOverview = "Statistics Overview"
    static let firstMonthFree = "First Month Free"
    static let habitName = "Habit Name"
    static let colorAndIcon = "Color and Icon"
    static let color = "Color"
    static let icon = "Icon"
    static let chooseAnIcon1 = "Choose an Icon"
    static let goalRules = "Goal Rules"
    static let times2 = " Times"
    static let month1 = " Month"
    static let year = " Year"
    static let target = "Target: "
    static let timesWeek = " Times/Week"
    static let statistics = "Statistics"
    static let yearlyCalendar = "Yearly Calendar"
    static let dataIrrecoverableAfterDeletion = "Data irrecoverable after deletion."
    static let checkInDays = "Check-in Days"
    static let checkInAmount = "Check-in Amount"
    static let checkInRecords = "Check-in Records"
    static let noCheckInRecords = "No check-in records"
    static let noCheckInsOnThisDay = "No check-ins on this day"
    static let noData = "No data"
    static let noDataForThisWeek = "No data for this week."
    static let beautifulChangesBeginToday = "Beautiful changes begin today"
    static let letSCreateYourFirstHabit = "Let's create your first habit"
    static let createFirstHabit = "Create First Habit"
    static let helpSupport = "Help & Support"
    static let habitDetails = "Habit Details"
    static let redeemOfferCode1 = "Redeem Offer Code"
    static let notificationPermissionRequired = "Notification Permission Required"
    static let youHaveDeniedNotificationPermissionsToReceiveCheckInRemindersPleaseEnableThemInSettings = "You have denied notification permissions. To receive check-in reminders, please enable them in Settings."
    static let goToSettings = "Go to Settings"
    static let features = "Features"
    static let widgets = "Widgets"
    static let addToHomeScreen = "Add to Home Screen"
    static let howToAddWidgets = "How to add Widgets"
    static let goToYourHomeScreen = "Go to your Home Screen."
    static let longPressAnyEmptySpaceUntilAppsJiggle = "Long press any empty space until apps jiggle."
    static let tapTheButtonInTheTopLeftCorner = "Tap the '+' button in the top left corner."
    static let searchForTickdayAndAddYourFavoriteWidget = "Search for 'TickDay' and add your favorite widget."
    static let gotIt = "Got it"
    static let frequencyGoal = "Frequency Goal"
    static let amountGoal = "Amount Goal"
    static let totalAmount1 = "Total Amount"
    static let monthlyTrend = "Monthly Trend"
    static let monthlyDetails = "Monthly Details"
    static let checkInDaysTrend = "Check-in Days Trend"
    static let totalAmountTrend = "Total Amount Trend"
    static let totalDays = "Total Days"
    static let system = "System"
    static let light = "Light"
    static let dark = "Dark"
    static let appearance = "Appearance"
    static let startOfWeek = "Start of Week"
    static let monday = "Monday"
    static let sunday = "Sunday"
    static let cancel = "Cancel"
    static let close = "Close"
    static let showCompleted = "Show Completed"
    static let hideCompleted = "Hide Completed"
    static let week1 = "Week"
    static let times3 = " times"
    static let time = " time"
    static let generating = "Generating..."
    static let today = "Today"
    static let total1 = "Total"
    static let tickday = "TickDay"
    static let today1 = "Today,"
    static let yesterday = "Yesterday,"
    static let normal1 = "Normal"
    static let down1 = "Down"
    static let angry1 = "Angry"
    static let reports = "Reports"
    static let met = "Met"
    static let bestDay = "Best Day"
    static let longestStreak = "Longest Streak"
    static let done = "Done"
    static let streak = "Streak"
    static let weeklyGrid = "Weekly Grid"
    static let yourProgress = "Your Progress"
    static let aDetailedLookAtYourJourney = "A detailed look at your journey."
    static let month2 = "Month"
    static let year1 = "Year"
    static let weekly = "Weekly"
    static let monthly = "Monthly"
    static let yearly = "Yearly"
    static let all = "All"
    static let weeklyView = "Weekly View"
    static let monthlyView = "Monthly View"
    static let yearlyView = "Yearly View"
    static let allView = "All View"
    static let deleteHabit = "Delete Habit?"
    static let savedToAlbum = "Saved to Album"
    static let ok = "OK"
    static let tapInTopLeftSearchTickdayAndTapAddWidget = "Tap '+' in top left, search 'TickDay', and tap 'Add Widget'."
    static let chooseYourFavoriteWidgetSizeAndPlaceItOnYourHomeScreen = "Choose your favorite widget size and place it on your Home Screen."
    static let basicInfo = "Basic Info"
    static let habit = "Habit"
    static let noHabitsFound = "No habits found."
    static let cumulativeStreak = "Cumulative Streak"
    static let top5 = "Top 5%"
    static let daysOfContinuousGrowth = "Days of continuous growth"
    static let consistencyMap = "Consistency Map"
    static let less = "Less"
    static let more = "More"
    static let habitDistribution = "Habit Distribution"
    static let mind = "Mind"
    static let body = "Body"
    static let soul = "Soul"
    static let mon = "Mon"
    static let tue = "Tue"
    static let wed = "Wed"
    static let thu = "Thu"
    static let fri = "Fri"
    static let sat = "Sat"
    static let sun = "Sun"
    static let daysStreak = "Days Streak"
    static let _30Days = "30 Days"
    static let delete = "Delete"
    static let archive = "Archive"
    static let restore1 = "Restore"
    static let settings = "Settings"
    static let developerTestOnly = "Developer (Test Only)"
    static let mockPremiumStatus = "Mock Premium Status"
    static let tickdayPremium = "TickDay Premium"
    static let unlockYourFullPotential = "Unlock your full potential"
    static let themeColors = "Theme Colors"
    static let personalizeYourAppWithCustomColors = "Personalize your app with custom colors"
    static let darkMode = "Dark Mode"
    static let reduceEyeStrainWithASleekDarkTheme = "Reduce eye strain with a sleek dark theme"
    static let protectYourHabitsWithFaceIdTouchId = "Protect your habits with Face ID / Touch ID"
    static let unlimitedHabits = "Unlimited Habits"
    static let createAsManyHabitsAsYouWantFreeVersionMax5 = "Create as many habits as you want (Free version max 5)"
    static let importExportData = "Import / Export Data"
    static let backupToExcelImportFromOtherApps = "Backup to Excel & import from other apps"
    static let keepYourHabitsSyncedAcrossAllDevices = "Keep your habits synced across all devices"
    static let billedMonthly = "Billed monthly"
    static let billedYearly = "Billed yearly"
    static let cancelAnytimeDuringTrialNoCharge = "Cancel anytime during trial, no charge"
    static let popular = "POPULAR"
    static let lifetime = "Lifetime"
    static let limitedTimeOffer = "Limited Time Offer"
    static let oneTimePayment = "One-time payment"
    static let bestValue = "BEST VALUE"
    static let `continue` = "Continue"
    static let byContinuingYouAgreeToOur = "By continuing, you agree to our"
    static let and = "and"
    static let appLock = "App Lock"
    static let data = "Data"
    static let icloudSync = "iCloud Sync"
    static let importData = "Import Data"
    static let exportData = "Export Data"
    static let exportSuccessful = "Export Successful!"
    static let termsOfService = "Terms of Service"
    static let privacyPolicy = "Privacy Policy"
    static let on = "On"
    static let off = "Off"
    static let upgradeToPremium = "Upgrade to Premium"
    static let unlockAllFeatures = "Unlock all features"
    static let premiumMember = "Premium Member"
    static let allFeaturesUnlocked = "All features unlocked"
    static let archivedHabits = "Archived Habits"
    static let showArchived = "Show Archived"
    static let noArchivedHabits = "No archived habits."
    static let thisActionWillPermanentlyDeleteThisHabitAndAllItsCheckInRecordsItCannotBeRecovered = "This action will permanently delete this habit and all its check-in records. It cannot be recovered."
    static let thisSession = "This Session"
    static let undoCheckIn1 = "Undo Check-in?"
    static let undo = "Undo"
    static let share = "Share"
    static let save1 = "Save"
    static let savedToPhotos = "Saved to Photos"
    static let checkInSuccess = "Check-in Success"
    static let w = "W:"
    static let m1 = "M:"
    static let reminder = "Reminder"
    static let time1 = "Time"
    static let customMessage = "Custom Message"
    static let timeToCheckInKeepItUp = "Time to check in! Keep it up~"
    static let reminderDisabled = "Reminder Disabled"
    static let restoreSuccessful = "Restore Successful"
    static let noPurchasesToRestore = "No Purchases to Restore"
    static let failedToFetchProducts = "Failed to fetch products: "
    static let purchasing = "Purchasing..."
    static let restoring = "Restoring..."
    static let purchaseSuccessful = "Purchase Successful!"
    static let purchaseCancelled = "Purchase Cancelled"
    static let purchaseFailed = "Purchase Failed"
    static let restorePurchases = "Restore Purchases"
    static let tickdayPremiumMember = "TickDay Premium Member"
    static let youAreAPremiumMember = "You are a Premium Member"
    static let validUntilLifetimeAccess = "Valid until: Lifetime Access"
    static let statusActivePremium = "Status: Active Premium"
    static let validUntil = "Valid until: "
    static let unableToFetchProductPricingFromAppStorePleaseCheckNetworkOrAppStoreConnectStatus = "Unable to fetch product pricing from App Store. Please check network or App Store Connect status."
    static let billedMonthly1 = "Billed monthly"
    static let billedYearly1 = "Billed yearly"
    static let oneTimePayment1 = "One-time payment"
    static let autoRenewablePriceCancelAnytime = "Auto-renewable, {price}, cancel anytime"
    static let firstMonthFreeThenPrice = "First month free, then {price}"
    static let oneTimePaymentLifetimeAccessToAllFeatures = "One-time payment, lifetime access to all features"
    static let paymentWillBeChargedToYourItunesAccountAtConfirmationOfPurchaseSubscriptionAutomaticallyRenewsUnlessAutoRenewIsTurnedOffAtLeast24HoursBeforeTheEndOfTheCurrentPeriodAccountWillBeChargedForRenewalWithin24HoursPriorToTheEndOfTheCurrentPeriodYouCanManageAndCancelYourSubscriptionsInYourAppStoreAccountSettings = "Payment will be charged to your iTunes account at confirmation of purchase. Subscription automatically renews unless auto-renew is turned off at least 24-hours before the end of the current period. Account will be charged for renewal within 24-hours prior to the end of the current period. You can manage and cancel your subscriptions in your App Store account settings."
    static let notice = "Notice"
    static let ok1 = "OK"
    static let unableToFetchSubscriptionPricingFromAppStoreConnectShowingDefaultReferencePricesPleaseCheck1InAppPurchaseStatusIsNotMissingMetadata2PaidApplicationsAgreementIsActive3ProductIdsMatchExactly = "Unable to fetch subscription pricing from App Store Connect. Showing default reference prices. Please check: 1) In-App Purchase status is not 'Missing Metadata'; 2) Paid Applications Agreement is Active; 3) Product IDs match exactly."
    static let generateMockDataForThisYear = "Generate Mock Data for This Year"
    static let populateRealistic2026CheckInsAndMoodRecords = "Populate realistic 2026 check-ins and mood records"
    static let successfullyGeneratedMockCheckInsMoodRecordsForThisYear = "Successfully generated mock check-ins & mood records for this year!"
    static let icloudConnected = "iCloud Connected"
    static let notLoggedInPleaseSignInToIcloudInSettings = "Not logged in. Please sign in to iCloud in Settings."
    static let icloudAccessRestricted = "iCloud Access Restricted"
    static let couldNotDetermineIcloudStatus = "Could Not Determine iCloud Status"
    static let icloudTemporarilyUnavailable = "iCloud Temporarily Unavailable"
    static let unknownStatus = "Unknown Status"
    static let icloudStatus = "iCloud Status"
    static let checkSyncNow = "Check Sync Now"
    static let checkingStatus = "Checking Status..."
    static let dataIsFullyStoredLocallyForInstantOfflineAccessEnablingIcloudBacksUpInBackgroundDisablingPreservesAllLocalRecordsReconnectingMergesOfflineUpdatesAutomatically = "Data is fully stored locally for instant offline access. Enabling iCloud backs up in background; disabling preserves all local records. Reconnecting merges offline updates automatically."
    static let noHabit = "No Habit"
    static let selectHabits = "Select Habits"
    static let pleaseLongPressToEditSelectHabit = "Please long press to edit & select habit"
    static let thisWeek1 = "This week"
    static let thisMonth1 = "This month"
    static let week2 = "Week"
    static let month3 = "Month"
    static let year2 = "Year"
}

extension String {
    static let translations: [String: [AppLanguage: String]] = [
        L10n.smallStepsBigChanges: [.chinese: "\"不积跬步，无以至千里。\"", .english: "\"Small steps, big changes.\""],
        L10n.home: [.chinese: "首页", .english: "Home"],
        L10n.habits: [.chinese: "习惯", .english: "Habits"],
        L10n.stats: [.chinese: "统计", .english: "Stats"],
        L10n.profile: [.chinese: "我的", .english: "Profile"],
        L10n.manageHabits: [.chinese: "管理习惯", .english: "Manage Habits"],
        L10n.youHave: [.chinese: "你当前有 ", .english: "You have "],
        L10n.habits1: [.chinese: " 个习惯。", .english: " habits."],
        L10n.goodMorning: [.chinese: "早上好。", .english: "Good Morning."],
        L10n.hereIsYourFocusForToday: [.chinese: "这是你今天的目标。", .english: "Here is your focus for today."],
        L10n.daily: [.chinese: "每天", .english: "Daily"],
        L10n.progress: [.chinese: "进度", .english: "Progress"],
        L10n.goal: [.chinese: "目标", .english: "Goal"],
        L10n.whatDoYouWantToBuild: [.chinese: "你想养成什么习惯？", .english: "What do you want to build?"],
        L10n.eGRead10PagesDrinkWater: [.chinese: "例如：阅读10页、喝水...", .english: "e.g. Read 10 pages, Drink water..."],
        L10n.themeColor: [.chinese: "主题颜色", .english: "Theme Color"],
        "Pick a Theme Color": [.chinese: "主题颜色", .english: "Theme Color"],
        L10n.chooseAnIcon: [.chinese: "选择一个图标", .english: "Choose an Icon"],
        L10n.goalType: [.chinese: "目标类型", .english: "Goal Type"],
        L10n.frequency: [.chinese: "频率", .english: "Frequency"],
        L10n.totalAmount: [.chinese: "总计数量", .english: "Total Amount"],
        L10n.targetPerWeek: [.chinese: "目标 (每周)", .english: "Target (per week)"],
        L10n.targetAmountPerWeek: [.chinese: "目标数量 (每周)", .english: "Target Amount (per week)"],
        L10n.times: [.chinese: "次", .english: "Times"],
        L10n.createHabit: [.chinese: "创建习惯", .english: "Create Habit"],
        L10n.saveChanges: [.chinese: "保存修改", .english: "Save Changes"],
        L10n.creating: [.chinese: "保存中...", .english: "Creating..."],
        L10n.perWeek: [.chinese: "按周", .english: "Per Week"],
        L10n.perMonth: [.chinese: "按月", .english: "Per Month"],
        L10n.weeklyTarget: [.chinese: "每周目标次数", .english: "Weekly Target"],
        L10n.monthlyTarget: [.chinese: "每月目标次数", .english: "Monthly Target"],
        L10n.weeklyTargetAmount: [.chinese: "每周目标总量", .english: "Weekly Target Amount"],
        L10n.monthlyTargetAmount: [.chinese: "每月目标总量", .english: "Monthly Target Amount"],
        L10n.language: [.chinese: "多语言 / Language", .english: "Language / 多语言"],
        "Language": [.chinese: "多语言 / Language", .english: "Language / 多语言"],
        L10n.shareWithFriends: [.chinese: "分享给朋友", .english: "Share with Friends"],
        L10n.moodHistory: [.chinese: "心情日记", .english: "Mood History"],
        L10n.feedback: [.chinese: "意见反馈", .english: "Feedback"],
        L10n.about: [.chinese: "关于", .english: "About"],
        L10n.contactSupport: [.chinese: "联系客服", .english: "Contact Support"],
        L10n.tapToSetName: [.chinese: "点击设置昵称", .english: "Tap to set name"],
        L10n.exploringMindfulnessAndBuildingBetterHabitsOneDayAtATime: [.chinese: "每天进步一点点。", .english: "Exploring mindfulness and building better habits, one day at a time."],
        L10n.noHabitsYet: [.chinese: "没有习惯", .english: "No habits yet"],
        L10n.clickTheButtonToAddYourFirstHabit: [.chinese: "点击进入习惯管理页添加你的第一个习惯吧", .english: "Click the + button to add your first habit"],
        L10n.pending: [.chinese: "未完成", .english: "Pending"],
        L10n.completed: [.chinese: "已完成", .english: "Completed"],
        L10n.noMomentsRecordedYet: [.chinese: "暂无心情记录。", .english: "No moments recorded yet."],
        L10n.yourJourney: [.chinese: "你的旅程", .english: "Your Journey"],
        L10n.aReflectiveLookBackAtYourMoodsAndMoments: [.chinese: "回顾你的心情与点滴时刻。", .english: "A reflective look back at your moods and moments."],
        L10n.checkIn: [.chinese: "记录", .english: "Check in"],
        L10n.edit: [.chinese: "修改", .english: "Edit"],
        L10n.checkIn1: [.chinese: "完成打卡", .english: "Check In"],
        L10n.targetAchieved: [.chinese: "目标已达成！", .english: "Target Achieved!"],
        L10n.newHabit: [.chinese: "新增习惯", .english: "New Habit"],
        L10n.editHabit: [.chinese: "编辑习惯", .english: "Edit Habit"],
        L10n.recordMood: [.chinese: "记录心情", .english: "Record Mood"],
        "记录心情": [.chinese: "记录心情", .english: "Record Mood"],
        L10n.currentMood: [.chinese: "当前心情", .english: "Current Mood"],
        "当前心情": [.chinese: "当前心情", .english: "Current Mood"],
        L10n.thoughtsOptional: [.chinese: "想法 (选填)", .english: "Thoughts (Optional)"],
        "想法 (选填)": [.chinese: "想法 (选填)", .english: "Thoughts (Optional)"],
        L10n.writeDownYourThoughts: [.chinese: "写下这一刻的想法...", .english: "Write down your thoughts..."],
        "写下这一刻的想法...": [.chinese: "写下这一刻的想法...", .english: "Write down your thoughts..."],
        L10n.imageOptional: [.chinese: "图片 (选填)", .english: "Image (Optional)"],
        "图片 (选填)": [.chinese: "图片 (选填)", .english: "Image (Optional)"],
        L10n.addImage: [.chinese: "添加图片", .english: "Add Image"],
        "添加图片": [.chinese: "添加图片", .english: "Add Image"],
        L10n.save: [.chinese: "记录", .english: "Save"],
        "记录": [.chinese: "记录", .english: "Save"],
        L10n.excited: [.chinese: "激动", .english: "Excited"],
        "激动": [.chinese: "激动", .english: "Excited"],
        "excited": [.chinese: "激动", .english: "Excited"],
        L10n.happy: [.chinese: "开心", .english: "Happy"],
        "开心": [.chinese: "开心", .english: "Happy"],
        "happy": [.chinese: "开心", .english: "Happy"],
        L10n.normal: [.chinese: "一般", .english: "Normal"],
        "一般": [.chinese: "一般", .english: "Normal"],
        L10n.down: [.chinese: "失落", .english: "Down"],
        "失落": [.chinese: "失落", .english: "Down"],
        L10n.angry: [.chinese: "愤怒", .english: "Angry"],
        "愤怒": [.chinese: "愤怒", .english: "Angry"],
        L10n.redeemOfferCode: [.chinese: "使用兑换码兑换会员", .english: "Redeem Offer Code"],
        "兑换码 / Redeem Code": [.chinese: "使用兑换码兑换会员", .english: "Redeem Offer Code"],
        L10n.trackYourDailyProgress: [.chinese: "记录你的每日进步", .english: "Track your daily progress"],
        L10n.generateSharingImage: [.chinese: "生成分享图", .english: "Generate Sharing Image"],
        L10n.km: [.chinese: "公里", .english: "km"],
        "公里": [.chinese: "公里", .english: "km"],
        L10n.m: [.chinese: "米", .english: "m"],
        "米": [.chinese: "米", .english: "m"],
        L10n.mins: [.chinese: "分钟", .english: "mins"],
        "分钟": [.chinese: "分钟", .english: "mins"],
        L10n.hours: [.chinese: "小时", .english: "hours"],
        "小时": [.chinese: "小时", .english: "hours"],
        L10n.times1: [.chinese: "次", .english: "times"],
        "次": [.chinese: "次", .english: "times"],
        L10n.pages: [.chinese: "页", .english: "pages"],
        "页": [.chinese: "页", .english: "pages"],
        L10n.days: [.chinese: "天", .english: "days"],
        "天": [.chinese: "天", .english: "days"],
        L10n.week: [.chinese: "周", .english: "week"],
        L10n.thisWeek: [.chinese: "本周", .english: "This Week"],
        L10n.thisMonth: [.chinese: "本月", .english: "This Month"],
        "周目标": [.chinese: "周目标", .english: "Weekly Target"],
        "月目标": [.chinese: "月目标", .english: "Monthly Target"],
        L10n.month: [.chinese: "月", .english: "month"],
        L10n.appLocked: [.chinese: "应用已锁定", .english: "App Locked"],
        L10n.unlock: [.chinese: "解锁", .english: "Unlock"],
        L10n.unlockTickday: [.chinese: "解锁 TickDay", .english: "Unlock TickDay"],
        "Unlock Little Habit": [.chinese: "解锁 TickDay", .english: "Unlock TickDay"],
        L10n.restore: [.chinese: "恢复购买", .english: "Restore"],
        "Restore Purchase": [.chinese: "恢复购买", .english: "Restore"],
        L10n.monthlyCard: [.chinese: "月度卡", .english: "Monthly Card"],
        L10n.yearlyCard: [.chinese: "年度卡", .english: "Yearly Card"],
        L10n.lifetimeCard: [.chinese: "终身卡", .english: "Lifetime Card"],
        L10n.startFreeTrial: [.chinese: "开始免费试用", .english: "Start Free Trial"],
        L10n.purchaseNow: [.chinese: "立即购买", .english: "Purchase Now"],
        L10n.waitASpecialOffer: [.chinese: "等一下，送您一份专属优惠！", .english: "Wait, a special offer!"],
        L10n.claimYearlyDiscount: [.chinese: "领取年度卡折扣", .english: "Claim Yearly Discount"],
        L10n.noThanks: [.chinese: "残忍拒绝", .english: "No, thanks"],
        L10n.cancelAnytimeDuringTrial: [.chinese: "试用期间随时取消", .english: "Cancel anytime during trial"],
        L10n.adFreeExperience: [.chinese: "纯净无广告", .english: "Ad-Free Experience"],
        L10n.reduceTheResistanceToYourDailyHabits: [.chinese: "降低坚持的阻力", .english: "Reduce the resistance to your daily habits."],
        L10n.enterData: [.chinese: "录入打卡数据", .english: "Enter Data"],
        L10n.editData: [.chinese: "修改打卡数据", .english: "Edit Data"],
        L10n.periodTarget: [.chinese: "本周期目标: ", .english: "Period Target: "],
        L10n.periodTotal: [.chinese: "本周期已累计: ", .english: "Period Total: "],
        L10n.amountCompleted: [.chinese: "本次完成量", .english: "Amount Completed"],
        L10n.undoCheckIn: [.chinese: "撤销打卡", .english: "Undo Check-in"],
        L10n.editAmount: [.chinese: "修改数值", .english: "Edit Amount"],
        L10n.total: [.chinese: "累计", .english: " Total"],
        L10n.achieved: [.chinese: "已达成！", .english: " Achieved!"],
        L10n.options: [.chinese: "操作", .english: "Options"],
        "Cancel Check-in?": [.chinese: "操作", .english: "Options"],
        L10n.checkInSuccessful: [.chinese: "打卡成功", .english: "Check-in Successful"],
        L10n.hideArchived: [.chinese: "隐藏归档", .english: "Hide Archived"],
        L10n.statisticsOverview: [.chinese: "统计概览", .english: "Statistics Overview"],
        "统计概览": [.chinese: "统计概览", .english: "Statistics Overview"],
        L10n.firstMonthFree: [.chinese: "首月免费", .english: "First Month Free"],
        "首月免费": [.chinese: "首月免费", .english: "First Month Free"],
        L10n.habitName: [.chinese: "习惯名称", .english: "Habit Name"],
        "习惯名称": [.chinese: "习惯名称", .english: "Habit Name"],
        L10n.colorAndIcon: [.chinese: "颜色和图标", .english: "Color and Icon"],
        "颜色和图标": [.chinese: "颜色和图标", .english: "Color and Icon"],
        L10n.color: [.chinese: "颜色", .english: "Color"],
        "颜色": [.chinese: "颜色", .english: "Color"],
        L10n.icon: [.chinese: "图标", .english: "Icon"],
        "图标": [.chinese: "图标", .english: "Icon"],
        "选择图标": [.chinese: "选择图标", .english: "Choose an Icon"],
        L10n.goalRules: [.chinese: "目标规则", .english: "Goal Rules"],
        "目标规则": [.chinese: "目标规则", .english: "Goal Rules"],
        L10n.times2: [.chinese: "次", .english: " Times"],
        L10n.month1: [.chinese: "月", .english: " Month"],
        L10n.year: [.chinese: " 年", .english: " Year"],
        L10n.target: [.chinese: "目标: ", .english: "Target: "],
        L10n.timesWeek: [.chinese: "次/周", .english: " Times/Week"],
        L10n.statistics: [.chinese: "统计数据", .english: "Statistics"],
        L10n.yearlyCalendar: [.chinese: "年度日历", .english: "Yearly Calendar"],
        L10n.dataIrrecoverableAfterDeletion: [.chinese: "删除后所有相关打卡数据将无法恢复。", .english: "Data irrecoverable after deletion."],
        L10n.checkInDays: [.chinese: "打卡天数", .english: "Check-in Days"],
        "打卡天数": [.chinese: "打卡天数", .english: "Check-in Days"],
        L10n.checkInAmount: [.chinese: "打卡数量", .english: "Check-in Amount"],
        L10n.checkInRecords: [.chinese: "打卡记录", .english: "Check-in Records"],
        L10n.noCheckInRecords: [.chinese: "暂无打卡记录", .english: "No check-in records"],
        L10n.noCheckInsOnThisDay: [.chinese: "当日无打卡记录", .english: "No check-ins on this day"],
        L10n.noData: [.chinese: "暂无数据", .english: "No data"],
        L10n.noDataForThisWeek: [.chinese: "本周暂无数据", .english: "No data for this week."],
        L10n.beautifulChangesBeginToday: [.chinese: "美好的改变，从今天开始", .english: "Beautiful changes begin today"],
        "美好的改变，从今天开始": [.chinese: "美好的改变，从今天开始", .english: "Beautiful changes begin today"],
        L10n.letSCreateYourFirstHabit: [.chinese: "开启你的第一个小习惯吧", .english: "Let's create your first habit"],
        "开启你的第一个小习惯吧": [.chinese: "开启你的第一个小习惯吧", .english: "Let's create your first habit"],
        L10n.createFirstHabit: [.chinese: "创建第一个习惯", .english: "Create First Habit"],
        "创建第一个习惯": [.chinese: "创建第一个习惯", .english: "Create First Habit"],
        L10n.helpSupport: [.chinese: "帮助与反馈", .english: "Help & Support"],
        L10n.habitDetails: [.chinese: "习惯详情", .english: "Habit Details"],
        L10n.notificationPermissionRequired: [.chinese: "需要通知权限", .english: "Notification Permission Required"],
        "需要通知权限": [.chinese: "需要通知权限", .english: "Notification Permission Required"],
        L10n.youHaveDeniedNotificationPermissionsToReceiveCheckInRemindersPleaseEnableThemInSettings: [.chinese: "您已拒绝通知权限。如需打卡提醒，请前往设置中开启。", .english: "You have denied notification permissions. To receive check-in reminders, please enable them in Settings."],
        "您已拒绝通知权限。如需打卡提醒，请前往设置中开启。": [.chinese: "您已拒绝通知权限。如需打卡提醒，请前往设置中开启。", .english: "You have denied notification permissions. To receive check-in reminders, please enable them in Settings."],
        L10n.goToSettings: [.chinese: "去设置", .english: "Go to Settings"],
        "去设置": [.chinese: "去设置", .english: "Go to Settings"],
        L10n.features: [.chinese: "功能", .english: "Features"],
        L10n.widgets: [.chinese: "小组件", .english: "Widgets"],
        L10n.addToHomeScreen: [.chinese: "添加到主屏幕", .english: "Add to Home Screen"],
        L10n.howToAddWidgets: [.chinese: "如何添加小组件", .english: "How to add Widgets"],
        L10n.goToYourHomeScreen: [.chinese: "回到手机主屏幕", .english: "Go to your Home Screen."],
        L10n.longPressAnyEmptySpaceUntilAppsJiggle: [.chinese: "长按主屏幕空白处，直到应用图标开始抖动", .english: "Long press any empty space until apps jiggle."],
        L10n.tapTheButtonInTheTopLeftCorner: [.chinese: "点击左上角的“+”按钮", .english: "Tap the '+' button in the top left corner."],
        L10n.searchForTickdayAndAddYourFavoriteWidget: [.chinese: "搜索“TickDay”，选择并添加你喜欢的小组件", .english: "Search for 'TickDay' and add your favorite widget."],
        L10n.gotIt: [.chinese: "我知道了", .english: "Got it"],
        L10n.frequencyGoal: [.chinese: "次数目标", .english: "Frequency Goal"],
        "次数目标": [.chinese: "次数目标", .english: "Frequency Goal"],
        L10n.amountGoal: [.chinese: "总量目标", .english: "Amount Goal"],
        "总量目标": [.chinese: "总量目标", .english: "Amount Goal"],
        "总数值": [.chinese: "总数值", .english: "Total Amount"],
        L10n.monthlyTrend: [.chinese: "月度趋势", .english: "Monthly Trend"],
        L10n.monthlyDetails: [.chinese: "月度详情", .english: "Monthly Details"],
        L10n.checkInDaysTrend: [.chinese: "打卡次数趋势", .english: "Check-in Days Trend"],
        L10n.totalAmountTrend: [.chinese: "打卡总量趋势", .english: "Total Amount Trend"],
        L10n.totalDays: [.chinese: "累计打卡", .english: "Total Days"],
        L10n.system: [.chinese: "系统", .english: "System"],
        L10n.light: [.chinese: "浅色", .english: "Light"],
        L10n.dark: [.chinese: "深色", .english: "Dark"],
        L10n.appearance: [.chinese: "外观", .english: "Appearance"],
        L10n.startOfWeek: [.chinese: "一周开始", .english: "Start of Week"],
        L10n.monday: [.chinese: "周一", .english: "Monday"],
        L10n.sunday: [.chinese: "周日", .english: "Sunday"],
        L10n.cancel: [.chinese: "取消", .english: "Cancel"],
        L10n.close: [.chinese: "关闭", .english: "Close"],
        L10n.showCompleted: [.chinese: "显示已打卡", .english: "Show Completed"],
        L10n.hideCompleted: [.chinese: "隐藏已打卡", .english: "Hide Completed"],
        L10n.week1: [.chinese: "本周", .english: "Week"],
        L10n.times3: [.chinese: "次", .english: " times"],
        L10n.time: [.chinese: "次", .english: " time"],
        L10n.generating: [.chinese: "生成中...", .english: "Generating..."],
        L10n.today: [.chinese: "今日", .english: "Today"],
        L10n.total1: [.chinese: "累计", .english: "Total"],
        L10n.tickday: [.chinese: "TickDay", .english: "TickDay"],
        "Little Habit Tracker": [.chinese: "TickDay", .english: "TickDay"],
        L10n.today1: [.chinese: "今天，", .english: "Today,"],
        L10n.yesterday: [.chinese: "昨天，", .english: "Yesterday,"],
        "normal": [.chinese: "平静", .english: "Normal"],
        "down": [.chinese: "低落", .english: "Down"],
        "angry": [.chinese: "生气", .english: "Angry"],
        L10n.reports: [.chinese: "报告", .english: "Reports"],
        L10n.met: [.chinese: "达成率", .english: "Met"],
        L10n.bestDay: [.chinese: "最佳单日", .english: "Best Day"],
        L10n.longestStreak: [.chinese: "最长连续", .english: "Longest Streak"],
        L10n.done: [.chinese: "打卡", .english: "Done"],
        L10n.streak: [.chinese: "连续", .english: "Streak"],
        L10n.weeklyGrid: [.chinese: "本周网格", .english: "Weekly Grid"],
        L10n.yourProgress: [.chinese: "你的进度", .english: "Your Progress"],
        L10n.aDetailedLookAtYourJourney: [.chinese: "详细回顾你的成长之旅。", .english: "A detailed look at your journey."],
        L10n.month2: [.chinese: "本月", .english: "Month"],
        L10n.year1: [.chinese: "本年", .english: "Year"],
        L10n.weekly: [.chinese: "周", .english: "Weekly"],
        L10n.monthly: [.chinese: "月", .english: "Monthly"],
        L10n.yearly: [.chinese: "年", .english: "Yearly"],
        L10n.all: [.chinese: "全部", .english: "All"],
        L10n.weeklyView: [.chinese: "周视图", .english: "Weekly View"],
        L10n.monthlyView: [.chinese: "月视图", .english: "Monthly View"],
        L10n.yearlyView: [.chinese: "年视图", .english: "Yearly View"],
        L10n.allView: [.chinese: "全部视图", .english: "All View"],
        L10n.deleteHabit: [.chinese: "确认删除?", .english: "Delete Habit?"],
        L10n.savedToAlbum: [.chinese: "已保存到相册", .english: "Saved to Album"],
        L10n.ok: [.chinese: "好的", .english: "OK"],
        L10n.tapInTopLeftSearchTickdayAndTapAddWidget: [.chinese: "点击左上角的“+”按钮，搜索“TickDay”，点击“添加小组件”按钮", .english: "Tap '+' in top left, search 'TickDay', and tap 'Add Widget'."],
        L10n.chooseYourFavoriteWidgetSizeAndPlaceItOnYourHomeScreen: [.chinese: "选择合适的小组件样式并放置到主屏幕上", .english: "Choose your favorite widget size and place it on your Home Screen."],
        L10n.basicInfo: [.chinese: "基本信息", .english: "Basic Info"],
        L10n.habit: [.chinese: "习惯", .english: "Habit"],
        L10n.noHabitsFound: [.chinese: "暂无习惯", .english: "No habits found."],
        L10n.cumulativeStreak: [.chinese: "累计连续打卡", .english: "Cumulative Streak"],
        L10n.top5: [.chinese: "前 5%", .english: "Top 5%"],
        L10n.daysOfContinuousGrowth: [.chinese: "天连续成长", .english: "Days of continuous growth"],
        L10n.consistencyMap: [.chinese: "连续性热力图", .english: "Consistency Map"],
        L10n.less: [.chinese: "少", .english: "Less"],
        L10n.more: [.chinese: "多", .english: "More"],
        L10n.habitDistribution: [.chinese: "习惯分布", .english: "Habit Distribution"],
        L10n.mind: [.chinese: "心灵", .english: "Mind"],
        L10n.body: [.chinese: "身体", .english: "Body"],
        L10n.soul: [.chinese: "灵魂", .english: "Soul"],
        L10n.mon: [.chinese: "一", .english: "Mon"],
        L10n.tue: [.chinese: "二", .english: "Tue"],
        L10n.wed: [.chinese: "三", .english: "Wed"],
        L10n.thu: [.chinese: "四", .english: "Thu"],
        L10n.fri: [.chinese: "五", .english: "Fri"],
        L10n.sat: [.chinese: "六", .english: "Sat"],
        L10n.sun: [.chinese: "日", .english: "Sun"],
        L10n.daysStreak: [.chinese: "天连续", .english: "Days Streak"],
        L10n._30Days: [.chinese: "近30天", .english: "30 Days"],
        L10n.delete: [.chinese: "删除", .english: "Delete"],
        L10n.archive: [.chinese: "归档", .english: "Archive"],
        L10n.settings: [.chinese: "设置", .english: "Settings"],
        L10n.developerTestOnly: [.chinese: "开发者 (仅供测试)", .english: "Developer (Test Only)"],
        L10n.mockPremiumStatus: [.chinese: "模拟高级版状态", .english: "Mock Premium Status"],
        L10n.tickdayPremium: [.chinese: "TickDay 高级版", .english: "TickDay Premium"],
        "Little Habit Premium": [.chinese: "TickDay 高级版", .english: "TickDay Premium"],
        L10n.unlockYourFullPotential: [.chinese: "解锁所有特权与功能", .english: "Unlock your full potential"],
        L10n.themeColors: [.chinese: "自定义主题", .english: "Theme Colors"],
        L10n.personalizeYourAppWithCustomColors: [.chinese: "丰富的主题色彩个性化你的应用", .english: "Personalize your app with custom colors"],
        L10n.darkMode: [.chinese: "深色模式", .english: "Dark Mode"],
        L10n.reduceEyeStrainWithASleekDarkTheme: [.chinese: "时尚的深色主题，缓解眼睛疲劳", .english: "Reduce eye strain with a sleek dark theme"],
        L10n.protectYourHabitsWithFaceIdTouchId: [.chinese: "使用 Face ID 或 Touch ID 保护你的隐私", .english: "Protect your habits with Face ID / Touch ID"],
        L10n.unlimitedHabits: [.chinese: "无限习惯", .english: "Unlimited Habits"],
        L10n.createAsManyHabitsAsYouWantFreeVersionMax5: [.chinese: "突破限制，创建任意数量的习惯（免费版最多5个）", .english: "Create as many habits as you want (Free version max 5)"],
        "Create as many habits as you want": [.chinese: "突破限制，创建任意数量的习惯（免费版最多5个）", .english: "Create as many habits as you want (Free version max 5)"],
        L10n.importExportData: [.chinese: "导入 / 导出数据", .english: "Import / Export Data"],
        L10n.backupToExcelImportFromOtherApps: [.chinese: "备份到 Excel 文件，并支持导入其他 app 打卡记录", .english: "Backup to Excel & import from other apps"],
        "Backup to Excel & Import": [.chinese: "备份到 Excel 文件，并支持导入其他 app 打卡记录", .english: "Backup to Excel & import from other apps"],
        L10n.keepYourHabitsSyncedAcrossAllDevices: [.chinese: "让你的习惯在所有设备上保持同步", .english: "Keep your habits synced across all devices"],
        L10n.billedMonthly: [.chinese: "按月扣款", .english: "Billed monthly"],
        L10n.billedYearly: [.chinese: "按年扣款", .english: "Billed yearly"],
        L10n.cancelAnytimeDuringTrialNoCharge: [.chinese: "试用期间可以随时取消，不扣费", .english: "Cancel anytime during trial, no charge"],
        "试用期间可以随时取消，不扣费": [.chinese: "试用期间可以随时取消，不扣费", .english: "Cancel anytime during trial, no charge"],
        L10n.popular: [.chinese: "最受欢迎", .english: "POPULAR"],
        L10n.lifetime: [.chinese: "终身买断", .english: "Lifetime"],
        L10n.limitedTimeOffer: [.chinese: "限时特惠", .english: "Limited Time Offer"],
        L10n.oneTimePayment: [.chinese: "一次性买断", .english: "One-time payment"],
        L10n.bestValue: [.chinese: "最超值", .english: "BEST VALUE"],
        L10n.`continue`: [.chinese: "继续", .english: "Continue"],
        L10n.byContinuingYouAgreeToOur: [.chinese: "继续即表示您同意我们的", .english: "By continuing, you agree to our"],
        L10n.and: [.chinese: "和", .english: "and"],
        L10n.appLock: [.chinese: "应用锁", .english: "App Lock"],
        L10n.data: [.chinese: "数据", .english: "Data"],
        L10n.icloudSync: [.chinese: "iCloud 同步", .english: "iCloud Sync"],
        L10n.importData: [.chinese: "导入数据", .english: "Import Data"],
        L10n.exportData: [.chinese: "导出数据", .english: "Export Data"],
        "Export Excel Data": [.chinese: "导出数据", .english: "Export Data"],
        L10n.exportSuccessful: [.chinese: "导出成功！", .english: "Export Successful!"],
        "导出成功！": [.chinese: "导出成功！", .english: "Export Successful!"],
        L10n.termsOfService: [.chinese: "使用条款", .english: "Terms of Service"],
        L10n.privacyPolicy: [.chinese: "隐私政策", .english: "Privacy Policy"],
        L10n.on: [.chinese: "开启", .english: "On"],
        L10n.off: [.chinese: "关闭", .english: "Off"],
        L10n.upgradeToPremium: [.chinese: "升级至高级版", .english: "Upgrade to Premium"],
        L10n.unlockAllFeatures: [.chinese: "解锁全部特权与功能", .english: "Unlock all features"],
        L10n.premiumMember: [.chinese: "高级版会员", .english: "Premium Member"],
        L10n.allFeaturesUnlocked: [.chinese: "已解锁全部特权与功能", .english: "All features unlocked"],
        L10n.archivedHabits: [.chinese: "已归档习惯", .english: "Archived Habits"],
        L10n.showArchived: [.chinese: "显示归档", .english: "Show Archived"],
        L10n.noArchivedHabits: [.chinese: "暂无已归档的习惯。", .english: "No archived habits."],
        L10n.thisActionWillPermanentlyDeleteThisHabitAndAllItsCheckInRecordsItCannotBeRecovered: [.chinese: "此操作将永久删除该习惯及其所有打卡记录，且不可恢复。", .english: "This action will permanently delete this habit and all its check-in records. It cannot be recovered."],
        L10n.thisSession: [.chinese: "本次", .english: "This Session"],
        L10n.undoCheckIn1: [.chinese: "撤销打卡？", .english: "Undo Check-in?"],
        L10n.undo: [.chinese: "撤销打卡", .english: "Undo"],
        L10n.share: [.chinese: "分享", .english: "Share"],
        L10n.savedToPhotos: [.chinese: "已保存到相册", .english: "Saved to Photos"],
        L10n.checkInSuccess: [.chinese: "打卡成功", .english: "Check-in Success"],
        L10n.w: [.chinese: "周：", .english: "W:"],
        L10n.m1: [.chinese: "月：", .english: "M:"],
        L10n.reminder: [.chinese: "打卡提醒", .english: "Reminder"],
        "打卡提醒": [.chinese: "打卡提醒", .english: "Reminder"],
        L10n.time1: [.chinese: "提醒时间", .english: "Time"],
        "提醒时间": [.chinese: "提醒时间", .english: "Time"],
        L10n.customMessage: [.chinese: "自定义文案", .english: "Custom Message"],
        "自定义文案": [.chinese: "自定义文案", .english: "Custom Message"],
        L10n.timeToCheckInKeepItUp: [.chinese: "该打卡啦！坚持就是胜利～", .english: "Time to check in! Keep it up~"],
        "该打卡啦！坚持就是胜利～": [.chinese: "该打卡啦！坚持就是胜利～", .english: "Time to check in! Keep it up~"],
        L10n.reminderDisabled: [.chinese: "未开启提醒", .english: "Reminder Disabled"],
        "未开启提醒": [.chinese: "未开启提醒", .english: "Reminder Disabled"],
        L10n.restoreSuccessful: [.chinese: "恢复购买成功", .english: "Restore Successful"],
        "恢复购买成功": [.chinese: "恢复购买成功", .english: "Restore Successful"],
        L10n.noPurchasesToRestore: [.chinese: "没有可恢复的购买项", .english: "No Purchases to Restore"],
        "没有可恢复的购买项": [.chinese: "没有可恢复的购买项", .english: "No Purchases to Restore"],
        L10n.failedToFetchProducts: [.chinese: "获取产品列表失败：", .english: "Failed to fetch products: "],
        "获取产品列表失败：": [.chinese: "获取产品列表失败：", .english: "Failed to fetch products: "],
        L10n.purchasing: [.chinese: "正在购买...", .english: "Purchasing..."],
        "正在购买...": [.chinese: "正在购买...", .english: "Purchasing..."],
        L10n.restoring: [.chinese: "恢复中...", .english: "Restoring..."],
        "恢复中...": [.chinese: "恢复中...", .english: "Restoring..."],
        L10n.purchaseSuccessful: [.chinese: "购买成功！", .english: "Purchase Successful!"],
        "购买成功！": [.chinese: "购买成功！", .english: "Purchase Successful!"],
        L10n.purchaseCancelled: [.chinese: "购买被取消", .english: "Purchase Cancelled"],
        "购买被取消": [.chinese: "购买被取消", .english: "Purchase Cancelled"],
        L10n.purchaseFailed: [.chinese: "购买失败", .english: "Purchase Failed"],
        "购买失败": [.chinese: "购买失败", .english: "Purchase Failed"],
        L10n.restorePurchases: [.chinese: "恢复购买", .english: "Restore Purchases"],
        "恢复购买": [.chinese: "恢复购买", .english: "Restore Purchases"],
        L10n.tickdayPremiumMember: [.chinese: "TickDay 尊享会员", .english: "TickDay Premium Member"],
        "TickDay 尊享会员": [.chinese: "TickDay 尊享会员", .english: "TickDay Premium Member"],
        L10n.youAreAPremiumMember: [.chinese: "您已是尊享会员", .english: "You are a Premium Member"],
        "您已是尊享会员": [.chinese: "您已是尊享会员", .english: "You are a Premium Member"],
        L10n.validUntilLifetimeAccess: [.chinese: "到期时间：永久有效 (终身会员)", .english: "Valid until: Lifetime Access"],
        "到期时间：永久有效 (终身会员)": [.chinese: "到期时间：永久有效 (终身会员)", .english: "Valid until: Lifetime Access"],
        L10n.statusActivePremium: [.chinese: "状态：已激活尊享会员", .english: "Status: Active Premium"],
        "状态：已激活尊享会员": [.chinese: "状态：已激活尊享会员", .english: "Status: Active Premium"],
        L10n.validUntil: [.chinese: "到期时间：", .english: "Valid until: "],
        "到期时间：": [.chinese: "到期时间：", .english: "Valid until: "],
        L10n.unableToFetchProductPricingFromAppStorePleaseCheckNetworkOrAppStoreConnectStatus: [.chinese: "无法从 App Store 获取产品价格与配置，请检查网络连接或确认苹果后台产品已生效。", .english: "Unable to fetch product pricing from App Store. Please check network or App Store Connect status."],
        "无法从 App Store 获取产品价格与配置，请检查网络连接或确认苹果后台产品已生效。": [.chinese: "无法从 App Store 获取产品价格与配置，请检查网络连接或确认苹果后台产品已生效。", .english: "Unable to fetch product pricing from App Store. Please check network or App Store Connect status."],
        "按月扣费": [.chinese: "按月扣费", .english: "Billed monthly"],
        "按年扣费": [.chinese: "按年扣费", .english: "Billed yearly"],
        "一次性付费": [.chinese: "一次性付费", .english: "One-time payment"],
        L10n.autoRenewablePriceCancelAnytime: [.chinese: "自动续期，{price}，可随时取消", .english: "Auto-renewable, {price}, cancel anytime"],
        "自动续期，{price}，可随时取消": [.chinese: "自动续期，{price}，可随时取消", .english: "Auto-renewable, {price}, cancel anytime"],
        L10n.firstMonthFreeThenPrice: [.chinese: "首月免费，结束后按 {price}收费", .english: "First month free, then {price}"],
        "首月免费，结束后按 {price}收费": [.chinese: "首月免费，结束后按 {price}收费", .english: "First month free, then {price}"],
        L10n.oneTimePaymentLifetimeAccessToAllFeatures: [.chinese: "一次性付费，永久解锁全部尊享权益", .english: "One-time payment, lifetime access to all features"],
        "一次性付费，永久解锁全部尊享权益": [.chinese: "一次性付费，永久解锁全部尊享权益", .english: "One-time payment, lifetime access to all features"],
        L10n.paymentWillBeChargedToYourItunesAccountAtConfirmationOfPurchaseSubscriptionAutomaticallyRenewsUnlessAutoRenewIsTurnedOffAtLeast24HoursBeforeTheEndOfTheCurrentPeriodAccountWillBeChargedForRenewalWithin24HoursPriorToTheEndOfTheCurrentPeriodYouCanManageAndCancelYourSubscriptionsInYourAppStoreAccountSettings: [.chinese: "确认购买后，款项将从您的 iTunes 账户扣除。订阅将自动续期，除非在当前订阅期结束前至少24小时关闭自动续订。您的账户将在当前订阅期结束前24小时内扣取续订费用。您可以在购买后前往 App Store 账户设置中管理或取消您的订阅。", .english: "Payment will be charged to your iTunes account at confirmation of purchase. Subscription automatically renews unless auto-renew is turned off at least 24-hours before the end of the current period. Account will be charged for renewal within 24-hours prior to the end of the current period. You can manage and cancel your subscriptions in your App Store account settings."],
        "确认购买后，款项将从您的 iTunes 账户扣除。订阅将自动续期，除非在当前订阅期结束前至少24小时关闭自动续订。您的账户将在当前订阅期结束前24小时内扣取续订费用。您可以在购买后前往 App Store 账户设置中管理或取消您的订阅。": [.chinese: "确认购买后，款项将从您的 iTunes 账户扣除。订阅将自动续期，除非在当前订阅期结束前至少24小时关闭自动续订。您的账户将在当前订阅期结束前24小时内扣取续订费用。您可以在购买后前往 App Store 账户设置中管理或取消您的订阅。", .english: "Payment will be charged to your iTunes account at confirmation of purchase. Subscription automatically renews unless auto-renew is turned off at least 24-hours before the end of the current period. Account will be charged for renewal within 24-hours prior to the end of the current period. You can manage and cancel your subscriptions in your App Store account settings."],
        L10n.notice: [.chinese: "提示", .english: "Notice"],
        "提示": [.chinese: "提示", .english: "Notice"],
        "确定": [.chinese: "确定", .english: "OK"],
        L10n.unableToFetchSubscriptionPricingFromAppStoreConnectShowingDefaultReferencePricesPleaseCheck1InAppPurchaseStatusIsNotMissingMetadata2PaidApplicationsAgreementIsActive3ProductIdsMatchExactly: [.chinese: "无法从苹果后台获取订阅价格，当前显示默认参考价。请检查：1) 苹果后台内购项目状态不为“缺少元数据”；2) App Store Connect 付费协议已生效；3) 产品 ID 匹配。", .english: "Unable to fetch subscription pricing from App Store Connect. Showing default reference prices. Please check: 1) In-App Purchase status is not 'Missing Metadata'; 2) Paid Applications Agreement is Active; 3) Product IDs match exactly."],
        "无法从苹果后台获取订阅价格，当前显示默认参考价。请检查：1) 苹果后台内购项目状态不为“缺少元数据”；2) App Store Connect 付费协议已生效；3) 产品 ID 匹配。": [.chinese: "无法从苹果后台获取订阅价格，当前显示默认参考价。请检查：1) 苹果后台内购项目状态不为“缺少元数据”；2) App Store Connect 付费协议已生效；3) 产品 ID 匹配。", .english: "Unable to fetch subscription pricing from App Store Connect. Showing default reference prices. Please check: 1) In-App Purchase status is not 'Missing Metadata'; 2) Paid Applications Agreement is Active; 3) Product IDs match exactly."],
        L10n.generateMockDataForThisYear: [.chinese: "一键生成今年模拟打卡数据", .english: "Generate Mock Data for This Year"],
        "一键生成今年模拟打卡数据": [.chinese: "一键生成今年模拟打卡数据", .english: "Generate Mock Data for This Year"],
        L10n.populateRealistic2026CheckInsAndMoodRecords: [.chinese: "为现有习惯随机填充今年打卡与情绪记录", .english: "Populate realistic 2026 check-ins and mood records"],
        "为现有习惯随机填充今年打卡与情绪记录": [.chinese: "为现有习惯随机填充今年打卡与情绪记录", .english: "Populate realistic 2026 check-ins and mood records"],
        L10n.successfullyGeneratedMockCheckInsMoodRecordsForThisYear: [.chinese: "已为所有习惯成功生成今年全套模拟打卡与情绪数据！", .english: "Successfully generated mock check-ins & mood records for this year!"],
        "已为所有习惯成功生成今年全套模拟打卡与情绪数据！": [.chinese: "已为所有习惯成功生成今年全套模拟打卡与情绪数据！", .english: "Successfully generated mock check-ins & mood records for this year!"],
        L10n.icloudConnected: [.chinese: "iCloud 账号正常连接", .english: "iCloud Connected"],
        "iCloud 账号正常连接": [.chinese: "iCloud 账号正常连接", .english: "iCloud Connected"],
        L10n.notLoggedInPleaseSignInToIcloudInSettings: [.chinese: "未登录，请在系统设置中登录您的 Apple ID", .english: "Not logged in. Please sign in to iCloud in Settings."],
        "未登录，请在系统设置中登录您的 Apple ID": [.chinese: "未登录，请在系统设置中登录您的 Apple ID", .english: "Not logged in. Please sign in to iCloud in Settings."],
        L10n.icloudAccessRestricted: [.chinese: "iCloud 访问受限", .english: "iCloud Access Restricted"],
        "iCloud 访问受限": [.chinese: "iCloud 访问受限", .english: "iCloud Access Restricted"],
        L10n.couldNotDetermineIcloudStatus: [.chinese: "无法确定 iCloud 状态", .english: "Could Not Determine iCloud Status"],
        "无法确定 iCloud 状态": [.chinese: "无法确定 iCloud 状态", .english: "Could Not Determine iCloud Status"],
        L10n.icloudTemporarilyUnavailable: [.chinese: "iCloud 服务暂不可用", .english: "iCloud Temporarily Unavailable"],
        "iCloud 服务暂不可用": [.chinese: "iCloud 服务暂不可用", .english: "iCloud Temporarily Unavailable"],
        L10n.unknownStatus: [.chinese: "未知状态", .english: "Unknown Status"],
        "未知状态": [.chinese: "未知状态", .english: "Unknown Status"],
        L10n.icloudStatus: [.chinese: "iCloud 状态", .english: "iCloud Status"],
        "iCloud 状态": [.chinese: "iCloud 状态", .english: "iCloud Status"],
        L10n.checkSyncNow: [.chinese: "立即检查同步", .english: "Check Sync Now"],
        "立即检查同步": [.chinese: "立即检查同步", .english: "Check Sync Now"],
        L10n.checkingStatus: [.chinese: "状态检查中...", .english: "Checking Status..."],
        "状态检查中...": [.chinese: "状态检查中...", .english: "Checking Status..."],
        L10n.dataIsFullyStoredLocallyForInstantOfflineAccessEnablingIcloudBacksUpInBackgroundDisablingPreservesAllLocalRecordsReconnectingMergesOfflineUpdatesAutomatically: [.chinese: "数据已完全保存在本地数据库，支持极速离线读取与打卡。开启 iCloud 仅在后台同步备份，关闭不会丢失任何本地已有记录，重新连接后自动增量双向合并。", .english: "Data is fully stored locally for instant offline access. Enabling iCloud backs up in background; disabling preserves all local records. Reconnecting merges offline updates automatically."],
        "数据已完全保存在本地数据库，支持极速离线读取与打卡。开启 iCloud 仅在后台同步备份，关闭不会丢失任何本地已有记录，重新连接后自动增量双向合并。": [.chinese: "数据已完全保存在本地数据库，支持极速离线读取与打卡。开启 iCloud 仅在后台同步备份，关闭不会丢失任何本地已有记录，重新连接后自动增量双向合并。", .english: "Data is fully stored locally for instant offline access. Enabling iCloud backs up in background; disabling preserves all local records. Reconnecting merges offline updates automatically."],
        L10n.noHabit: [.chinese: "暂无习惯", .english: "No Habit"],
        L10n.selectHabits: [.chinese: "请选择习惯", .english: "Select Habits"],
        L10n.pleaseLongPressToEditSelectHabit: [.chinese: "请长按编辑选择习惯", .english: "Please long press to edit & select habit"],
        "请长按编辑选择习惯": [.chinese: "请长按编辑选择习惯", .english: "Please long press to edit & select habit"],
        L10n.thisWeek1: [.chinese: "本周", .english: "This week"],
        "本周": [.chinese: "本周", .english: "This week"],
        L10n.thisMonth1: [.chinese: "本月", .english: "This month"],
        "本月": [.chinese: "本月", .english: "This month"],
        "周": [.chinese: "周", .english: "Week"],
        "月": [.chinese: "月", .english: "Month"],
        "年": [.chinese: "年", .english: "Year"],
    ]

    func tr(_ lang: AppLanguage) -> String {
        return String.translations[self]?[lang] ?? self
    }

    func wTr() -> String {
        let mode = UserDefaults(suiteName: "group.com.littlehabit.tracker")?.string(forKey: "appLanguage") ?? "system"
        var langStr = "en"
        if mode == "zh" { langStr = "zh" }
        else if mode == "en" { langStr = "en" }
        else if let firstLang = Locale.preferredLanguages.first {
            if firstLang.hasPrefix("zh") { langStr = "zh" }
        }
        let lang: AppLanguage = langStr == "zh" ? .chinese : .english
        return String.translations[self]?[lang] ?? self
    }
}

func getWidgetLanguage() -> String {
    let mode = UserDefaults(suiteName: "group.com.littlehabit.tracker")?.string(forKey: "appLanguage") ?? "system"
    if mode == "zh" { return "zh" }
    if mode == "en" { return "en" }
    if let firstLang = Locale.preferredLanguages.first {
        if firstLang.hasPrefix("zh") { return "zh" }
    }
    return "en"
}
