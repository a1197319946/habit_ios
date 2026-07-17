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
    case traditionalChinese = "zh-Hant"
    case japanese = "ja"
    case korean = "ko"
    case spanish = "es"
    case german = "de"
    case russian = "ru"
    case italian = "it"
    
    var id: String { self.rawValue }
    
    var displayName: String {
        switch self {
        case .system: return L10n.system.tr(.system)
        case .english: return "English"
        case .chinese: return "简体中文"
        case .traditionalChinese: return "繁體中文"
        case .japanese: return "日本語"
        case .korean: return "한국어"
        case .spanish: return "Español"
        case .german: return "Deutsch"
        case .russian: return "Русский"
        case .italian: return "Italiano"
        }
    }
    
    var localeIdentifier: String {
        switch self {
        case .system:
            return Locale.current.identifier
        case .english:
            return "en_US"
        case .chinese:
            return "zh_CN"
        case .traditionalChinese:
            return "zh_Hant"
        case .japanese:
            return "ja_JP"
        case .korean:
            return "ko_KR"
        case .spanish:
            return "es_ES"
        case .german:
            return "de_DE"
        case .russian:
            return "ru_RU"
        case .italian:
            return "it_IT"
        }
    }
}

enum L10n {
    static let csvHeaders = "csvHeaders"
    static let noRecords = "noRecords"
    static let smallStepsBigChanges = "\"Small steps, big changes.\""
    static let home = "Home"
    static let habits = "Habits"
    static let stats = "Stats"
    static let profile = "Profile"
    static let manageHabits = "Manage Habits"
    static let youHave = "You have "
    static let habits1 = " habits."
    static let goodMorning = "Good Morning"
    static let goodAfternoon = "Good Afternoon"
    static let goodEvening = "Good Evening"
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
    static let weeklyGoals = "Weekly goals"
    static let monthlyTarget2 = "monthly target"
    static let selectIcon = "Select icon"
    static let totalValue = "total value"
    static let calm = "calm"
    static let down2 = "down"
    static let angry2 = "angry"
    static let monthlyDeduction = "Monthly deduction"
    static let annualDeduction = "Annual deduction"
    static let oneTimePayment2 = "one time payment"
    static let ok2 = "OK"
    static let checkedIn = "Checked In"
    static let unableToFetchProductPricingAndConfig = "Unable to fetch product pricing and config..."

    static let mainTab = "Main"
}

extension String {
    static let translations: [String: [AppLanguage: String]] = {
        var dict = [String: [AppLanguage: String]]()
        dict[L10n.smallStepsBigChanges] = [.chinese: "\"不积跬步，无以至千里。\"", .traditionalChinese: "\"不積蹺步，無以至千里。\"", .english: "\"Small steps, big changes.\"", .japanese: "「小さな一歩、大きな変化。」", .korean: "\"작은 발걸음, 큰 변화\"", .spanish: "\"Pequeños pasos, grandes cambios\".", .german: "„Kleine Schritte, große Veränderungen.“", .russian: "«Маленькие шаги, большие изменения».", .italian: "\"Piccoli passi, grandi cambiamenti.\""]
        dict[L10n.home] = [.chinese: "首页", .traditionalChinese: "首頁", .english: "Home", .japanese: "ホーム", .korean: "홈", .spanish: "Inicio", .german: "Zuhause", .russian: "Главная", .italian: "Casa"]
        dict[L10n.habits] = [.chinese: "习惯", .traditionalChinese: "習慣", .english: "Habits", .japanese: "習慣", .korean: "습관", .spanish: "Hábitos", .german: "Gewohnheiten", .russian: "Привычки", .italian: "Abitudini"]
        dict[L10n.stats] = [.chinese: "统计", .traditionalChinese: "統計", .english: "Stats", .japanese: "統計", .korean: "통계", .spanish: "Estadísticas", .german: "Statistiken", .russian: "Статистика", .italian: "Statistiche"]
        dict[L10n.profile] = [.chinese: "我的", .traditionalChinese: "我的", .english: "Profile", .japanese: "プロフィール", .korean: "프로필", .spanish: "Perfil", .german: "Profil", .russian: "Профиль", .italian: "Profilo"]
        dict[L10n.manageHabits] = [.chinese: "管理习惯", .traditionalChinese: "管理習慣", .english: "Manage Habits", .japanese: "習慣を管理する", .korean: "습관 관리", .spanish: "Gestionar hábitos", .german: "Gewohnheiten verwalten", .russian: "Управляйте привычками", .italian: "Gestire le abitudini"]
        dict[L10n.youHave] = [.chinese: "你当前有 ", .traditionalChinese: "你目前有", .english: "You have ", .japanese: "あなたは持っています", .korean: "당신은", .spanish: "tienes", .german: "Das hast du", .russian: "У тебя есть", .italian: "Sì"]
        dict[L10n.habits1] = [.chinese: " 个习惯。", .traditionalChinese: "個習慣。", .english: " habits.", .japanese: "習慣。", .korean: "습관.", .spanish: "hábitos.", .german: "Gewohnheiten.", .russian: "привычки.", .italian: "abitudini."]
        dict[L10n.goodMorning] = [.chinese: "早上好", .traditionalChinese: "早安", .english: "Good Morning", .japanese: "おはよう", .korean: "좋은 아침이에요", .spanish: "Buen día", .german: "Guten Morgen", .russian: "Доброе утро", .italian: "Buongiorno"]
        dict[L10n.goodAfternoon] = [.chinese: "下午好", .traditionalChinese: "午安", .english: "Good Afternoon", .japanese: "こんにちは", .korean: "좋은 오후입니다", .spanish: "Buenas tardes", .german: "Guten Tag", .russian: "Добрый день", .italian: "Buon pomeriggio"]
        dict[L10n.goodEvening] = [.chinese: "晚上好", .traditionalChinese: "晚安", .english: "Good Evening", .japanese: "こんばんは", .korean: "좋은 저녁이에요", .spanish: "Buenas noches", .german: "Guten Abend", .russian: "Добрый вечер", .italian: "Buonasera"]
        dict[L10n.hereIsYourFocusForToday] = [.chinese: "这是你今天的目标。", .traditionalChinese: "這是你今天的目標。", .english: "Here is your focus for today.", .japanese: "今日の焦点はここです。", .korean: "오늘의 초점은 다음과 같습니다.", .spanish: "Aquí está su enfoque para hoy.", .german: "Hier liegt Ihr Fokus für heute.", .russian: "Вот ваше внимание на сегодня.", .italian: "Ecco il tuo focus per oggi."]
        dict[L10n.daily] = [.chinese: "每天", .traditionalChinese: "每天", .english: "Daily", .japanese: "毎日", .korean: "매일", .spanish: "Diariamente", .german: "Täglich", .russian: "Ежедневно", .italian: "Ogni giorno"]
        dict[L10n.progress] = [.chinese: "进度", .traditionalChinese: "進度", .english: "Progress", .japanese: "進捗状況", .korean: "진행상황", .spanish: "Progreso", .german: "Fortschritt", .russian: "Прогресс", .italian: "Progresso"]
        dict[L10n.goal] = [.chinese: "目标", .traditionalChinese: "目標", .english: "Goal", .japanese: "目標", .korean: "목표", .spanish: "Objetivo", .german: "Ziel", .russian: "Цель", .italian: "Obiettivo"]
        dict[L10n.whatDoYouWantToBuild] = [.chinese: "你想养成什么习惯？", .traditionalChinese: "你想養成什麼習慣？", .english: "What do you want to build?", .japanese: "何を作りたいですか?", .korean: "무엇을 만들고 싶나요?", .spanish: "¿Qué quieres construir?", .german: "Was möchten Sie bauen?", .russian: "Что вы хотите построить?", .italian: "Cosa vuoi costruire?"]
        dict[L10n.eGRead10PagesDrinkWater] = [.chinese: "例如：阅读10页、喝水...", .traditionalChinese: "例如：閱讀10頁、喝水...", .english: "e.g. Read 10 pages, Drink water...", .japanese: "例えば10ページ読んで、水を飲みましょう...", .korean: "예를 들어 10페이지 읽고 물 마시고...", .spanish: "p.ej. Leer 10 páginas, Beber agua...", .german: "z.B. 10 Seiten lesen, Wasser trinken...", .russian: "например Прочитать 10 страниц, Пить воду...", .italian: "per esempio. Leggi 10 pagine, bevi acqua..."]
        dict[L10n.themeColor] = [.chinese: "主题颜色", .traditionalChinese: "主題顏色", .english: "Theme Color", .japanese: "テーマカラー", .korean: "테마 색상", .spanish: "Color del tema", .german: "Themenfarbe", .russian: "Цвет темы", .italian: "Colore del tema"]
        dict[L10n.chooseAnIcon] = [.chinese: "选择一个图标", .traditionalChinese: "選擇一個圖標", .english: "Choose an Icon", .japanese: "アイコンを選択してください", .korean: "아이콘을 선택하세요", .spanish: "Elige un icono", .german: "Wählen Sie ein Symbol", .russian: "Выберите значок", .italian: "Scegli un'icona"]
        dict[L10n.goalType] = [.chinese: "目标类型", .traditionalChinese: "目標類型", .english: "Goal Type", .japanese: "目標の種類", .korean: "목표 유형", .spanish: "Tipo de objetivo", .german: "Zieltyp", .russian: "Тип цели", .italian: "Tipo di obiettivo"]
        dict[L10n.frequency] = [.chinese: "频率", .traditionalChinese: "頻率", .english: "Frequency", .japanese: "周波数", .korean: "빈도", .spanish: "Frecuencia", .german: "Häufigkeit", .russian: "Частота", .italian: "Frequenza"]
        dict[L10n.totalAmount] = [.chinese: "总计数量", .traditionalChinese: "總計數量", .english: "Total Amount", .japanese: "合計金額", .korean: "총액", .spanish: "Monto Total", .german: "Gesamtbetrag", .russian: "Общая сумма", .italian: "Importo totale"]
        dict[L10n.targetPerWeek] = [.chinese: "目标 (每周)", .traditionalChinese: "目標 (每週)", .english: "Target (per week)", .japanese: "目標（1週間あたり）", .korean: "목표(주당)", .spanish: "Objetivo (por semana)", .german: "Ziel (pro Woche)", .russian: "Цель (в неделю)", .italian: "Obiettivo (a settimana)"]
        dict[L10n.targetAmountPerWeek] = [.chinese: "目标数量 (每周)", .traditionalChinese: "目標數量 (每週)", .english: "Target Amount (per week)", .japanese: "目標金額（1週間あたり）", .korean: "목표금액(주당)", .spanish: "Importe objetivo (por semana)", .german: "Zielbetrag (pro Woche)", .russian: "Целевая сумма (в неделю)", .italian: "Importo target (a settimana)"]
        dict[L10n.times] = [.chinese: "次", .traditionalChinese: "次", .english: "Times", .japanese: "回", .korean: "타임즈", .spanish: "tiempos", .german: "Zeiten", .russian: "Время", .italian: "Tempi"]
        dict[L10n.createHabit] = [.chinese: "创建习惯", .traditionalChinese: "創建習慣", .english: "Create Habit", .japanese: "習慣を作る", .korean: "습관 만들기", .spanish: "Crear hábito", .german: "Gewohnheit schaffen", .russian: "Создайте привычку", .italian: "Crea un'abitudine"]
        dict[L10n.saveChanges] = [.chinese: "保存修改", .traditionalChinese: "儲存修改", .english: "Save Changes", .japanese: "変更を保存", .korean: "변경 사항 저장", .spanish: "Guardar cambios", .german: "Änderungen speichern", .russian: "Сохранить изменения", .italian: "Salva modifiche"]
        dict[L10n.creating] = [.chinese: "保存中...", .traditionalChinese: "儲存中...", .english: "Creating...", .japanese: "作成中...", .korean: "만드는 중...", .spanish: "Creando...", .german: "Erstellen...", .russian: "Создание...", .italian: "Creazione..."]
        dict[L10n.perWeek] = [.chinese: "按周", .traditionalChinese: "按週", .english: "Per Week", .japanese: "週ごと", .korean: "주당", .spanish: "Por semana", .german: "Pro Woche", .russian: "в неделю", .italian: "A settimana"]
        dict[L10n.perMonth] = [.chinese: "按月", .traditionalChinese: "按月", .english: "Per Month", .japanese: "月あたり", .korean: "월별", .spanish: "Por mes", .german: "Pro Monat", .russian: "в месяц", .italian: "Al mese"]
        dict[L10n.weeklyTarget] = [.chinese: "每周目标次数", .traditionalChinese: "每週目標次數", .english: "Weekly Target", .japanese: "週間目標", .korean: "주간 목표", .spanish: "Objetivo semanal", .german: "Wöchentliches Ziel", .russian: "Еженедельная цель", .italian: "Obiettivo settimanale"]
        dict[L10n.monthlyTarget] = [.chinese: "每月目标次数", .traditionalChinese: "每月目標次數", .english: "Monthly Target", .japanese: "月間目標", .korean: "월간 목표", .spanish: "Objetivo mensual", .german: "Monatsziel", .russian: "Ежемесячная цель", .italian: "Obiettivo mensile"]
        dict[L10n.weeklyTargetAmount] = [.chinese: "每周目标总量", .traditionalChinese: "每週目標總量", .english: "Weekly Target Amount", .japanese: "週間目標金額", .korean: "주간 목표금액", .spanish: "Monto objetivo semanal", .german: "Wöchentlicher Zielbetrag", .russian: "Еженедельная целевая сумма", .italian: "Importo target settimanale"]
        dict[L10n.monthlyTargetAmount] = [.chinese: "每月目标总量", .traditionalChinese: "每月目標總量", .english: "Monthly Target Amount", .japanese: "月間目標金額", .korean: "월별 목표금액", .spanish: "Monto objetivo mensual", .german: "Monatlicher Zielbetrag", .russian: "Ежемесячная целевая сумма", .italian: "Importo target mensile"]
        dict[L10n.language] = [.chinese: "多语言 / Language", .traditionalChinese: "多語言 / Language", .english: "Language / 多语言", .japanese: "言語 / 多言", .korean: "언어 / 多语言", .spanish: "Idioma / 多语言", .german: "Sprache / 多语言", .russian: "Язык / Английский", .italian: "Lingua / 多语言"]
        dict[L10n.shareWithFriends] = [.chinese: "分享给朋友", .traditionalChinese: "分享給朋友", .english: "Share with Friends", .japanese: "友達と共有する", .korean: "친구와 공유", .spanish: "Compartir con amigos", .german: "Mit Freunden teilen", .russian: "Поделитесь с друзьями", .italian: "Condividi con gli amici"]
        dict[L10n.moodHistory] = [.chinese: "心情日记", .traditionalChinese: "心情日記", .english: "Mood History", .japanese: "気分の歴史", .korean: "기분의 역사", .spanish: "Historia del estado de ánimo", .german: "Stimmungsgeschichte", .russian: "История настроения", .italian: "Storia dell'umore"]
        dict[L10n.feedback] = [.chinese: "意见反馈", .traditionalChinese: "意見回饋", .english: "Feedback", .japanese: "フィードバック", .korean: "피드백", .spanish: "Comentarios", .german: "Rückmeldung", .russian: "Обратная связь", .italian: "Feedback"]
        dict[L10n.about] = [.chinese: "关于", .traditionalChinese: "關於", .english: "About", .japanese: "について", .korean: "소개", .spanish: "Acerca de", .german: "Über", .russian: "О", .italian: "Circa"]
        dict[L10n.contactSupport] = [.chinese: "联系客服", .traditionalChinese: "聯絡客服", .english: "Contact Support", .japanese: "サポートに連絡する", .korean: "지원팀에 문의", .spanish: "Contactar con soporte", .german: "Kontaktieren Sie den Support", .russian: "Обратиться в службу поддержки", .italian: "Contatta l'assistenza"]
        dict[L10n.tapToSetName] = [.chinese: "点击设置昵称", .traditionalChinese: "點擊設定暱稱", .english: "Tap to set name", .japanese: "タップして名前を設定します", .korean: "이름을 설정하려면 탭하세요.", .spanish: "Toca para establecer el nombre", .german: "Tippen Sie, um den Namen festzulegen", .russian: "Нажмите, чтобы установить имя", .italian: "Tocca per impostare il nome"]
        dict[L10n.exploringMindfulnessAndBuildingBetterHabitsOneDayAtATime] = [.chinese: "每天进步一点点。", .traditionalChinese: "每天進步一點點。", .english: "Exploring mindfulness and building better habits, one day at a time.", .japanese: "マインドフルネスを探求し、より良い習慣を一日ずつ構築していきます。", .korean: "하루에 한 번씩 마음챙김을 탐구하고 더 나은 습관을 기르세요.", .spanish: "Explorando la atención plena y construyendo mejores hábitos, un día a la vez.", .german: "Achtsamkeit erforschen und bessere Gewohnheiten entwickeln, Tag für Tag.", .russian: "Изучение осознанности и формирование лучших привычек, день за днем.", .italian: "Esplorare la consapevolezza e costruire abitudini migliori, un giorno alla volta."]
        dict[L10n.noHabitsYet] = [.chinese: "没有习惯", .traditionalChinese: "沒有習慣", .english: "No habits yet", .japanese: "まだ習慣が無い", .korean: "아직 습관이 없습니다.", .spanish: "Aún no hay hábitos", .german: "Noch keine Gewohnheiten", .russian: "Привычек пока нет", .italian: "Nessuna abitudine ancora"]
        dict[L10n.clickTheButtonToAddYourFirstHabit] = [.chinese: "点击进入习惯管理页添加你的第一个习惯吧", .traditionalChinese: "點擊進入習慣管理頁面加入你的第一個習慣吧", .english: "Click the + button to add your first habit", .japanese: "+ ボタンをクリックして最初の習慣を追加します", .korean: "첫 번째 습관을 추가하려면 + 버튼을 클릭하세요.", .spanish: "Haz clic en el botón + para agregar tu primer hábito", .german: "Klicken Sie auf die Schaltfläche „+“, um Ihre erste Gewohnheit hinzuzufügen", .russian: "Нажмите кнопку +, чтобы добавить свою первую привычку.", .italian: "Fai clic sul pulsante + per aggiungere la tua prima abitudine"]
        dict[L10n.pending] = [.chinese: "未完成", .traditionalChinese: "未完成", .english: "Pending", .japanese: "保留中", .korean: "보류 중", .spanish: "Pendiente", .german: "Ausstehend", .russian: "Ожидается", .italian: "In sospeso"]
        dict[L10n.completed] = [.chinese: "已完成", .traditionalChinese: "已完成", .english: "Completed", .japanese: "完了", .korean: "완료됨", .spanish: "Completado", .german: "Abgeschlossen", .russian: "Завершено", .italian: "Completato"]
        dict[L10n.noMomentsRecordedYet] = [.chinese: "暂无心情记录。", .traditionalChinese: "暫無心情記錄。", .english: "No moments recorded yet.", .japanese: "まだ記録された瞬間はありません。", .korean: "아직 기록된 순간이 없습니다.", .spanish: "Aún no se han registrado momentos.", .german: "Es wurden noch keine Momente aufgezeichnet.", .russian: "Пока не записано ни одного момента.", .italian: "Nessun momento ancora registrato."]
        dict[L10n.yourJourney] = [.chinese: "你的旅程", .traditionalChinese: "你的旅程", .english: "Your Journey", .japanese: "あなたの旅", .korean: "당신의 여행", .spanish: "Tu viaje", .german: "Deine Reise", .russian: "Ваше путешествие", .italian: "Il tuo viaggio"]
        dict[L10n.aReflectiveLookBackAtYourMoodsAndMoments] = [.chinese: "回顾你的心情与点滴时刻。", .traditionalChinese: "回顧你的心情與點滴時刻。", .english: "A reflective look back at your moods and moments.", .japanese: "自分の気分や瞬間を振り返ります。", .korean: "당신의 기분과 순간을 되돌아보세요.", .spanish: "Una mirada reflexiva a tus estados de ánimo y momentos.", .german: "Ein reflektierter Rückblick auf Ihre Stimmungen und Momente.", .russian: "Рефлексивный взгляд на ваше настроение и моменты.", .italian: "Uno sguardo riflessivo ai tuoi stati d'animo e ai tuoi momenti."]
        dict[L10n.checkIn] = [.chinese: "记录", .traditionalChinese: "記錄", .english: "Check in", .japanese: "チェックイン", .korean: "체크인", .spanish: "Registrarse", .german: "Checken Sie ein", .russian: "Зарегистрироваться", .italian: "Effettua il check-in"]
        dict[L10n.edit] = [.chinese: "修改", .traditionalChinese: "修改", .english: "Edit", .japanese: "編集", .korean: "편집", .spanish: "Editar", .german: "Bearbeiten", .russian: "Редактировать", .italian: "Modifica"]
        dict[L10n.checkIn1] = [.chinese: "完成打卡", .traditionalChinese: "完成打卡", .english: "Check In", .japanese: "チェックイン", .korean: "체크인", .spanish: "Registrarse", .german: "Einchecken", .russian: "Зарегистрироваться", .italian: "Effettua il check-in"]
        dict[L10n.targetAchieved] = [.chinese: "目标已达成！", .traditionalChinese: "目標達成！", .english: "Target Achieved!", .japanese: "目標達成！", .korean: "목표달성!", .spanish: "¡Objetivo logrado!", .german: "Ziel erreicht!", .russian: "Цель достигнута!", .italian: "Obiettivo raggiunto!"]
        dict[L10n.newHabit] = [.chinese: "新增习惯", .traditionalChinese: "新增習慣", .english: "New Habit", .japanese: "新しい習慣", .korean: "새로운 습관", .spanish: "Nuevo hábito", .german: "Neue Gewohnheit", .russian: "Новая привычка", .italian: "Nuova abitudine"]
        dict[L10n.editHabit] = [.chinese: "编辑习惯", .traditionalChinese: "編輯習慣", .english: "Edit Habit", .japanese: "習慣を編集する", .korean: "습관 편집", .spanish: "Editar hábito", .german: "Gewohnheit bearbeiten", .russian: "Изменить привычку", .italian: "Modifica abitudine"]
        dict[L10n.recordMood] = [.chinese: "记录心情", .traditionalChinese: "記錄心情", .english: "Record Mood", .japanese: "気分を記録する", .korean: "기분 기록하기", .spanish: "Grabar estado de ánimo", .german: "Stimmung aufzeichnen", .russian: "Запись настроения", .italian: "Registra l'umore"]
        dict[L10n.currentMood] = [.chinese: "当前心情", .traditionalChinese: "目前心情", .english: "Current Mood", .japanese: "現在の気分", .korean: "현재 기분", .spanish: "Estado de ánimo actual", .german: "Aktuelle Stimmung", .russian: "Текущее настроение", .italian: "Umore attuale"]
        dict[L10n.thoughtsOptional] = [.chinese: "想法 (选填)", .traditionalChinese: "想法 (選填)", .english: "Thoughts (Optional)", .japanese: "感想（任意）", .korean: "생각(선택사항)", .spanish: "Pensamientos (opcional)", .german: "Gedanken (optional)", .russian: "Мысли (необязательно)", .italian: "Pensieri (facoltativo)"]
        dict[L10n.writeDownYourThoughts] = [.chinese: "写下这一刻的想法...", .traditionalChinese: "寫下這一刻的想法...", .english: "Write down your thoughts...", .japanese: "あなたの考えを書き留めてください...", .korean: "당신의 생각을 적어보세요...", .spanish: "Escribe tus pensamientos...", .german: "Schreiben Sie Ihre Gedanken auf...", .russian: "Запишите свои мысли...", .italian: "Scrivi i tuoi pensieri..."]
        dict[L10n.imageOptional] = [.chinese: "图片 (选填)", .traditionalChinese: "圖片 (選填)", .english: "Image (Optional)", .japanese: "画像 (オプション)", .korean: "이미지(선택사항)", .spanish: "Imagen (opcional)", .german: "Bild (optional)", .russian: "Изображение (необязательно)", .italian: "Immagine (facoltativa)"]
        dict[L10n.addImage] = [.chinese: "添加图片", .traditionalChinese: "新增圖片", .english: "Add Image", .japanese: "画像を追加", .korean: "이미지 추가", .spanish: "Agregar imagen", .german: "Bild hinzufügen", .russian: "Добавить изображение", .italian: "Aggiungi immagine"]
        dict[L10n.save] = [.chinese: "记录", .traditionalChinese: "記錄", .english: "Save", .japanese: "保存", .korean: "저장", .spanish: "Guardar", .german: "Speichern", .russian: "Сохранить", .italian: "Salva"]
        dict[L10n.excited] = [.chinese: "激动", .traditionalChinese: "激動", .english: "Excited", .japanese: "興奮した", .korean: "흥분된다", .spanish: "emocionado", .german: "Aufgeregt", .russian: "взволнованный", .italian: "Emozionato"]
        dict[L10n.happy] = [.chinese: "开心", .traditionalChinese: "開心", .english: "Happy", .japanese: "ハッピー", .korean: "행복하다", .spanish: "feliz", .german: "Glücklich", .russian: "Счастливый", .italian: "Felice"]
        dict[L10n.normal] = [.chinese: "一般", .traditionalChinese: "一般", .english: "Normal", .japanese: "ノーマル", .korean: "보통", .spanish: "normales", .german: "Normal", .russian: "Нормальный", .italian: "Normale"]
        dict[L10n.down] = [.chinese: "失落", .traditionalChinese: "失落", .english: "Down", .japanese: "ダウン", .korean: "아래로", .spanish: "abajo", .german: "Runter", .russian: "Вниз", .italian: "Giù"]
        dict[L10n.angry] = [.chinese: "愤怒", .traditionalChinese: "憤怒", .english: "Angry", .japanese: "怒っている", .korean: "화난", .spanish: "enojado", .german: "Wütend", .russian: "Злой", .italian: "Arrabbiato"]
        dict[L10n.redeemOfferCode] = [.chinese: "使用兑换码兑换会员", .traditionalChinese: "使用兌換碼兌換會員", .english: "Redeem Offer Code", .japanese: "オファーコードを引き換える", .korean: "혜택 코드 사용", .spanish: "Canjear código de oferta", .german: "Angebotscode einlösen", .russian: "Активировать код предложения", .italian: "Riscatta il codice dell'offerta"]
        dict[L10n.trackYourDailyProgress] = [.chinese: "记录你的每日进步", .traditionalChinese: "記錄你的每日進步", .english: "Track your daily progress", .japanese: "毎日の進捗状況を追跡する", .korean: "일일 진행 상황을 추적하세요", .spanish: "Sigue tu progreso diario", .german: "Verfolgen Sie Ihren täglichen Fortschritt", .russian: "Отслеживайте свой ежедневный прогресс", .italian: "Tieni traccia dei tuoi progressi quotidiani"]
        dict[L10n.generateSharingImage] = [.chinese: "生成分享图", .traditionalChinese: "產生分享圖", .english: "Generate Sharing Image", .japanese: "共有イメージの生成", .korean: "공유 이미지 생성", .spanish: "Generar imagen para compartir", .german: "Freigabebild generieren", .russian: "Создать изображение для общего доступа", .italian: "Genera immagine di condivisione"]
        dict[L10n.km] = [.chinese: "公里", .traditionalChinese: "公里", .english: "km", .japanese: "km", .korean: "킬로미터", .spanish: "kilómetros", .german: "km", .russian: "км", .italian: "km"]
        dict[L10n.m] = [.chinese: "米", .traditionalChinese: "米", .english: "m", .japanese: "メートル", .korean: "엠", .spanish: "m", .german: "m", .russian: "м", .italian: "m"]
        dict[L10n.mins] = [.chinese: "分钟", .traditionalChinese: "分分鐘", .english: "mins", .japanese: "分", .korean: "분", .spanish: "minutos", .german: "Min", .russian: "минут", .italian: "min"]
        dict[L10n.hours] = [.chinese: "小时", .traditionalChinese: "小時", .english: "hours", .japanese: "時間", .korean: "시간", .spanish: "horas", .german: "Stunden", .russian: "часы", .italian: "ore"]
        dict[L10n.times1] = [.chinese: "次", .traditionalChinese: "次", .english: "times", .japanese: "回", .korean: "배", .spanish: "veces", .german: "Zeiten", .russian: "раз", .italian: "volte"]
        dict[L10n.pages] = [.chinese: "页", .traditionalChinese: "頁", .english: "pages", .japanese: "ページ", .korean: "페이지", .spanish: "paginas", .german: "Seiten", .russian: "страницы", .italian: "pagine"]
        dict[L10n.days] = [.chinese: "天", .traditionalChinese: "天", .english: "days", .japanese: "日", .korean: "일", .spanish: "dias", .german: "Tage", .russian: "дни", .italian: "giorni"]
        dict[L10n.week] = [.chinese: "周", .traditionalChinese: "週", .english: "week", .japanese: "週", .korean: "주", .spanish: "semana", .german: "Woche", .russian: "неделя", .italian: "settimana"]
        dict[L10n.thisWeek] = [.chinese: "本周", .traditionalChinese: "本週", .english: "This Week", .japanese: "今週", .korean: "이번 주", .spanish: "Esta semana", .german: "Diese Woche", .russian: "На этой неделе", .italian: "Questa settimana"]
        dict[L10n.thisMonth] = [.chinese: "本月", .traditionalChinese: "本月", .english: "This Month", .japanese: "今月", .korean: "이번 달", .spanish: "este mes", .german: "Diesen Monat", .russian: "В этом месяце", .italian: "Questo mese"]
        dict[L10n.month] = [.chinese: "月", .traditionalChinese: "月", .english: "month", .japanese: "月", .korean: "달", .spanish: "mes", .german: "Monat", .russian: "месяц", .italian: "mese"]
        dict[L10n.appLocked] = [.chinese: "应用已锁定", .traditionalChinese: "應用程式已鎖定", .english: "App Locked", .japanese: "アプリがロックされました", .korean: "앱이 잠겼습니다.", .spanish: "Aplicación bloqueada", .german: "App gesperrt", .russian: "Приложение заблокировано", .italian: "Applicazione bloccata"]
        dict[L10n.unlock] = [.chinese: "解锁", .traditionalChinese: "解鎖", .english: "Unlock", .japanese: "ロックを解除する", .korean: "잠금 해제", .spanish: "Desbloquear", .german: "Entsperren", .russian: "Разблокировать", .italian: "Sblocca"]
        dict[L10n.unlockTickday] = [.chinese: "解锁 TickDay", .traditionalChinese: "解鎖 TickDay", .english: "Unlock TickDay", .japanese: "TickDayのロックを解除する", .korean: "TickDay 잠금 해제", .spanish: "Desbloquear TickDay", .german: "Schalte TickDay frei", .russian: "Разблокировать TickDay", .italian: "Sblocca TickDay"]
        dict[L10n.restore] = [.chinese: "恢复购买", .traditionalChinese: "恢復購買", .english: "Restore", .japanese: "復元", .korean: "복원", .spanish: "Restaurar", .german: "Wiederherstellen", .russian: "Восстановить", .italian: "Ripristina"]
        dict[L10n.monthlyCard] = [.chinese: "月度卡", .traditionalChinese: "月度卡", .english: "Monthly Card", .japanese: "マンスリーカード", .korean: "월간 카드", .spanish: "Tarjeta Mensual", .german: "Monatskarte", .russian: "Ежемесячная карта", .italian: "Carta mensile"]
        dict[L10n.yearlyCard] = [.chinese: "年度卡", .traditionalChinese: "年度卡", .english: "Yearly Card", .japanese: "年間カード", .korean: "연간 카드", .spanish: "Tarjeta Anual", .german: "Jahreskarte", .russian: "Годовая карта", .italian: "Carta annuale"]
        dict[L10n.lifetimeCard] = [.chinese: "终身卡", .traditionalChinese: "終身卡", .english: "Lifetime Card", .japanese: "ライフタイムカード", .korean: "평생 카드", .spanish: "Tarjeta de por vida", .german: "Lebenslange Karte", .russian: "Пожизненная карта", .italian: "Carta a vita"]
        dict[L10n.startFreeTrial] = [.chinese: "开始免费试用", .traditionalChinese: "開始免費試用", .english: "Start Free Trial", .japanese: "無料トライアルを開始する", .korean: "무료 평가판 시작", .spanish: "Iniciar prueba gratuita", .german: "Kostenlose Testversion starten", .russian: "Начать бесплатную пробную версию", .italian: "Inizia la prova gratuita"]
        dict[L10n.purchaseNow] = [.chinese: "立即购买", .traditionalChinese: "立即購買", .english: "Purchase Now", .japanese: "今すぐ購入", .korean: "지금 구매", .spanish: "Compra ahora", .german: "Jetzt kaufen", .russian: "Купить сейчас", .italian: "Acquista ora"]
        dict[L10n.waitASpecialOffer] = [.chinese: "等一下，送您一份专属优惠！", .traditionalChinese: "等一下，送您一份專屬優惠！", .english: "Wait, a special offer!", .japanese: "待ってください、特別オファーです！", .korean: "잠깐만요, 특별 제안이요!", .spanish: "Espera, ¡una oferta especial!", .german: "Warten Sie, ein Sonderangebot!", .russian: "Подождите, специальное предложение!", .italian: "Aspetta, un'offerta speciale!"]
        dict[L10n.claimYearlyDiscount] = [.chinese: "领取年度卡折扣", .traditionalChinese: "領取年度卡折扣", .english: "Claim Yearly Discount", .japanese: "年間割引を請求する", .korean: "연간 할인 청구", .spanish: "Reclamar descuento anual", .german: "Fordern Sie einen Jahresrabatt an", .russian: "Получить годовую скидку", .italian: "Richiedi lo sconto annuale"]
        dict[L10n.noThanks] = [.chinese: "残忍拒绝", .traditionalChinese: "殘忍拒絕", .english: "No, thanks", .japanese: "いいえ、ありがとう", .korean: "아니요, 감사합니다", .spanish: "No, gracias", .german: "Nein, danke", .russian: "Нет, спасибо", .italian: "No, grazie"]
        dict[L10n.cancelAnytimeDuringTrial] = [.chinese: "试用期间随时取消", .traditionalChinese: "試用期間隨時取消", .english: "Cancel anytime during trial", .japanese: "お試し期間中はいつでもキャンセル可能", .korean: "평가판 기간 중 언제든지 취소", .spanish: "Cancelar en cualquier momento durante la prueba", .german: "Während der Testphase jederzeit kündbar", .russian: "Отменить в любой момент во время пробного периода", .italian: "Annulla in qualsiasi momento durante il periodo di prova"]
        dict[L10n.adFreeExperience] = [.chinese: "纯净无广告", .traditionalChinese: "純淨無廣告", .english: "Ad-Free Experience", .japanese: "広告なしのエクスペリエンス", .korean: "광고 없는 경험", .spanish: "Experiencia sin publicidad", .german: "Werbefreies Erlebnis", .russian: "Опыт без рекламы", .italian: "Esperienza senza pubblicità"]
        dict[L10n.reduceTheResistanceToYourDailyHabits] = [.chinese: "降低坚持的阻力", .traditionalChinese: "降低堅持的阻力", .english: "Reduce the resistance to your daily habits.", .japanese: "日々の習慣に対する抵抗感を軽減します。", .korean: "일상 습관에 대한 저항을 줄이십시오.", .spanish: "Reduce la resistencia a tus hábitos diarios.", .german: "Reduzieren Sie den Widerstand gegen Ihre täglichen Gewohnheiten.", .russian: "Уменьшите сопротивление своим повседневным привычкам.", .italian: "Riduci la resistenza alle tue abitudini quotidiane."]
        dict[L10n.enterData] = [.chinese: "录入打卡数据", .traditionalChinese: "錄入打卡數據", .english: "Enter Data", .japanese: "データの入力", .korean: "데이터 입력", .spanish: "Introducir datos", .german: "Geben Sie Daten ein", .russian: "Введите данные", .italian: "Inserisci i dati"]
        dict[L10n.editData] = [.chinese: "修改打卡数据", .traditionalChinese: "修改打卡數據", .english: "Edit Data", .japanese: "データの編集", .korean: "데이터 편집", .spanish: "Editar datos", .german: "Daten bearbeiten", .russian: "Редактировать данные", .italian: "Modifica dati"]
        dict[L10n.periodTarget] = [.chinese: "本周期目标: ", .traditionalChinese: "本週期目標:", .english: "Period Target: ", .japanese: "期間対象：", .korean: "기간 목표:", .spanish: "Objetivo del período:", .german: "Zeitraumziel:", .russian: "Цель периода:", .italian: "Obiettivo del periodo:"]
        dict[L10n.periodTotal] = [.chinese: "本周期已累计: ", .traditionalChinese: "本週期已累計:", .english: "Period Total: ", .japanese: "期間合計:", .korean: "총 기간:", .spanish: "Total del período:", .german: "Periodensumme:", .russian: "Итого за период:", .italian: "Totale periodo:"]
        dict[L10n.amountCompleted] = [.chinese: "本次完成量", .traditionalChinese: "本次完成量", .english: "Amount Completed", .japanese: "完了金額", .korean: "완료금액", .spanish: "Cantidad completada", .german: "Betrag abgeschlossen", .russian: "Сумма завершена", .italian: "Importo completato"]
        dict[L10n.undoCheckIn] = [.chinese: "撤销打卡", .traditionalChinese: "撤銷打卡", .english: "Undo Check-in", .japanese: "チェックインを元に戻す", .korean: "체크인 취소", .spanish: "Deshacer registro", .german: "Check-in rückgängig machen", .russian: "Отменить регистрацию", .italian: "Annulla il check-in"]
        dict[L10n.editAmount] = [.chinese: "修改数值", .traditionalChinese: "修改數值", .english: "Edit Amount", .japanese: "金額の編集", .korean: "금액 수정", .spanish: "Editar cantidad", .german: "Betrag bearbeiten", .russian: "Изменить сумму", .italian: "Modifica importo"]
        dict[L10n.total] = [.chinese: "累计", .traditionalChinese: "累計", .english: " Total", .japanese: "合計", .korean: "합계", .spanish: "totales", .german: "Insgesamt", .russian: "Итого", .italian: "Totale"]
        dict[L10n.achieved] = [.chinese: "已达成！", .traditionalChinese: "已達成！", .english: " Achieved!", .japanese: "達成しました！", .korean: "달성했습니다!", .spanish: "¡Logrado!", .german: "Erreicht!", .russian: "Достигнуто!", .italian: "Raggiunto!"]
        dict[L10n.options] = [.chinese: "操作", .traditionalChinese: "操作", .english: "Options", .japanese: "オプション", .korean: "옵션", .spanish: "Opciones", .german: "Optionen", .russian: "Опции", .italian: "Opzioni"]
        dict[L10n.checkInSuccessful] = [.chinese: "打卡成功", .traditionalChinese: "打卡成功", .english: "Check-in Successful", .japanese: "チェックイン成功", .korean: "체크인 성공", .spanish: "Registro exitoso", .german: "Check-in erfolgreich", .russian: "Регистрация прошла успешно", .italian: "Check-in riuscito"]
        dict[L10n.hideArchived] = [.chinese: "隐藏归档", .traditionalChinese: "隱藏歸檔", .english: "Hide Archived", .japanese: "アーカイブを非表示にする", .korean: "보관된 항목 숨기기", .spanish: "Ocultar Archivado", .german: "Archiviert ausblenden", .russian: "Скрыть в архиве", .italian: "Nascondi archiviato"]
        dict[L10n.statisticsOverview] = [.chinese: "统计概览", .traditionalChinese: "統計概覽", .english: "Statistics Overview", .japanese: "統計の概要", .korean: "통계 개요", .spanish: "Resumen de estadísticas", .german: "Statistikübersicht", .russian: "Обзор статистики", .italian: "Panoramica delle statistiche"]
        dict[L10n.firstMonthFree] = [.chinese: "首月免费", .traditionalChinese: "第一個月免費", .english: "First Month Free", .japanese: "初月無料", .korean: "첫 달 무료", .spanish: "Primer mes gratis", .german: "Erster Monat kostenlos", .russian: "Первый месяц бесплатно", .italian: "Primo mese gratuito"]
        dict[L10n.habitName] = [.chinese: "习惯名称", .traditionalChinese: "習慣名稱", .english: "Habit Name", .japanese: "習慣名", .korean: "습관 이름", .spanish: "Nombre del hábito", .german: "Gewohnheitsname", .russian: "Название привычки", .italian: "Nome dell'abitudine"]
        dict[L10n.colorAndIcon] = [.chinese: "颜色和图标", .traditionalChinese: "顏色和圖標", .english: "Color and Icon", .japanese: "色とアイコン", .korean: "색상 및 아이콘", .spanish: "Color e icono", .german: "Farbe und Symbol", .russian: "Цвет и значок", .italian: "Colore e icona"]
        dict[L10n.color] = [.chinese: "颜色", .traditionalChinese: "顏色", .english: "Color", .japanese: "色", .korean: "색상", .spanish: "Color", .german: "Farbe", .russian: "Цвет", .italian: "Colore"]
        dict[L10n.icon] = [.chinese: "图标", .traditionalChinese: "圖示", .english: "Icon", .japanese: "アイコン", .korean: "아이콘", .spanish: "Icono", .german: "Symbol", .russian: "Значок", .italian: "Icona"]
        dict[L10n.goalRules] = [.chinese: "目标规则", .traditionalChinese: "目標規則", .english: "Goal Rules", .japanese: "目標ルール", .korean: "목표 규칙", .spanish: "Reglas de objetivos", .german: "Zielregeln", .russian: "Правила целей", .italian: "Regole dell'obiettivo"]
        dict[L10n.times2] = [.chinese: "次", .traditionalChinese: "次", .english: " Times", .japanese: "回", .korean: "타임즈", .spanish: "tiempos", .german: "Zeiten", .russian: "Время", .italian: "Tempi"]
        dict[L10n.month1] = [.chinese: "月", .traditionalChinese: "月", .english: " Month", .japanese: "月", .korean: "월", .spanish: "Mes", .german: "Monat", .russian: "Месяц", .italian: "Mese"]
        dict[L10n.year] = [.chinese: " 年", .traditionalChinese: "年", .english: " Year", .japanese: "年", .korean: "연도", .spanish: "Año", .german: "Jahr", .russian: "Год", .italian: "Anno"]
        dict[L10n.target] = [.chinese: "目标: ", .traditionalChinese: "目標:", .english: "Target: ", .japanese: "対象:", .korean: "대상:", .spanish: "Objetivo:", .german: "Ziel:", .russian: "Цель:", .italian: "Obiettivo:"]
        dict[L10n.timesWeek] = [.chinese: "次/周", .traditionalChinese: "次/週", .english: " Times/Week", .japanese: "週あたりの回数", .korean: "횟수/주", .spanish: "Horarios/Semana", .german: "Zeiten/Woche", .russian: "Раз/неделю", .italian: "Orari/settimana"]
        dict[L10n.statistics] = [.chinese: "统计数据", .traditionalChinese: "統計數據", .english: "Statistics", .japanese: "統計", .korean: "통계", .spanish: "Estadísticas", .german: "Statistiken", .russian: "Статистика", .italian: "Statistiche"]
        dict[L10n.yearlyCalendar] = [.chinese: "年度日历", .traditionalChinese: "年度日曆", .english: "Yearly Calendar", .japanese: "年間カレンダー", .korean: "연간 달력", .spanish: "Calendario anual", .german: "Jahreskalender", .russian: "Годовой календарь", .italian: "Calendario annuale"]
        dict[L10n.dataIrrecoverableAfterDeletion] = [.chinese: "删除后所有相关打卡数据将无法恢复。", .traditionalChinese: "刪除後所有相關打卡資料將無法恢復。", .english: "Data irrecoverable after deletion.", .japanese: "削除後はデータを復元できません。", .korean: "삭제 후에는 데이터를 복구할 수 없습니다.", .spanish: "Datos irrecuperables después de la eliminación.", .german: "Nach der Löschung sind die Daten unwiederbringlich.", .russian: "Данные не подлежат восстановлению после удаления.", .italian: "Dati irrecuperabili dopo la cancellazione."]
        dict[L10n.checkInDays] = [.chinese: "打卡天数", .traditionalChinese: "打卡天數", .english: "Check-in Days", .japanese: "チェックイン日", .korean: "체크인 날짜", .spanish: "Días de check-in", .german: "Check-in-Tage", .russian: "Дни заезда", .italian: "Giorni di check-in"]
        dict[L10n.checkInAmount] = [.chinese: "打卡数量", .traditionalChinese: "打卡數量", .english: "Check-in Amount", .japanese: "チェックイン金額", .korean: "체크인 금액", .spanish: "Importe del check-in", .german: "Check-in-Betrag", .russian: "Сумма регистрации", .italian: "Importo del check-in"]
        dict[L10n.checkInRecords] = [.chinese: "打卡记录", .traditionalChinese: "打卡記錄", .english: "Check-in Records", .japanese: "チェックイン記録", .korean: "체크인 기록", .spanish: "Registros de check-in", .german: "Check-in-Aufzeichnungen", .russian: "Записи о регистрации", .italian: "Registri di check-in"]
        dict[L10n.noCheckInRecords] = [.chinese: "暂无打卡记录", .traditionalChinese: "暫無打卡紀錄", .english: "No check-in records", .japanese: "チェックイン記録がありません", .korean: "체크인 기록이 없습니다", .spanish: "Sin registros de check-in", .german: "Keine Check-in-Aufzeichnungen", .russian: "Нет записей о заездах", .italian: "Nessun record di check-in"]
        dict[L10n.noCheckInsOnThisDay] = [.chinese: "当日无打卡记录", .traditionalChinese: "當天無打卡記錄", .english: "No check-ins on this day", .japanese: "この日はチェックインはできません", .korean: "이날은 체크인 불가", .spanish: "No hay registros en este día", .german: "An diesem Tag ist kein Check-in möglich", .russian: "В этот день заездов нет", .italian: "Nessun check-in in questo giorno"]
        dict[L10n.noData] = [.chinese: "暂无数据", .traditionalChinese: "暫無數據", .english: "No data", .japanese: "データなし", .korean: "데이터 없음", .spanish: "Sin datos", .german: "Keine Daten", .russian: "Нет данных", .italian: "Nessun dato"]
        dict[L10n.noDataForThisWeek] = [.chinese: "本周暂无数据", .traditionalChinese: "本週暫無數據", .english: "No data for this week.", .japanese: "今週のデータはありません。", .korean: "이번주 데이터가 없습니다.", .spanish: "No hay datos para esta semana.", .german: "Keine Daten für diese Woche.", .russian: "Данных за эту неделю нет.", .italian: "Nessun dato per questa settimana."]
        dict[L10n.beautifulChangesBeginToday] = [.chinese: "美好的改变，从今天开始", .traditionalChinese: "美好的改變，從今天開始", .english: "Beautiful changes begin today", .japanese: "美しい変化が今日始まります", .korean: "아름다운 변화는 오늘부터 시작됩니다", .spanish: "Hermosos cambios comienzan hoy", .german: "Heute beginnen schöne Veränderungen", .russian: "Красивые перемены начинаются сегодня", .italian: "Bellissimi cambiamenti iniziano oggi"]
        dict[L10n.letSCreateYourFirstHabit] = [.chinese: "开启你的第一个小习惯吧", .traditionalChinese: "開啟你的第一個小習慣吧", .english: "Let's create your first habit", .japanese: "最初の習慣を作りましょう", .korean: "첫 번째 습관을 만들어보자", .spanish: "Creemos tu primer hábito", .german: "Lass uns deine erste Gewohnheit schaffen", .russian: "Давайте создадим вашу первую привычку", .italian: "Creiamo la tua prima abitudine"]
        dict[L10n.createFirstHabit] = [.chinese: "创建第一个习惯", .traditionalChinese: "創建第一個習慣", .english: "Create First Habit", .japanese: "最初の習慣を作る", .korean: "첫 번째 습관 만들기", .spanish: "Crea el primer hábito", .german: "Schaffen Sie eine erste Gewohnheit", .russian: "Создайте первую привычку", .italian: "Crea la prima abitudine"]
        dict[L10n.helpSupport] = [.chinese: "帮助与反馈", .traditionalChinese: "幫助與回饋", .english: "Help & Support", .japanese: "ヘルプとサポート", .korean: "도움말 및 지원", .spanish: "Ayuda y soporte", .german: "Hilfe und Support", .russian: "Помощь и поддержка", .italian: "Aiuto e supporto"]
        dict[L10n.habitDetails] = [.chinese: "习惯详情", .traditionalChinese: "習慣詳情", .english: "Habit Details", .japanese: "習慣の詳細", .korean: "습관 세부정보", .spanish: "Detalles del hábito", .german: "Gewohnheitsdetails", .russian: "Детали привычки", .italian: "Dettagli dell'abitudine"]
        dict[L10n.notificationPermissionRequired] = [.chinese: "需要通知权限", .traditionalChinese: "需要通知權限", .english: "Notification Permission Required", .japanese: "通知許可が必要です", .korean: "알림 권한 필요", .spanish: "Se requiere permiso de notificación", .german: "Benachrichtigungsberechtigung erforderlich", .russian: "Требуется разрешение на уведомление", .italian: "Autorizzazione di notifica richiesta"]
        dict[L10n.youHaveDeniedNotificationPermissionsToReceiveCheckInRemindersPleaseEnableThemInSettings] = [.chinese: "您已拒绝通知权限。如需打卡提醒，请前往设置中开启。", .traditionalChinese: "您已拒絕通知權限。如需打卡提醒，請前往設定中開啟。", .english: "You have denied notification permissions. To receive check-in reminders, please enable them in Settings.", .japanese: "通知のアクセス許可を拒否しました。チェックインのリマインダーを受け取るには、設定でリマインダーを有効にしてください。", .korean: "알림 권한을 거부했습니다. 체크인 알림을 받으려면 설정에서 활성화하세요.", .spanish: "Ha denegado los permisos de notificación. Para recibir recordatorios de check-in, habilítelos en Configuración.", .german: "Sie haben die Benachrichtigungsberechtigungen verweigert. Um Check-in-Erinnerungen zu erhalten, aktivieren Sie diese bitte in den Einstellungen.", .russian: "Вы отказали в разрешении на уведомления. Чтобы получать напоминания о регистрации, включите их в настройках.", .italian: "Hai negato le autorizzazioni di notifica. Per ricevere promemoria per il check-in, abilitali nelle Impostazioni."]
        dict[L10n.goToSettings] = [.chinese: "去设置", .traditionalChinese: "去設定", .english: "Go to Settings", .japanese: "設定に移動", .korean: "설정으로 이동", .spanish: "Ir a configuración", .german: "Gehen Sie zu Einstellungen", .russian: "Зайдите в настройки", .italian: "Vai su Impostazioni"]
        dict[L10n.features] = [.chinese: "功能", .traditionalChinese: "功能", .english: "Features", .japanese: "特長", .korean: "특징", .spanish: "Características", .german: "Funktionen", .russian: "Особенности", .italian: "Caratteristiche"]
        dict[L10n.widgets] = [.chinese: "小组件", .traditionalChinese: "小組件", .english: "Widgets", .japanese: "ウィジェット", .korean: "위젯", .spanish: "widgets", .german: "Widgets", .russian: "Виджеты", .italian: "Widget"]
        dict[L10n.addToHomeScreen] = [.chinese: "添加到主屏幕", .traditionalChinese: "新增到主螢幕", .english: "Add to Home Screen", .japanese: "ホーム画面に追加", .korean: "홈 화면에 추가", .spanish: "Agregar a la pantalla de inicio", .german: "Zum Startbildschirm hinzufügen", .russian: "Добавить на главный экран", .italian: "Aggiungi alla schermata principale"]
        dict[L10n.howToAddWidgets] = [.chinese: "如何添加小组件", .traditionalChinese: "如何添加小組件", .english: "How to add Widgets", .japanese: "ウィジェットの追加方法", .korean: "위젯을 추가하는 방법", .spanish: "Cómo agregar widgets", .german: "So fügen Sie Widgets hinzu", .russian: "Как добавить виджеты", .italian: "Come aggiungere widget"]
        dict[L10n.goToYourHomeScreen] = [.chinese: "回到手机主屏幕", .traditionalChinese: "回到手機主螢幕", .english: "Go to your Home Screen.", .japanese: "ホーム画面に移動します。", .korean: "홈 화면으로 이동합니다.", .spanish: "Vaya a su pantalla de inicio.", .german: "Gehen Sie zu Ihrem Startbildschirm.", .russian: "Перейдите на главный экран.", .italian: "Vai alla schermata iniziale."]
        dict[L10n.longPressAnyEmptySpaceUntilAppsJiggle] = [.chinese: "长按主屏幕空白处，直到应用图标开始抖动", .traditionalChinese: "長按主畫面空白處，直到應用程式圖示開始抖動", .english: "Long press any empty space until apps jiggle.", .japanese: "アプリが震えるまで、空いているスペースを長押しします。", .korean: "앱이 흔들릴 때까지 빈 공간을 길게 누릅니다.", .spanish: "Mantenga presionado cualquier espacio vacío hasta que las aplicaciones se muevan.", .german: "Drücken Sie lange auf eine leere Stelle, bis die Apps wackeln.", .russian: "Нажмите и удерживайте любое пустое место, пока приложения не начнут покачиваться.", .italian: "Premi a lungo qualsiasi spazio vuoto finché le app non si muovono."]
        dict[L10n.tapTheButtonInTheTopLeftCorner] = [.chinese: "点击左上角的“+”按钮", .traditionalChinese: "點擊左上角的“+”按鈕", .english: "Tap the '+' button in the top left corner.", .japanese: "左上隅にある「+」ボタンをタップします。", .korean: "왼쪽 상단에 있는 '+' 버튼을 탭하세요.", .spanish: "Toque el botón '+' en la esquina superior izquierda.", .german: "Tippen Sie oben links auf die Schaltfläche „+“.", .russian: "Нажмите кнопку «+» в левом верхнем углу.", .italian: "Tocca il pulsante \"+\" nell'angolo in alto a sinistra."]
        dict[L10n.searchForTickdayAndAddYourFavoriteWidget] = [.chinese: "搜索“TickDay”，选择并添加你喜欢的小组件", .traditionalChinese: "搜尋“TickDay”，選擇並加入你喜歡的小元件", .english: "Search for 'TickDay' and add your favorite widget.", .japanese: "「TickDay」を検索し、お気に入りのウィジェットを追加します。", .korean: "'TickDay'를 검색하고 즐겨찾는 위젯을 추가하세요.", .spanish: "Busque 'TickDay' y agregue su widget favorito.", .german: "Suchen Sie nach „TickDay“ und fügen Sie Ihr Lieblings-Widget hinzu.", .russian: "Найдите «TickDay» и добавьте свой любимый виджет.", .italian: "Cerca \"TickDay\" e aggiungi il tuo widget preferito."]
        dict[L10n.gotIt] = [.chinese: "我知道了", .traditionalChinese: "我知道了", .english: "Got it", .japanese: "わかりました", .korean: "알았어요", .spanish: "Lo tengo", .german: "Verstanden", .russian: "понял", .italian: "Capito"]
        dict[L10n.frequencyGoal] = [.chinese: "次数目标", .traditionalChinese: "次數目標", .english: "Frequency Goal", .japanese: "頻度の目標", .korean: "빈도 목표", .spanish: "Objetivo de frecuencia", .german: "Häufigkeitsziel", .russian: "Целевая частота", .italian: "Obiettivo di frequenza"]
        dict[L10n.amountGoal] = [.chinese: "总量目标", .traditionalChinese: "總量目標", .english: "Amount Goal", .japanese: "目標金額", .korean: "금액 목표", .spanish: "Objetivo de cantidad", .german: "Betragsziel", .russian: "Сумма цели", .italian: "Obiettivo importo"]
        dict[L10n.monthlyTrend] = [.chinese: "月度趋势", .traditionalChinese: "每月趨勢", .english: "Monthly Trend", .japanese: "月次傾向", .korean: "월별 동향", .spanish: "Tendencia mensual", .german: "Monatlicher Trend", .russian: "Ежемесячный тренд", .italian: "Tendenza mensile"]
        dict[L10n.monthlyDetails] = [.chinese: "月度详情", .traditionalChinese: "月度詳情", .english: "Monthly Details", .japanese: "毎月の詳細", .korean: "월간 세부정보", .spanish: "Detalles mensuales", .german: "Monatliche Details", .russian: "Ежемесячная информация", .italian: "Dettagli mensili"]
        dict[L10n.checkInDaysTrend] = [.chinese: "打卡次数趋势", .traditionalChinese: "打卡次數趨勢", .english: "Check-in Days Trend", .japanese: "チェックイン日数の傾向", .korean: "체크인 일자 추세", .spanish: "Tendencia de días de check-in", .german: "Trend der Check-in-Tage", .russian: "Тенденция в днях заезда", .italian: "Andamento dei giorni di check-in"]
        dict[L10n.totalAmountTrend] = [.chinese: "打卡总量趋势", .traditionalChinese: "打卡總量趨勢", .english: "Total Amount Trend", .japanese: "総額推移", .korean: "총액 추이", .spanish: "Tendencia del importe total", .german: "Gesamtbetragstrend", .russian: "Тенденция общей суммы", .italian: "Andamento dell'importo totale"]
        dict[L10n.totalDays] = [.chinese: "累计打卡", .traditionalChinese: "累計打卡", .english: "Total Days", .japanese: "合計日数", .korean: "총 일수", .spanish: "Días totales", .german: "Gesamtzahl der Tage", .russian: "Всего дней", .italian: "Giorni totali"]
        dict[L10n.system] = [.chinese: "系统", .traditionalChinese: "系統", .english: "System", .japanese: "システム", .korean: "시스템", .spanish: "Sistema", .german: "System", .russian: "Система", .italian: "Sistema"]
        dict[L10n.light] = [.chinese: "浅色", .traditionalChinese: "淺色", .english: "Light", .japanese: "ライト", .korean: "빛", .spanish: "Luz", .german: "Licht", .russian: "Свет", .italian: "Luce"]
        dict[L10n.dark] = [.chinese: "深色", .traditionalChinese: "深色", .english: "Dark", .japanese: "暗い", .korean: "어둠", .spanish: "oscuro", .german: "Dunkel", .russian: "Темный", .italian: "Buio"]
        dict[L10n.appearance] = [.chinese: "外观", .traditionalChinese: "外觀", .english: "Appearance", .japanese: "外観", .korean: "외관", .spanish: "Apariencia", .german: "Aussehen", .russian: "Внешний вид", .italian: "Aspetto"]
        dict[L10n.startOfWeek] = [.chinese: "一周开始", .traditionalChinese: "一週開始", .english: "Start of Week", .japanese: "週の始まり", .korean: "주의 시작", .spanish: "Inicio de semana", .german: "Wochenbeginn", .russian: "Начало недели", .italian: "Inizio settimana"]
        dict[L10n.monday] = [.chinese: "周一", .traditionalChinese: "週一", .english: "Monday", .japanese: "月曜日", .korean: "월요일", .spanish: "lunes", .german: "Montag", .russian: "понедельник", .italian: "Lunedì"]
        dict[L10n.sunday] = [.chinese: "周日", .traditionalChinese: "週日", .english: "Sunday", .japanese: "日曜日", .korean: "일요일", .spanish: "domingo", .german: "Sonntag", .russian: "воскресенье", .italian: "Domenica"]
        dict[L10n.cancel] = [.chinese: "取消", .traditionalChinese: "取消", .english: "Cancel", .japanese: "キャンセル", .korean: "취소", .spanish: "Cancelar", .german: "Abbrechen", .russian: "Отмена", .italian: "Annulla"]
        dict[L10n.close] = [.chinese: "关闭", .traditionalChinese: "關閉", .english: "Close", .japanese: "閉じる", .korean: "닫기", .spanish: "Cerrar", .german: "Schließen", .russian: "Закрыть", .italian: "Chiudi"]
        dict[L10n.showCompleted] = [.chinese: "显示已打卡", .traditionalChinese: "顯示已打卡", .english: "Show Completed", .japanese: "完了した番組を表示", .korean: "쇼 완료", .spanish: "Mostrar completado", .german: "Show abgeschlossen", .russian: "Показать завершено", .italian: "Mostra completata"]
        dict[L10n.hideCompleted] = [.chinese: "隐藏已打卡", .traditionalChinese: "隱藏已打卡", .english: "Hide Completed", .japanese: "完了したものを非表示にする", .korean: "완료됨 숨기기", .spanish: "Ocultar completado", .german: "Ausblenden abgeschlossen", .russian: "Скрыть завершенное", .italian: "Nascondi completato"]
        dict[L10n.week1] = [.chinese: "本周", .traditionalChinese: "本週", .english: "Week", .japanese: "週", .korean: "주", .spanish: "Semana", .german: "Woche", .russian: "неделя", .italian: "Settimana"]
        dict[L10n.times3] = [.chinese: "次", .traditionalChinese: "次", .english: " times", .japanese: "回", .korean: "배", .spanish: "veces", .german: "Zeiten", .russian: "раз", .italian: "volte"]
        dict[L10n.time] = [.chinese: "次", .traditionalChinese: "次", .english: " time", .japanese: "時間", .korean: "시간", .spanish: "tiempo", .german: "Zeit", .russian: "время", .italian: "tempo"]
        dict[L10n.generating] = [.chinese: "生成中...", .traditionalChinese: "生成中...", .english: "Generating...", .japanese: "生成中...", .korean: "생성 중...", .spanish: "Generando...", .german: "Generieren...", .russian: "Создание...", .italian: "Generazione..."]
        dict[L10n.today] = [.chinese: "今日", .traditionalChinese: "今日", .english: "Today", .japanese: "今日", .korean: "오늘", .spanish: "hoy", .german: "Heute", .russian: "Сегодня", .italian: "Oggi"]
        dict[L10n.total1] = [.chinese: "累计", .traditionalChinese: "累計", .english: "Total", .japanese: "合計", .korean: "합계", .spanish: "totales", .german: "Insgesamt", .russian: "Итого", .italian: "Totale"]
        dict[L10n.tickday] = [.chinese: "TickDay", .traditionalChinese: "TickDay", .english: "TickDay", .japanese: "ティックデイ", .korean: "틱데이", .spanish: "TickDay", .german: "TickDay", .russian: "ТикДэй", .italian: "TickDay"]
        dict[L10n.today1] = [.chinese: "今天，", .traditionalChinese: "今天，", .english: "Today,", .japanese: "今日、", .korean: "오늘,", .spanish: "Hoy,", .german: "Heute,", .russian: "Сегодня,", .italian: "oggi,"]
        dict[L10n.yesterday] = [.chinese: "昨天，", .traditionalChinese: "昨天，", .english: "Yesterday,", .japanese: "昨日、", .korean: "어제,", .spanish: "ayer,", .german: "Gestern,", .russian: "Вчера,", .italian: "ieri,"]
        dict[L10n.reports] = [.chinese: "报告", .traditionalChinese: "報告", .english: "Reports", .japanese: "レポート", .korean: "보고서", .spanish: "Informes", .german: "Berichte", .russian: "Отчеты", .italian: "Rapporti"]
        dict[L10n.met] = [.chinese: "达成率", .traditionalChinese: "達成率", .english: "Met", .japanese: "会った", .korean: "만난", .spanish: "Cumplió", .german: "Getroffen", .russian: "Встретились", .italian: "Incontrato"]
        dict[L10n.bestDay] = [.chinese: "最佳单日", .traditionalChinese: "最佳單日", .english: "Best Day", .japanese: "最高の一日", .korean: "최고의 날", .spanish: "mejor dia", .german: "Bester Tag", .russian: "Лучший день", .italian: "Giorno migliore"]
        dict[L10n.longestStreak] = [.chinese: "最长连续", .traditionalChinese: "最長連續", .english: "Longest Streak", .japanese: "最長連続記録", .korean: "최장 연속", .spanish: "Racha más larga", .german: "Längster Streak", .russian: "Самая длинная серия", .italian: "Serie più lunga"]
        dict[L10n.done] = [.chinese: "打卡", .traditionalChinese: "打卡", .english: "Done", .japanese: "完了", .korean: "완료", .spanish: "hecho", .german: "Fertig", .russian: "Готово", .italian: "Fatto"]
        dict[L10n.streak] = [.chinese: "连续", .traditionalChinese: "連續", .english: "Streak", .japanese: "ストリーク", .korean: "연속", .spanish: "racha", .german: "Streifen", .russian: "Полоса", .italian: "Striscia"]
        dict[L10n.weeklyGrid] = [.chinese: "本周网格", .traditionalChinese: "本週網格", .english: "Weekly Grid", .japanese: "週間グリッド", .korean: "주간 그리드", .spanish: "Cuadrícula semanal", .german: "Wöchentliches Raster", .russian: "Еженедельная сетка", .italian: "Griglia settimanale"]
        dict[L10n.yourProgress] = [.chinese: "你的进度", .traditionalChinese: "你的進度", .english: "Your Progress", .japanese: "あなたの進歩", .korean: "귀하의 진행 상황", .spanish: "Tu progreso", .german: "Ihr Fortschritt", .russian: "Ваш прогресс", .italian: "I tuoi progressi"]
        dict[L10n.aDetailedLookAtYourJourney] = [.chinese: "详细回顾你的成长之旅。", .traditionalChinese: "詳細回顧你的成長之旅。", .english: "A detailed look at your journey.", .japanese: "あなたの旅行を詳しく見てみましょう。", .korean: "여행을 자세히 살펴보세요.", .spanish: "Una mirada detallada a su viaje.", .german: "Ein detaillierter Blick auf Ihre Reise.", .russian: "Подробный обзор вашего путешествия.", .italian: "Uno sguardo dettagliato al tuo viaggio."]
        dict[L10n.month2] = [.chinese: "本月", .traditionalChinese: "本月", .english: "Month", .japanese: "月", .korean: "월", .spanish: "Mes", .german: "Monat", .russian: "Месяц", .italian: "Mese"]
        dict[L10n.year1] = [.chinese: "本年", .traditionalChinese: "本年", .english: "Year", .japanese: "年", .korean: "연도", .spanish: "Año", .german: "Jahr", .russian: "Год", .italian: "Anno"]
        dict[L10n.weekly] = [.chinese: "周", .traditionalChinese: "週", .english: "Weekly", .japanese: "毎週", .korean: "주간", .spanish: "Semanal", .german: "Wöchentlich", .russian: "Еженедельно", .italian: "Settimanale"]
        dict[L10n.monthly] = [.chinese: "月", .traditionalChinese: "月", .english: "Monthly", .japanese: "毎月", .korean: "월간", .spanish: "Mensual", .german: "Monatlich", .russian: "Ежемесячно", .italian: "Mensile"]
        dict[L10n.yearly] = [.chinese: "年", .traditionalChinese: "年", .english: "Yearly", .japanese: "毎年", .korean: "매년", .spanish: "Anual", .german: "Jährlich", .russian: "Ежегодно", .italian: "Annuale"]
        dict[L10n.all] = [.chinese: "全部", .traditionalChinese: "全部", .english: "All", .japanese: "すべて", .korean: "모두", .spanish: "Todos", .german: "Alle", .russian: "Все", .italian: "Tutto"]
        dict[L10n.weeklyView] = [.chinese: "周视图", .traditionalChinese: "週視圖", .english: "Weekly View", .japanese: "週次表示", .korean: "주간 보기", .spanish: "Vista semanal", .german: "Wochenansicht", .russian: "Еженедельный просмотр", .italian: "Visualizzazione settimanale"]
        dict[L10n.monthlyView] = [.chinese: "月视图", .traditionalChinese: "月視圖", .english: "Monthly View", .japanese: "月次ビュー", .korean: "월별 보기", .spanish: "Vista mensual", .german: "Monatsansicht", .russian: "Ежемесячный просмотр", .italian: "Visualizzazione mensile"]
        dict[L10n.yearlyView] = [.chinese: "年视图", .traditionalChinese: "年視圖", .english: "Yearly View", .japanese: "年間ビュー", .korean: "연간 보기", .spanish: "Vista anual", .german: "Jahresansicht", .russian: "Ежегодный просмотр", .italian: "Visualizzazione annuale"]
        dict[L10n.allView] = [.chinese: "全部视图", .traditionalChinese: "全部視圖", .english: "All View", .japanese: "すべて表示", .korean: "모두보기", .spanish: "Ver todo", .german: "Alle Ansicht", .russian: "Все Посмотреть", .italian: "Tutto Visualizza"]
        dict[L10n.deleteHabit] = [.chinese: "确认删除?", .traditionalChinese: "確認刪除?", .english: "Delete Habit?", .japanese: "習慣を削除しますか？", .korean: "습관을 삭제하시겠습니까?", .spanish: "¿Eliminar el hábito?", .german: "Gewohnheit löschen?", .russian: "Удалить привычку?", .italian: "Eliminare l'abitudine?"]
        dict[L10n.savedToAlbum] = [.chinese: "已保存到相册", .traditionalChinese: "已儲存至相簿", .english: "Saved to Album", .japanese: "アルバムに保存されました", .korean: "앨범에 저장됨", .spanish: "Guardado en el álbum", .german: "Im Album gespeichert", .russian: "Сохранено в альбоме", .italian: "Salvato nell'album"]
        dict[L10n.ok] = [.chinese: "好的", .traditionalChinese: "好的", .english: "OK", .japanese: "OK", .korean: "알았어", .spanish: "bien", .german: "Okay", .russian: "ОК", .italian: "Va bene"]
        dict[L10n.tapInTopLeftSearchTickdayAndTapAddWidget] = [.chinese: "点击左上角的“+”按钮，搜索“TickDay”，点击“添加小组件”按钮", .traditionalChinese: "點擊左上角的“+”按鈕，搜尋“TickDay”，點擊“新增小元件”按鈕", .english: "Tap '+' in top left, search 'TickDay', and tap 'Add Widget'.", .japanese: "左上の「+」をタップし、「TickDay」を検索して「ウィジェットを追加」をタップします。", .korean: "왼쪽 상단의 '+'를 탭하고 'TickDay'를 검색한 후 '위젯 추가'를 탭하세요.", .spanish: "Toca '+' en la parte superior izquierda, busca 'TickDay' y toca 'Agregar widget'.", .german: "Tippen Sie oben links auf „+“, suchen Sie nach „TickDay“ und tippen Sie auf „Widget hinzufügen“.", .russian: "Нажмите «+» в левом верхнем углу, найдите «TickDay» и нажмите «Добавить виджет».", .italian: "Tocca \"+\" in alto a sinistra, cerca \"TickDay\" e tocca \"Aggiungi widget\"."]
        dict[L10n.chooseYourFavoriteWidgetSizeAndPlaceItOnYourHomeScreen] = [.chinese: "选择合适的小组件样式并放置到主屏幕上", .traditionalChinese: "選擇合適的小組件樣式並放置到主螢幕上", .english: "Choose your favorite widget size and place it on your Home Screen.", .japanese: "お気に入りのウィジェット サイズを選択して、ホーム画面に配置します。", .korean: "좋아하는 위젯 크기를 선택하고 홈 화면에 배치하세요.", .spanish: "Elija su tamaño de widget favorito y colóquelo en su pantalla de inicio.", .german: "Wählen Sie Ihre bevorzugte Widget-Größe und platzieren Sie sie auf Ihrem Startbildschirm.", .russian: "Выберите свой любимый размер виджета и поместите его на главный экран.", .italian: "Scegli la dimensione del tuo widget preferito e posizionalo sulla schermata principale."]
        dict[L10n.basicInfo] = [.chinese: "基本信息", .traditionalChinese: "基本訊息", .english: "Basic Info", .japanese: "基本情報", .korean: "기본 정보", .spanish: "Información básica", .german: "Grundlegende Informationen", .russian: "Основная информация", .italian: "Informazioni di base"]
        dict[L10n.habit] = [.chinese: "习惯", .traditionalChinese: "習慣", .english: "Habit", .japanese: "習慣", .korean: "습관", .spanish: "Hábito", .german: "Gewohnheit", .russian: "Привычка", .italian: "Abitudine"]
        dict[L10n.noHabitsFound] = [.chinese: "暂无习惯", .traditionalChinese: "暫無習慣", .english: "No habits found.", .japanese: "習慣は見つかりませんでした。", .korean: "습관이 발견되지 않았습니다.", .spanish: "No se encontraron hábitos.", .german: "Keine Gewohnheiten gefunden.", .russian: "Привычек не обнаружено.", .italian: "Nessuna abitudine trovata."]
        dict[L10n.cumulativeStreak] = [.chinese: "累计连续打卡", .traditionalChinese: "累計連續打卡", .english: "Cumulative Streak", .japanese: "累積連続記録", .korean: "누적 연속", .spanish: "Racha acumulativa", .german: "Kumulativer Streik", .russian: "Совокупная полоса", .italian: "Serie cumulativa"]
        dict[L10n.top5] = [.chinese: "前 5%", .traditionalChinese: "前 5%", .english: "Top 5%", .japanese: "上位 5%", .korean: "상위 5%", .spanish: "5% superior", .german: "Top 5 %", .russian: "Топ 5%", .italian: "Migliori 5%"]
        dict[L10n.daysOfContinuousGrowth] = [.chinese: "天连续成长", .traditionalChinese: "天連續成長", .english: "Days of continuous growth", .japanese: "成長を続ける日々", .korean: "지속적인 성장의 날들", .spanish: "Días de crecimiento continuo", .german: "Tage kontinuierlichen Wachstums", .russian: "Дни непрерывного роста", .italian: "Giorni di crescita continua"]
        dict[L10n.consistencyMap] = [.chinese: "连续性热力图", .traditionalChinese: "連續性熱力圖", .english: "Consistency Map", .japanese: "一貫性マップ", .korean: "일관성 맵", .spanish: "Mapa de coherencia", .german: "Konsistenzkarte", .russian: "Карта согласованности", .italian: "Mappa di coerenza"]
        dict[L10n.less] = [.chinese: "少", .traditionalChinese: "少", .english: "Less", .japanese: "少ない", .korean: "덜", .spanish: "menos", .german: "Weniger", .russian: "Меньше", .italian: "Meno"]
        dict[L10n.more] = [.chinese: "多", .traditionalChinese: "多", .english: "More", .japanese: "もっと見る", .korean: "더보기", .spanish: "Más", .german: "Mehr", .russian: "Подробнее", .italian: "Di più"]
        dict[L10n.habitDistribution] = [.chinese: "习惯分布", .traditionalChinese: "習慣分佈", .english: "Habit Distribution", .japanese: "習慣の分布", .korean: "습관 분포", .spanish: "Distribución de hábitos", .german: "Gewohnheitsverteilung", .russian: "Распределение привычек", .italian: "Distribuzione delle abitudini"]
        dict[L10n.mind] = [.chinese: "心灵", .traditionalChinese: "心靈", .english: "Mind", .japanese: "心", .korean: "마음", .spanish: "Mente", .german: "Verstand", .russian: "Разум", .italian: "Mente"]
        dict[L10n.body] = [.chinese: "身体", .traditionalChinese: "身體", .english: "Body", .japanese: "本体", .korean: "본체", .spanish: "cuerpo", .german: "Körper", .russian: "Тело", .italian: "Corpo"]
        dict[L10n.soul] = [.chinese: "灵魂", .traditionalChinese: "靈魂", .english: "Soul", .japanese: "ソウル", .korean: "소울", .spanish: "alma", .german: "Seele", .russian: "Душа", .italian: "Anima"]
        dict[L10n.mon] = [.chinese: "一", .traditionalChinese: "一", .english: "Mon", .japanese: "月", .korean: "월", .spanish: "lun", .german: "Mo", .russian: "Пн.", .italian: "Lun"]
        dict[L10n.tue] = [.chinese: "二", .traditionalChinese: "二", .english: "Tue", .japanese: "火", .korean: "화요일", .spanish: "mar", .german: "Di", .russian: "Вт", .italian: "Mar"]
        dict[L10n.wed] = [.chinese: "三", .traditionalChinese: "三", .english: "Wed", .japanese: "水", .korean: "수요일", .spanish: "mié", .german: "Mi", .russian: "ср.", .italian: "Mercoledì"]
        dict[L10n.thu] = [.chinese: "四", .traditionalChinese: "四", .english: "Thu", .japanese: "木", .korean: "목", .spanish: "jueves", .german: "Do", .russian: "Чт", .italian: "Gio"]
        dict[L10n.fri] = [.chinese: "五", .traditionalChinese: "五", .english: "Fri", .japanese: "金", .korean: "금", .spanish: "viernes", .german: "Fr", .russian: "Пт", .italian: "Ven"]
        dict[L10n.sat] = [.chinese: "六", .traditionalChinese: "六", .english: "Sat", .japanese: "土", .korean: "토요일", .spanish: "sábado", .german: "Sa", .russian: "Суббота", .italian: "Sab"]
        dict[L10n.sun] = [.chinese: "日", .traditionalChinese: "日", .english: "Sun", .japanese: "太陽", .korean: "태양", .spanish: "sol", .german: "Sonne", .russian: "Солнце", .italian: "Sole"]
        dict[L10n.daysStreak] = [.chinese: "天连续", .traditionalChinese: "天連續", .english: "Days Streak", .japanese: "連続日数", .korean: "연속 일수", .spanish: "Racha de días", .german: "Tagesträhne", .russian: "Дней подряд", .italian: "Serie di giorni"]
        dict[L10n._30Days] = [.chinese: "近30天", .traditionalChinese: "近30天", .english: "30 Days", .japanese: "30日", .korean: "30일", .spanish: "30 dias", .german: "30 Tage", .russian: "30 дней", .italian: "30 giorni"]
        dict[L10n.delete] = [.chinese: "删除", .traditionalChinese: "刪除", .english: "Delete", .japanese: "削除", .korean: "삭제", .spanish: "Eliminar", .german: "Löschen", .russian: "Удалить", .italian: "Elimina"]
        dict[L10n.archive] = [.chinese: "归档", .traditionalChinese: "歸檔", .english: "Archive", .japanese: "アーカイブ", .korean: "아카이브", .spanish: "Archivo", .german: "Archiv", .russian: "Архив", .italian: "Archivio"]
        dict[L10n.settings] = [.chinese: "设置", .traditionalChinese: "設定", .english: "Settings", .japanese: "設定", .korean: "설정", .spanish: "Configuración", .german: "Einstellungen", .russian: "Настройки", .italian: "Impostazioni"]
        dict[L10n.developerTestOnly] = [.chinese: "开发者 (仅供测试)", .traditionalChinese: "開發者 (僅供測試)", .english: "Developer (Test Only)", .japanese: "開発者 (テストのみ)", .korean: "개발자(테스트 전용)", .spanish: "Desarrollador (solo prueba)", .german: "Entwickler (nur Test)", .russian: "Разработчик (только тестирование)", .italian: "Sviluppatore (solo test)"]
        dict[L10n.mockPremiumStatus] = [.chinese: "模拟高级版状态", .traditionalChinese: "模擬高級版狀態", .english: "Mock Premium Status", .japanese: "プレミアムステータスのモックアップ", .korean: "모의 프리미엄 상태", .spanish: "Estado premium simulado", .german: "Schein-Premium-Status", .russian: "Ложный премиум-статус", .italian: "Stato Premium simulato"]
        dict[L10n.tickdayPremium] = [.chinese: "TickDay 高级版", .traditionalChinese: "TickDay 高級版", .english: "TickDay Premium", .japanese: "TickDay プレミアム", .korean: "틱데이 프리미엄", .spanish: "TickDay Premium", .german: "TickDay Premium", .russian: "ТикДэй Премиум", .italian: "TickDay Premium"]
        dict[L10n.unlockYourFullPotential] = [.chinese: "解锁所有特权与功能", .traditionalChinese: "解鎖所有特權與功能", .english: "Unlock your full potential", .japanese: "あなたの可能性を最大限に解き放ちます", .korean: "잠재력을 최대한 발휘하세요", .spanish: "Libera todo tu potencial", .german: "Entfalten Sie Ihr volles Potenzial", .russian: "Раскройте весь свой потенциал", .italian: "Sblocca il tuo pieno potenziale"]
        dict[L10n.themeColors] = [.chinese: "自定义主题", .traditionalChinese: "自訂主題", .english: "Theme Colors", .japanese: "テーマカラー", .korean: "테마 색상", .spanish: "Colores del tema", .german: "Themenfarben", .russian: "Цвета темы", .italian: "Colori del tema"]
        dict[L10n.personalizeYourAppWithCustomColors] = [.chinese: "丰富的主题色彩个性化你的应用", .traditionalChinese: "豐富的主題色彩個性化你的應用", .english: "Personalize your app with custom colors", .japanese: "カスタムカラーでアプリをパーソナライズする", .korean: "맞춤 색상으로 앱을 맞춤설정하세요.", .spanish: "Personaliza tu aplicación con colores personalizados", .german: "Personalisieren Sie Ihre App mit benutzerdefinierten Farben", .russian: "Персонализируйте свое приложение с помощью пользовательских цветов", .italian: "Personalizza la tua app con colori personalizzati"]
        dict[L10n.darkMode] = [.chinese: "深色模式", .traditionalChinese: "深色模式", .english: "Dark Mode", .japanese: "ダークモード", .korean: "다크 모드", .spanish: "Modo oscuro", .german: "Dunkler Modus", .russian: "Темный режим", .italian: "Modalità oscura"]
        dict[L10n.reduceEyeStrainWithASleekDarkTheme] = [.chinese: "时尚的深色主题，缓解眼睛疲劳", .traditionalChinese: "時尚的深色主題，緩解眼睛疲勞", .english: "Reduce eye strain with a sleek dark theme", .japanese: "洗練されたダークテーマで目の疲れを軽減", .korean: "세련된 어두운 테마로 눈의 피로를 줄여보세요", .spanish: "Reduzca la fatiga visual con un elegante tema oscuro", .german: "Reduzieren Sie die Belastung Ihrer Augen mit einem eleganten, dunklen Thema", .russian: "Уменьшите нагрузку на глаза с помощью стильной темной темы.", .italian: "Riduci l'affaticamento degli occhi con un elegante tema scuro"]
        dict[L10n.protectYourHabitsWithFaceIdTouchId] = [.chinese: "使用 Face ID 或 Touch ID 保护你的隐私", .traditionalChinese: "使用 Face ID 或 Touch ID 保護你的隱私", .english: "Protect your habits with Face ID / Touch ID", .japanese: "Face ID / Touch ID で習慣を守る", .korean: "Face ID/Touch ID로 습관을 보호하세요", .spanish: "Protege tus hábitos con Face ID / Touch ID", .german: "Schützen Sie Ihre Gewohnheiten mit Face ID / Touch ID", .russian: "Защитите свои привычки с помощью Face ID/Touch ID", .italian: "Proteggi le tue abitudini con Face ID/Touch ID"]
        dict[L10n.unlimitedHabits] = [.chinese: "无限习惯", .traditionalChinese: "無限習慣", .english: "Unlimited Habits", .japanese: "無制限の習慣", .korean: "무제한의 습관", .spanish: "Hábitos ilimitados", .german: "Unbegrenzte Gewohnheiten", .russian: "Неограниченные привычки", .italian: "Abitudini illimitate"]
        dict[L10n.createAsManyHabitsAsYouWantFreeVersionMax5] = [.chinese: "突破限制，创建任意数量的习惯（免费版最多5个）", .traditionalChinese: "突破限制，創造任意數量的習慣（免費版最多5個）", .english: "Create as many habits as you want (Free version max 5)", .japanese: "好きなだけ習慣を作成できます (無料版では最大 5 つ)", .korean: "원하는 만큼 습관을 만드세요(무료 버전 최대 5개)", .spanish: "Crea tantos hábitos como quieras (versión gratuita máximo 5)", .german: "Erstellen Sie so viele Gewohnheiten, wie Sie möchten (maximal 5 kostenlose Version)", .russian: "Создайте столько привычек, сколько хотите (в бесплатной версии максимум 5)", .italian: "Crea tutte le abitudini che vuoi (Versione gratuita max 5)"]
        dict[L10n.importExportData] = [.chinese: "导入 / 导出数据", .traditionalChinese: "導入 / 匯出數據", .english: "Import / Export Data", .japanese: "データのインポート/エクスポート", .korean: "데이터 가져오기/내보내기", .spanish: "Importar/Exportar datos", .german: "Daten importieren/exportieren", .russian: "Импорт/экспорт данных", .italian: "Importa/Esporta dati"]
        dict[L10n.backupToExcelImportFromOtherApps] = [.chinese: "备份到 Excel 文件，并支持导入其他 app 打卡记录", .traditionalChinese: "備份到 Excel 文件，並支援匯入其他 app 打卡記錄", .english: "Backup to Excel & import from other apps", .japanese: "Excel へのバックアップと他のアプリからのインポート", .korean: "Excel로 백업 및 다른 앱에서 가져오기", .spanish: "Copia de seguridad en Excel e importación desde otras aplicaciones", .german: "In Excel sichern und aus anderen Apps importieren", .russian: "Резервное копирование в Excel и импорт из других приложений", .italian: "Backup su Excel e importazione da altre app"]
        dict[L10n.keepYourHabitsSyncedAcrossAllDevices] = [.chinese: "让你的习惯在所有设备上保持同步", .traditionalChinese: "讓你的習慣在所有裝置上保持同步", .english: "Keep your habits synced across all devices", .japanese: "すべてのデバイス間で習慣を同期させます", .korean: "모든 기기에서 습관을 동기화하세요", .spanish: "Mantenga sus hábitos sincronizados en todos los dispositivos", .german: "Halten Sie Ihre Gewohnheiten auf allen Geräten synchronisiert", .russian: "Синхронизируйте свои привычки на всех устройствах", .italian: "Mantieni le tue abitudini sincronizzate su tutti i dispositivi"]
        dict[L10n.billedMonthly] = [.chinese: "按月扣款", .traditionalChinese: "按月扣款", .english: "Billed monthly", .japanese: "毎月請求される", .korean: "매월 청구됨", .spanish: "Facturado mensualmente", .german: "Wird monatlich abgerechnet", .russian: "Оплата ежемесячно", .italian: "Fatturazione mensile"]
        dict[L10n.billedYearly] = [.chinese: "按年扣款", .traditionalChinese: "按年扣款", .english: "Billed yearly", .japanese: "毎年請求される", .korean: "매년 청구됨", .spanish: "Facturado anualmente", .german: "Jährliche Abrechnung", .russian: "Оплата ежегодно", .italian: "Fatturato annualmente"]
        dict[L10n.cancelAnytimeDuringTrialNoCharge] = [.chinese: "试用期间可以随时取消，不扣费", .traditionalChinese: "試用期間可以隨時取消，不扣費", .english: "Cancel anytime during trial, no charge", .japanese: "お試し中はいつでもキャンセル可能、料金はかかりません", .korean: "체험 기간 중 언제든지 취소 가능, 요금 없음", .spanish: "Cancele en cualquier momento durante la prueba, sin cargo", .german: "Während der Testphase können Sie jederzeit kostenlos kündigen", .russian: "Отмена в любой момент во время пробного периода, бесплатно", .italian: "Annulla in qualsiasi momento durante il periodo di prova, senza alcun costo"]
        dict[L10n.popular] = [.chinese: "最受欢迎", .traditionalChinese: "最受歡迎", .english: "POPULAR", .japanese: "人気のある", .korean: "인기", .spanish: "POPULAR", .german: "BELIEBT", .russian: "ПОПУЛЯРНЫЕ", .italian: "POPOLARE"]
        dict[L10n.lifetime] = [.chinese: "终身买断", .traditionalChinese: "終身買斷", .english: "Lifetime", .japanese: "生涯", .korean: "평생", .spanish: "Toda la vida", .german: "Lebenszeit", .russian: "Срок службы", .italian: "A vita"]
        dict[L10n.limitedTimeOffer] = [.chinese: "限时特惠", .traditionalChinese: "限時特惠", .english: "Limited Time Offer", .japanese: "期間限定オファー", .korean: "기간 한정 제안", .spanish: "Oferta por tiempo limitado", .german: "Zeitlich begrenztes Angebot", .russian: "Ограниченное по времени предложение", .italian: "Offerta a tempo limitato"]
        dict[L10n.oneTimePayment] = [.chinese: "一次性买断", .traditionalChinese: "免一次買斷", .english: "One-time payment", .japanese: "1回払い", .korean: "일회성 결제", .spanish: "Pago único", .german: "Einmalige Zahlung", .russian: "Единовременный платеж", .italian: "Pagamento una tantum"]
        dict[L10n.bestValue] = [.chinese: "最超值", .traditionalChinese: "最超值", .english: "BEST VALUE", .japanese: "ベストバリュー", .korean: "최고의 가치", .spanish: "MEJOR VALOR", .german: "BESTER PREIS", .russian: "ЛУЧШАЯ ЦЕНА", .italian: "MIGLIOR VALORE"]
        dict[L10n.`continue`] = [.chinese: "继续", .traditionalChinese: "繼續", .english: "Continue", .japanese: "続ける", .korean: "계속", .spanish: "Continuar", .german: "Weiter", .russian: "Продолжить", .italian: "Continua"]
        dict[L10n.byContinuingYouAgreeToOur] = [.chinese: "继续即表示您同意我们的", .traditionalChinese: "繼續即表示您同意我們的", .english: "By continuing, you agree to our", .japanese: "続行すると、次のことに同意したことになります", .korean: "계속하면 다음 내용에 동의하게 됩니다.", .spanish: "Al continuar, aceptas nuestra", .german: "Indem Sie fortfahren, stimmen Sie unseren zu", .russian: "Продолжая, вы соглашаетесь с нашими", .italian: "Continuando accetti i ns"]
        dict[L10n.and] = [.chinese: "和", .traditionalChinese: "和", .english: "and", .japanese: "そして", .korean: "그리고", .spanish: "y", .german: "und", .russian: "и", .italian: "e"]
        dict[L10n.appLock] = [.chinese: "应用锁", .traditionalChinese: "應用鎖", .english: "App Lock", .japanese: "アプリロック", .korean: "앱 잠금", .spanish: "Bloqueo de aplicaciones", .german: "App-Sperre", .russian: "Блокировка приложения", .italian: "Blocco dell'app"]
        dict[L10n.data] = [.chinese: "数据", .traditionalChinese: "數據", .english: "Data", .japanese: "データ", .korean: "데이터", .spanish: "Datos", .german: "Daten", .russian: "Данные", .italian: "Dati"]
        dict[L10n.icloudSync] = [.chinese: "iCloud 同步", .traditionalChinese: "iCloud 同步", .english: "iCloud Sync", .japanese: "iCloud同期", .korean: "아이클라우드 동기화", .spanish: "Sincronización de iCloud", .german: "iCloud-Synchronisierung", .russian: "Синхронизация с iCloud", .italian: "Sincronizzazione iCloud"]
        dict[L10n.importData] = [.chinese: "导入数据", .traditionalChinese: "導入數據", .english: "Import Data", .japanese: "データのインポート", .korean: "데이터 가져오기", .spanish: "Importar datos", .german: "Daten importieren", .russian: "Импортировать данные", .italian: "Importa dati"]
        dict[L10n.exportData] = [.chinese: "导出数据", .traditionalChinese: "匯出數據", .english: "Export Data", .japanese: "データのエクスポート", .korean: "데이터 내보내기", .spanish: "Exportar datos", .german: "Daten exportieren", .russian: "Экспортировать данные", .italian: "Esporta dati"]
        dict[L10n.exportSuccessful] = [.chinese: "导出成功！", .traditionalChinese: "匯出成功！", .english: "Export Successful!", .japanese: "エクスポートに成功しました!", .korean: "내보내기 성공!", .spanish: "¡Exportación exitosa!", .german: "Export erfolgreich!", .russian: "Экспорт успешен!", .italian: "Esportazione riuscita!"]
        dict[L10n.termsOfService] = [.chinese: "使用条款", .traditionalChinese: "使用條款", .english: "Terms of Service", .japanese: "利用規約", .korean: "서비스 약관", .spanish: "Términos de servicio", .german: "Nutzungsbedingungen", .russian: "Условия использования", .italian: "Termini di servizio"]
        dict[L10n.privacyPolicy] = [.chinese: "隐私政策", .traditionalChinese: "隱私權政策", .english: "Privacy Policy", .japanese: "プライバシーポリシー", .korean: "개인 정보 보호 정책", .spanish: "Política de privacidad", .german: "Datenschutzrichtlinie", .russian: "Политика конфиденциальности", .italian: "Informativa sulla privacy"]
        dict[L10n.on] = [.chinese: "开启", .traditionalChinese: "開啟", .english: "On", .japanese: "オン", .korean: "켜기", .spanish: "encendido", .german: "Auf", .russian: "Вкл.", .italian: "Su"]
        dict[L10n.off] = [.chinese: "关闭", .traditionalChinese: "關閉", .english: "Off", .japanese: "オフ", .korean: "끄기", .spanish: "Apagado", .german: "Aus", .russian: "Выкл.", .italian: "Spento"]
        dict[L10n.upgradeToPremium] = [.chinese: "升级至高级版", .traditionalChinese: "升級至高級版", .english: "Upgrade to Premium", .japanese: "プレミアムにアップグレード", .korean: "프리미엄으로 업그레이드", .spanish: "Actualizar a Premium", .german: "Upgrade auf Premium", .russian: "Обновите до Премиум", .italian: "Passa a Premium"]
        dict[L10n.unlockAllFeatures] = [.chinese: "解锁全部特权与功能", .traditionalChinese: "解鎖全部特權與功能", .english: "Unlock all features", .japanese: "すべての機能のロックを解除する", .korean: "모든 기능 잠금 해제", .spanish: "Desbloquea todas las funciones", .german: "Schalten Sie alle Funktionen frei", .russian: "Разблокируйте все функции", .italian: "Sblocca tutte le funzionalità"]
        dict[L10n.premiumMember] = [.chinese: "高级版会员", .traditionalChinese: "高級版會員", .english: "Premium Member", .japanese: "プレミアム会員", .korean: "프리미엄 회원", .spanish: "Miembro Premium", .german: "Premium-Mitglied", .russian: "Премиум-участник", .italian: "Membro Premium"]
        dict[L10n.allFeaturesUnlocked] = [.chinese: "已解锁全部特权与功能", .traditionalChinese: "已解鎖全部特權與功能", .english: "All features unlocked", .japanese: "すべての機能がロック解除されました", .korean: "모든 기능 잠금 해제", .spanish: "Todas las funciones desbloqueadas", .german: "Alle Funktionen freigeschaltet", .russian: "Все функции разблокированы", .italian: "Tutte le funzionalità sbloccate"]
        dict[L10n.archivedHabits] = [.chinese: "已归档习惯", .traditionalChinese: "已歸檔習慣", .english: "Archived Habits", .japanese: "アーカイブされた習慣", .korean: "보관된 습관", .spanish: "Hábitos archivados", .german: "Archivierte Gewohnheiten", .russian: "Архивные привычки", .italian: "Abitudini archiviate"]
        dict[L10n.showArchived] = [.chinese: "显示归档", .traditionalChinese: "顯示歸檔", .english: "Show Archived", .japanese: "アーカイブを表示", .korean: "보관된 항목 표시", .spanish: "Mostrar Archivado", .german: "Archiviert anzeigen", .russian: "Показать в архиве", .italian: "Mostra archiviato"]
        dict[L10n.noArchivedHabits] = [.chinese: "暂无已归档的习惯。", .traditionalChinese: "暫無歸檔的習慣。", .english: "No archived habits.", .japanese: "アーカイブされた習慣はありません。", .korean: "보관된 습관이 없습니다.", .spanish: "Sin hábitos archivados.", .german: "Keine archivierten Gewohnheiten.", .russian: "Никаких архивных привычек.", .italian: "Nessuna abitudine archiviata."]
        dict[L10n.thisActionWillPermanentlyDeleteThisHabitAndAllItsCheckInRecordsItCannotBeRecovered] = [.chinese: "此操作将永久删除该习惯及其所有打卡记录，且不可恢复。", .traditionalChinese: "此操作將永久刪除該習慣及其所有打卡記錄，且無法恢復。", .english: "This action will permanently delete this habit and all its check-in records. It cannot be recovered.", .japanese: "この操作により、この習慣とそのすべてのチェックイン記録が完全に削除されます。回復することはできません。", .korean: "이 작업을 수행하면 이 습관과 모든 체크인 기록이 영구적으로 삭제됩니다. 복구할 수 없습니다.", .spanish: "Esta acción eliminará permanentemente este hábito y todos sus registros de registro. No se puede recuperar.", .german: "Durch diese Aktion werden diese Gewohnheit und alle zugehörigen Check-in-Datensätze dauerhaft gelöscht. Es kann nicht wiederhergestellt werden.", .russian: "Это действие приведет к безвозвратному удалению этой привычки и всех связанных с ней записей о посещениях. Его невозможно восстановить.", .italian: "Questa azione eliminerà permanentemente questa abitudine e tutti i relativi record di check-in. Non può essere recuperato."]
        dict[L10n.thisSession] = [.chinese: "本次", .traditionalChinese: "本次", .english: "This Session", .japanese: "このセッション", .korean: "이번 세션", .spanish: "Esta sesión", .german: "Diese Sitzung", .russian: "Эта сессия", .italian: "Questa sessione"]
        dict[L10n.undoCheckIn1] = [.chinese: "撤销打卡？", .traditionalChinese: "撤銷打卡？", .english: "Undo Check-in?", .japanese: "チェックインを取り消しますか?", .korean: "체크인을 취소하시겠습니까?", .spanish: "¿Deshacer registro?", .german: "Einchecken rückgängig machen?", .russian: "Отменить регистрацию?", .italian: "Annullare il check-in?"]
        dict[L10n.undo] = [.chinese: "撤销打卡", .traditionalChinese: "撤銷打卡", .english: "Undo", .japanese: "元に戻す", .korean: "실행 취소", .spanish: "Deshacer", .german: "Rückgängig machen", .russian: "Отменить", .italian: "Annulla"]
        dict[L10n.share] = [.chinese: "分享", .traditionalChinese: "分享", .english: "Share", .japanese: "シェアする", .korean: "공유", .spanish: "Compartir", .german: "Teilen", .russian: "Поделиться", .italian: "Condividi"]
        dict[L10n.savedToPhotos] = [.chinese: "已保存到相册", .traditionalChinese: "已儲存至相簿", .english: "Saved to Photos", .japanese: "写真に保存しました", .korean: "포토에 저장됨", .spanish: "Guardado en fotos", .german: "Unter Fotos gespeichert", .russian: "Сохранено в фотографиях", .italian: "Salvato in Foto"]
        dict[L10n.checkInSuccess] = [.chinese: "打卡成功", .traditionalChinese: "打卡成功", .english: "Check-in Success", .japanese: "チェックイン成功", .korean: "체크인 성공", .spanish: "Registro exitoso", .german: "Erfolgreicher Check-in", .russian: "Регистрация прошла успешно", .italian: "Check-in riuscito"]
        dict[L10n.w] = [.chinese: "周：", .traditionalChinese: "週：", .english: "W:", .japanese: "女性:", .korean: "여:", .spanish: "W:", .german: "W:", .russian: "У:", .italian: "W:"]
        dict[L10n.m1] = [.chinese: "月：", .traditionalChinese: "月：", .english: "M:", .japanese: "母：", .korean: "남:", .spanish: "M:", .german: "M:", .russian: "М:", .italian: "M:"]
        dict[L10n.reminder] = [.chinese: "打卡提醒", .traditionalChinese: "打卡提醒", .english: "Reminder", .japanese: "リマインダー", .korean: "알림", .spanish: "Recordatorio", .german: "Erinnerung", .russian: "Напоминание", .italian: "Promemoria"]
        dict[L10n.time1] = [.chinese: "提醒时间", .traditionalChinese: "提醒時間", .english: "Time", .japanese: "時間", .korean: "시간", .spanish: "tiempo", .german: "Zeit", .russian: "Время", .italian: "Tempo"]
        dict[L10n.customMessage] = [.chinese: "自定义文案", .traditionalChinese: "自訂文案", .english: "Custom Message", .japanese: "カスタムメッセージ", .korean: "맞춤 메시지", .spanish: "Mensaje personalizado", .german: "Benutzerdefinierte Nachricht", .russian: "Пользовательское сообщение", .italian: "Messaggio personalizzato"]
        dict[L10n.timeToCheckInKeepItUp] = [.chinese: "该打卡啦！坚持就是胜利～", .traditionalChinese: "該打卡啦！堅持就是勝利～", .english: "Time to check in! Keep it up~", .japanese: "チェックインの時間です！それを続けてください~", .korean: "체크인 시간입니다! 계속하세요~", .spanish: "¡Es hora de registrarse! Sigue así ~", .german: "Zeit zum Einchecken! Weiter so~", .russian: "Время зарегистрироваться! Так держать~", .italian: "È ora di fare il check-in! Continua così~"]
        dict[L10n.reminderDisabled] = [.chinese: "未开启提醒", .traditionalChinese: "未開啟提醒", .english: "Reminder Disabled", .japanese: "リマインダーが無効になっています", .korean: "알림이 비활성화되었습니다.", .spanish: "Recordatorio deshabilitado", .german: "Erinnerung deaktiviert", .russian: "Напоминание отключено", .italian: "Promemoria disabilitato"]
        dict[L10n.restoreSuccessful] = [.chinese: "恢复购买成功", .traditionalChinese: "恢復購買成功", .english: "Restore Successful", .japanese: "復元に成功しました", .korean: "복원 성공", .spanish: "Restauración exitosa", .german: "Wiederherstellung erfolgreich", .russian: "Восстановить успешно", .italian: "Ripristino riuscito"]
        dict[L10n.noPurchasesToRestore] = [.chinese: "没有可恢复的购买项", .traditionalChinese: "沒有可恢復的購買項", .english: "No Purchases to Restore", .japanese: "復元する購入はありません", .korean: "복원할 구매가 없습니다.", .spanish: "No hay compras para restaurar", .german: "Keine Käufe zum Wiederherstellen", .russian: "Нет покупок для восстановления", .italian: "Nessun acquisto da ripristinare"]
        dict[L10n.failedToFetchProducts] = [.chinese: "获取产品列表失败：", .traditionalChinese: "取得產品清單失敗：", .english: "Failed to fetch products: ", .japanese: "製品の取得に失敗しました:", .korean: "제품을 가져오지 못했습니다:", .spanish: "No se pudieron recuperar los productos:", .german: "Produkte konnten nicht abgerufen werden:", .russian: "Не удалось получить товары:", .italian: "Impossibile recuperare i prodotti:"]
        dict[L10n.purchasing] = [.chinese: "正在购买...", .traditionalChinese: "正在購買...", .english: "Purchasing...", .japanese: "購入中...", .korean: "구매 중...", .spanish: "Comprando...", .german: "Einkauf...", .russian: "Покупка...", .italian: "Acquisto..."]
        dict[L10n.restoring] = [.chinese: "恢复中...", .traditionalChinese: "恢復中...", .english: "Restoring...", .japanese: "復元中...", .korean: "복원 중...", .spanish: "Restaurando...", .german: "Wiederherstellung...", .russian: "Восстановление...", .italian: "Ripristino..."]
        dict[L10n.purchaseSuccessful] = [.chinese: "购买成功！", .traditionalChinese: "購買成功！", .english: "Purchase Successful!", .japanese: "購入成功しました！", .korean: "구매 성공!", .spanish: "¡Compra exitosa!", .german: "Kauf erfolgreich!", .russian: "Покупка успешна!", .italian: "Acquisto riuscito!"]
        dict[L10n.purchaseCancelled] = [.chinese: "购买被取消", .traditionalChinese: "購買取消", .english: "Purchase Cancelled", .japanese: "購入がキャンセルされました", .korean: "구매가 취소되었습니다.", .spanish: "Compra cancelada", .german: "Kauf storniert", .russian: "Покупка отменена", .italian: "Acquisto annullato"]
        dict[L10n.purchaseFailed] = [.chinese: "购买失败", .traditionalChinese: "購買失敗", .english: "Purchase Failed", .japanese: "購入に失敗しました", .korean: "구매 실패", .spanish: "Compra fallida", .german: "Der Kauf ist fehlgeschlagen", .russian: "Покупка не удалась", .italian: "Acquisto non riuscito"]
        dict[L10n.restorePurchases] = [.chinese: "恢复购买", .traditionalChinese: "恢復購買", .english: "Restore Purchases", .japanese: "購入を復元する", .korean: "구매 복원", .spanish: "Restaurar compras", .german: "Einkäufe wiederherstellen", .russian: "Восстановить покупки", .italian: "Ripristina gli acquisti"]
        dict[L10n.tickdayPremiumMember] = [.chinese: "TickDay 尊享会员", .traditionalChinese: "TickDay 尊享會員", .english: "TickDay Premium Member", .japanese: "TickDay プレミアム会員", .korean: "TickDay 프리미엄 회원", .spanish: "Miembro Premium de Tick Day", .german: "TickDay Premium-Mitglied", .russian: "Премиум-участник TickDay", .italian: "Membro Premium di TickDay"]
        dict[L10n.youAreAPremiumMember] = [.chinese: "您已是尊享会员", .traditionalChinese: "您已是尊享會員", .english: "You are a Premium Member", .japanese: "あなたはプレミアム会員です", .korean: "당신은 프리미엄 회원입니다", .spanish: "Eres un Miembro Premium", .german: "Sie sind Premium-Mitglied", .russian: "Вы Премиум-участник", .italian: "Sei un membro Premium"]
        dict[L10n.validUntilLifetimeAccess] = [.chinese: "到期时间：永久有效 (终身会员)", .traditionalChinese: "到期時間：永久有效 (終身會員)", .english: "Valid until: Lifetime Access", .japanese: "有効期限: 生涯アクセス", .korean: "유효기간: 평생 이용 가능", .spanish: "Válido hasta: Acceso de por vida", .german: "Gültig bis: Lebenslanger Zugriff", .russian: "Действительно до: Пожизненный доступ", .italian: "Valido fino al: Accesso a vita"]
        dict[L10n.statusActivePremium] = [.chinese: "状态：已激活尊享会员", .traditionalChinese: "狀態：已啟動尊享會員", .english: "Status: Active Premium", .japanese: "ステータス: アクティブプレミアム", .korean: "상태: 활성 프리미엄", .spanish: "Estado: Premium activo", .german: "Status: Active Premium", .russian: "Статус: Активный Премиум", .italian: "Stato: Premium attivo"]
        dict[L10n.validUntil] = [.chinese: "到期时间：", .traditionalChinese: "到期時間：", .english: "Valid until: ", .japanese: "有効期限:", .korean: "유효기간:", .spanish: "Válido hasta:", .german: "Gültig bis:", .russian: "Действует до:", .italian: "Valido fino al:"]
        dict[L10n.unableToFetchProductPricingFromAppStorePleaseCheckNetworkOrAppStoreConnectStatus] = [.chinese: "无法从 App Store 获取产品价格与配置，请检查网络连接或确认苹果后台产品已生效。", .traditionalChinese: "無法從 App Store 取得產品價格與配置，請檢查網路連線或確認蘋果後台產品已生效。", .english: "Unable to fetch product pricing from App Store. Please check network or App Store Connect status.", .japanese: "App Store から製品の価格を取得できません。ネットワークまたは App Store Connect のステータスを確認してください。", .korean: "App Store에서 제품 가격을 가져올 수 없습니다. 네트워크 또는 App Store 연결 상태를 확인하세요.", .spanish: "No se pueden obtener los precios de los productos en la App Store. Verifique el estado de la red o App Store Connect.", .german: "Produktpreise können nicht aus dem App Store abgerufen werden. Bitte überprüfen Sie den Netzwerk- oder App Store Connect-Status.", .russian: "Не удалось получить цены на продукты из App Store. Пожалуйста, проверьте статус сети или App Store Connect.", .italian: "Impossibile recuperare i prezzi dei prodotti dall'App Store. Controlla lo stato della connessione della rete o dell'App Store."]
        dict[L10n.autoRenewablePriceCancelAnytime] = [.chinese: "自动续期，{price}，可随时取消", .traditionalChinese: "自動續期，{price}，可隨時取消", .english: "Auto-renewable, {price}, cancel anytime", .japanese: "自動更新可能、{price}、いつでもキャンセル可能", .korean: "자동 갱신 가능, {price}, 언제든지 취소", .spanish: "Renovable automáticamente, {price}, cancelar en cualquier momento", .german: "Automatisch verlängerbar, {price}, jederzeit kündbar", .russian: "Автоматическое продление, {price}, отмена в любое время", .italian: "Rinnovabile automaticamente, {price}, annulla in qualsiasi momento"]
        dict[L10n.firstMonthFreeThenPrice] = [.chinese: "首月免费，结束后按 {price}收费", .traditionalChinese: "第一個月免費，結束後按 {price}收費", .english: "First month free, then {price}", .japanese: "最初の 1 か月間は無料、その後は {price}", .korean: "첫 달은 무료, 그 이후에는 {price}", .spanish: "Primer mes gratis, luego {price}", .german: "Erster Monat kostenlos, dann {price}", .russian: "Первый месяц бесплатно, затем {price}", .italian: "Primo mese gratis, poi {price}"]
        dict[L10n.oneTimePaymentLifetimeAccessToAllFeatures] = [.chinese: "一次性付费，永久解锁全部尊享权益", .traditionalChinese: "一次性付費，永久解鎖全部尊享權益", .english: "One-time payment, lifetime access to all features", .japanese: "1 回限りの支払いで、すべての機能に生涯アクセスできます", .korean: "일회성 결제, 평생 모든 기능 이용 가능", .spanish: "Pago único, acceso de por vida a todas las funciones", .german: "Einmalige Zahlung, lebenslanger Zugriff auf alle Funktionen", .russian: "Единоразовый платеж, пожизненный доступ ко всем функциям", .italian: "Pagamento una tantum, accesso illimitato a tutte le funzionalità"]
        dict[L10n.paymentWillBeChargedToYourItunesAccountAtConfirmationOfPurchaseSubscriptionAutomaticallyRenewsUnlessAutoRenewIsTurnedOffAtLeast24HoursBeforeTheEndOfTheCurrentPeriodAccountWillBeChargedForRenewalWithin24HoursPriorToTheEndOfTheCurrentPeriodYouCanManageAndCancelYourSubscriptionsInYourAppStoreAccountSettings] = [.chinese: "确认购买后，款项将从您的 iTunes 账户扣除。订阅将自动续期，除非在当前订阅期结束前至少24小时关闭自动续订。您的账户将在当前订阅期结束前24小时内扣取续订费用。您可以在购买后前往 App Store 账户设置中管理或取消您的订阅。", .traditionalChinese: "確認購買後，款項將從您的 iTunes 帳戶扣除。訂閱將自動續期，除非在目前訂閱期結束前至少24小時關閉自動續訂。您的帳戶將在目前訂閱期結束前24小時內扣取續訂費用。您可以在購買後前往 App Store 帳戶設定中管理或取消您的訂閱。", .english: "Payment will be charged to your iTunes account at confirmation of purchase. Subscription automatically renews unless auto-renew is turned off at least 24-hours before the end of the current period. Account will be charged for renewal within 24-hours prior to the end of the current period. You can manage and cancel your subscriptions in your App Store account settings.", .japanese: "購入の確認時に、支払いは iTunes アカウントに請求されます。現在の期間が終了する少なくとも 24 時間前に自動更新をオフにしない限り、サブスクリプションは自動的に更新されます。アカウントには、現在の期間が終了する 24 時間以内に更新料金が請求されます。 App Store アカウント設定でサブスクリプションを管理およびキャンセルできます。", .korean: "구매 확인 시 iTunes 계정으로 요금이 청구됩니다. 현재 기간이 종료되기 최소 24시간 전에 자동 갱신을 끄지 않으면 구독이 자동으로 갱신됩니다. 현재 기간이 종료되기 24시간 이내에 갱신 비용이 계정에 청구됩니다. App Store 계정 설정에서 구독을 관리하고 취소할 수 있습니다.", .spanish: "El pago se cargará a su cuenta de iTunes al confirmar la compra. La suscripción se renueva automáticamente a menos que se desactive la renovación automática al menos 24 horas antes del final del período actual. Se cargará a la cuenta la renovación dentro de las 24 horas anteriores al final del período actual. Puede administrar y cancelar sus suscripciones en la configuración de su cuenta de App Store.", .german: "Die Zahlung wird Ihrem iTunes-Konto bei der Kaufbestätigung belastet. Das Abonnement verlängert sich automatisch, es sei denn, die automatische Verlängerung wird mindestens 24 Stunden vor dem Ende des aktuellen Zeitraums deaktiviert. Die Verlängerung des Kontos wird innerhalb von 24 Stunden vor dem Ende des aktuellen Zeitraums belastet. Sie können Ihre Abonnements in den Einstellungen Ihres App Store-Kontos verwalten und kündigen.", .russian: "Оплата будет снята с вашей учетной записи iTunes при подтверждении покупки. Подписка продлевается автоматически, если автоматическое продление не отключено по крайней мере за 24 часа до окончания текущего периода. С аккаунта будет взиматься плата за продление в течение 24 часов до окончания текущего периода. Вы можете управлять своими подписками и отменять их в настройках учетной записи App Store.", .italian: "Il pagamento verrà addebitato sul tuo account iTunes alla conferma dell'acquisto. L'abbonamento si rinnova automaticamente a meno che il rinnovo automatico non venga disattivato almeno 24 ore prima della fine del periodo corrente. Il rinnovo verrà addebitato sul conto entro 24 ore prima della fine del periodo corrente. Puoi gestire e annullare i tuoi abbonamenti nelle impostazioni del tuo account App Store."]
        dict[L10n.notice] = [.chinese: "提示", .traditionalChinese: "提示", .english: "Notice", .japanese: "お知らせ", .korean: "공지사항", .spanish: "Aviso", .german: "Hinweis", .russian: "Уведомление", .italian: "Avviso"]
        dict[L10n.unableToFetchSubscriptionPricingFromAppStoreConnectShowingDefaultReferencePricesPleaseCheck1InAppPurchaseStatusIsNotMissingMetadata2PaidApplicationsAgreementIsActive3ProductIdsMatchExactly] = [.chinese: "无法从苹果后台获取订阅价格，当前显示默认参考价。请检查：1) 苹果后台内购项目状态不为“缺少元数据”；2) App Store Connect 付费协议已生效；3) 产品 ID 匹配。", .traditionalChinese: "無法從蘋果後台取得訂閱價格，目前顯示預設參考價。請檢查：1) 蘋果後台內購項目狀態不為「缺少元資料」；2) App Store Connect 付費協議已生效；3) 產品 ID 匹配。", .english: "Unable to fetch subscription pricing from App Store Connect. Showing default reference prices. Please check: 1) In-App Purchase status is not 'Missing Metadata'; 2) Paid Applications Agreement is Active; 3) Product IDs match exactly.", .japanese: "App Store Connect からサブスクリプションの価格を取得できません。デフォルトの参考価格を表示します。ご確認ください: 1) アプリ内購入のステータスが「メタデータがありません」ではないこと。 2) 有料アプリケーション契約が有効である。 3) 製品 ID が正確に一致します。", .korean: "App Store Connect에서 구독 가격을 가져올 수 없습니다. 기본 참조 가격을 표시합니다. 확인하세요: 1) 인앱 구매 상태가 '메타데이터 누락'이 아닙니다. 2) 유료 애플리케이션 계약이 활성화되었습니다. 3) 상품ID가 정확히 일치합니다.", .spanish: "No se pueden obtener los precios de suscripción de App Store Connect. Mostrando precios de referencia predeterminados. Verifique: 1) El estado de la compra dentro de la aplicación no es \"Metadatos faltantes\"; 2) El Acuerdo de Aplicaciones Pagadas está Activo; 3) Los ID de producto coinciden exactamente.", .german: "Abonnementpreise können nicht von App Store Connect abgerufen werden. Standardreferenzpreise werden angezeigt. Bitte überprüfen Sie: 1) Der Status des In-App-Kaufs lautet nicht „Fehlende Metadaten“. 2) Die Vereinbarung über kostenpflichtige Anwendungen ist aktiv. 3) Produkt-IDs stimmen genau überein.", .russian: "Не удалось получить информацию о ценах на подписку из App Store Connect. Показаны справочные цены по умолчанию. Пожалуйста, проверьте: 1) Статус покупки в приложении не «Отсутствуют метаданные»; 2) Соглашение о платных приложениях является действующим; 3) Идентификаторы продуктов точно совпадают.", .italian: "Impossibile recuperare i prezzi dell'abbonamento da App Store Connect. Visualizzazione dei prezzi di riferimento predefiniti. Controlla: 1) Lo stato dell'acquisto in-app non sia \"Metadati mancanti\"; 2) Il contratto per le applicazioni a pagamento è attivo; 3) Gli ID prodotto corrispondono esattamente."]
        dict[L10n.generateMockDataForThisYear] = [.chinese: "一键生成今年模拟打卡数据", .traditionalChinese: "一鍵生成今年模擬打卡數據", .english: "Generate Mock Data for This Year", .japanese: "今年のモックデータを生成する", .korean: "올해의 모의 데이터 생성", .spanish: "Genere datos simulados para este año", .german: "Generieren Sie Scheindaten für dieses Jahr", .russian: "Сгенерируйте фиктивные данные за этот год", .italian: "Genera dati fittizi per quest'anno"]
        dict[L10n.populateRealistic2026CheckInsAndMoodRecords] = [.chinese: "为现有习惯随机填充今年打卡与情绪记录", .traditionalChinese: "為現有習慣隨機填滿今年打卡與情緒紀錄", .english: "Populate realistic 2026 check-ins and mood records", .japanese: "現実的な 2026 年のチェックインと気分の記録を取り込む", .korean: "현실적인 2026년 체크인 및 기분 기록 채우기", .spanish: "Complete registros de estado de ánimo y registros realistas de 2026", .german: "Füllen Sie realistische Check-ins und Stimmungsaufzeichnungen für 2026 aus", .russian: "Заполните реалистичные записи о посещениях и настроении на 2026 год.", .italian: "Compila check-in realistici e record dell'umore del 2026"]
        dict[L10n.successfullyGeneratedMockCheckInsMoodRecordsForThisYear] = [.chinese: "已为所有习惯成功生成今年全套模拟打卡与情绪数据！", .traditionalChinese: "已為所有習慣成功產生今年全套模擬打卡與情緒數據！", .english: "Successfully generated mock check-ins & mood records for this year!", .japanese: "今年の模擬チェックインと気分記録が正常に生成されました。", .korean: "올해의 모의 체크인 및 기분 기록을 성공적으로 생성했습니다!", .spanish: "¡Se generaron con éxito registros simulados y registros de estado de ánimo para este año!", .german: "Für dieses Jahr wurden erfolgreich Mock-Check-Ins und Stimmungsaufzeichnungen generiert!", .russian: "Успешно созданы пробные проверки и записи настроения за этот год!", .italian: "Check-in simulati e record dell'umore generati con successo per quest'anno!"]
        dict[L10n.icloudConnected] = [.chinese: "iCloud 账号正常连接", .traditionalChinese: "iCloud 帳號正常連接", .english: "iCloud Connected", .japanese: "iCloud接続済み", .korean: "iCloud에 연결됨", .spanish: "iCloud conectado", .german: "iCloud verbunden", .russian: "iCloud подключен", .italian: "iCloud connesso"]
        dict[L10n.notLoggedInPleaseSignInToIcloudInSettings] = [.chinese: "未登录，请在系统设置中登录您的 Apple ID", .traditionalChinese: "未登錄，請在系統設定中登入您的 Apple ID", .english: "Not logged in. Please sign in to iCloud in Settings.", .japanese: "ログインしていません。設定で iCloud にサインインしてください。", .korean: "로그인되지 않았습니다. 설정에서 iCloud에 로그인하세요.", .spanish: "No ha iniciado sesión. Inicie sesión en iCloud en Configuración.", .german: "Nicht angemeldet. Bitte melden Sie sich in den Einstellungen bei iCloud an.", .russian: "Не выполнен вход. Войдите в iCloud в настройках.", .italian: "Accesso non effettuato. Accedi a iCloud nelle Impostazioni."]
        dict[L10n.icloudAccessRestricted] = [.chinese: "iCloud 访问受限", .traditionalChinese: "iCloud 存取受限", .english: "iCloud Access Restricted", .japanese: "iCloudアクセスが制限されています", .korean: "iCloud 액세스 제한됨", .spanish: "Acceso restringido a iCloud", .german: "iCloud-Zugriff eingeschränkt", .russian: "Доступ к iCloud ограничен", .italian: "Accesso iCloud limitato"]
        dict[L10n.couldNotDetermineIcloudStatus] = [.chinese: "无法确定 iCloud 状态", .traditionalChinese: "無法確定 iCloud 狀態", .english: "Could Not Determine iCloud Status", .japanese: "iCloudのステータスを特定できませんでした", .korean: "iCloud 상태를 확인할 수 없음", .spanish: "No se pudo determinar el estado de iCloud", .german: "Der iCloud-Status konnte nicht ermittelt werden", .russian: "Не удалось определить статус iCloud", .italian: "Impossibile determinare lo stato di iCloud"]
        dict[L10n.icloudTemporarilyUnavailable] = [.chinese: "iCloud 服务暂不可用", .traditionalChinese: "iCloud 服務暫不可用", .english: "iCloud Temporarily Unavailable", .japanese: "iCloudが一時的に利用できなくなる", .korean: "iCloud를 일시적으로 사용할 수 없음", .spanish: "iCloud no disponible temporalmente", .german: "iCloud vorübergehend nicht verfügbar", .russian: "iCloud временно недоступен", .italian: "iCloud temporaneamente non disponibile"]
        dict[L10n.unknownStatus] = [.chinese: "未知状态", .traditionalChinese: "未知狀態", .english: "Unknown Status", .japanese: "不明なステータス", .korean: "알 수 없는 상태", .spanish: "Estado desconocido", .german: "Unbekannter Status", .russian: "Неизвестный статус", .italian: "Stato sconosciuto"]
        dict[L10n.icloudStatus] = [.chinese: "iCloud 状态", .traditionalChinese: "iCloud 狀態", .english: "iCloud Status", .japanese: "iCloudのステータス", .korean: "아이클라우드 상태", .spanish: "Estado de iCloud", .german: "iCloud-Status", .russian: "Статус iCloud", .italian: "Stato dell'iCloud"]
        dict[L10n.checkSyncNow] = [.chinese: "立即检查同步", .traditionalChinese: "立即檢查同步", .english: "Check Sync Now", .japanese: "今すぐ同期をチェックする", .korean: "지금 동기화 확인", .spanish: "Marque Sincronizar ahora", .german: "Aktivieren Sie „Jetzt synchronisieren“.", .russian: "Проверить синхронизацию сейчас", .italian: "Controlla Sincronizza ora"]
        dict[L10n.checkingStatus] = [.chinese: "状态检查中...", .traditionalChinese: "狀態檢查中...", .english: "Checking Status...", .japanese: "ステータスを確認中...", .korean: "상태 확인 중...", .spanish: "Comprobando estado...", .german: "Status wird geprüft...", .russian: "Проверка статуса...", .italian: "Verifica dello stato..."]
        dict[L10n.dataIsFullyStoredLocallyForInstantOfflineAccessEnablingIcloudBacksUpInBackgroundDisablingPreservesAllLocalRecordsReconnectingMergesOfflineUpdatesAutomatically] = [.chinese: "数据已完全保存在本地数据库，支持极速离线读取与打卡。开启 iCloud 仅在后台同步备份，关闭不会丢失任何本地已有记录，重新连接后自动增量双向合并。", .traditionalChinese: "資料已完全保存在本機資料庫，支援極速離線讀取與打卡。開啟 iCloud 僅在背景同步備份，關閉不會遺失任何本機已有記錄，重新連線後自動增量雙向合併。", .english: "Data is fully stored locally for instant offline access. Enabling iCloud backs up in background; disabling preserves all local records. Reconnecting merges offline updates automatically.", .japanese: "データは完全にローカルに保存されるため、オフラインですぐにアクセスできます。 iCloud を有効にすると、バックグラウンドでバックアップが行われます。無効にすると、すべてのローカル レコードが保存されます。再接続すると、オフライン更新が自動的にマージされます。", .korean: "데이터는 즉시 오프라인 액세스를 위해 로컬에 완전히 저장됩니다. iCloud를 활성화하면 백그라운드에서 백업됩니다. 비활성화하면 모든 로컬 기록이 보존됩니다. 다시 연결하면 오프라인 업데이트가 자동으로 병합됩니다.", .spanish: "Los datos se almacenan completamente localmente para un acceso instantáneo sin conexión. Habilitar las copias de seguridad de iCloud en segundo plano; La desactivación conserva todos los registros locales. La reconexión fusiona las actualizaciones sin conexión automáticamente.", .german: "Die Daten werden vollständig lokal gespeichert und ermöglichen den sofortigen Offline-Zugriff. Aktivieren von iCloud-Backups im Hintergrund; Durch die Deaktivierung bleiben alle lokalen Datensätze erhalten. Durch die erneute Verbindung werden Offline-Updates automatisch zusammengeführt.", .russian: "Данные полностью хранятся локально для мгновенного доступа в автономном режиме. Включение резервного копирования iCloud в фоновом режиме; отключение сохраняет все локальные записи. При повторном подключении автономные обновления автоматически объединяются.", .italian: "I dati vengono completamente archiviati localmente per un accesso offline immediato. Abilitazione dei backup di iCloud in background; la disabilitazione preserva tutti i record locali. La riconnessione unisce automaticamente gli aggiornamenti offline."]
        dict[L10n.noHabit] = [.chinese: "暂无习惯", .traditionalChinese: "暫無習慣", .english: "No Habit", .japanese: "習慣がない", .korean: "습관 없음", .spanish: "Sin hábito", .german: "Keine Gewohnheit", .russian: "Нет привычки", .italian: "Nessuna abitudine"]
        dict[L10n.selectHabits] = [.chinese: "请选择习惯", .traditionalChinese: "請選擇習慣", .english: "Select Habits", .japanese: "習慣を選択する", .korean: "습관 선택", .spanish: "Seleccionar hábitos", .german: "Wählen Sie Gewohnheiten", .russian: "Выберите привычки", .italian: "Seleziona Abitudini"]
        dict[L10n.pleaseLongPressToEditSelectHabit] = [.chinese: "请长按编辑选择习惯", .traditionalChinese: "請長按編輯選擇習慣", .english: "Please long press to edit & select habit", .japanese: "長押しして習慣を編集して選択してください", .korean: "습관을 수정하고 선택하려면 길게 누르세요.", .spanish: "Mantenga presionado para editar y seleccionar el hábito", .german: "Bitte lange drücken, um die Gewohnheit zu bearbeiten und auszuwählen", .russian: "Пожалуйста, нажмите и удерживайте, чтобы изменить и выбрать привычку", .italian: "Premere a lungo per modificare e selezionare l'abitudine"]
        dict[L10n.thisWeek1] = [.chinese: "本周", .traditionalChinese: "本週", .english: "This week", .japanese: "今週", .korean: "이번주", .spanish: "esta semana", .german: "Diese Woche", .russian: "На этой неделе", .italian: "Questa settimana"]
        dict[L10n.thisMonth1] = [.chinese: "本月", .traditionalChinese: "本月", .english: "This month", .japanese: "今月", .korean: "이번 달", .spanish: "este mes", .german: "Diesen Monat", .russian: "В этом месяце", .italian: "Questo mese"]

        dict[L10n.csvHeaders] = [.chinese: "习惯名称,颜色编号,图标编号,频率类型,目标类型,打卡日期,打卡数值", .traditionalChinese: "習慣名稱,顏色編號,圖標編號,頻率類型,目標類型,打卡日期,打卡數值", .english: "Habit Name,Color Hex,Icon Name,Frequency Type,Goal Type,Check-in Date,Amount", .japanese: "習慣名,カラー16進数,アイコン名,頻度タイプ,目標タイプ,チェックイン日,量", .korean: "습관 이름,색상 16진수,아이콘 이름,빈도 유형,목표 유형,체크인 날짜,양", .spanish: "Nombre del hábito,Color Hex,Nombre del icono,Tipo de frecuencia,Tipo de objetivo,Fecha de registro,Cantidad", .german: "Gewohnheitsname,Farb-Hex,Symbolname,Häufigkeitstyp,Zieltyp,Check-in-Datum,Menge", .russian: "Название привычки,Шестнадцатеричный цвет,Название значка,Тип частоты,Тип цели,Дата отметки,Количество", .italian: "Nome abitudine,Esadecimale colore,Nome icona,Tipo di frequenza,Tipo di obiettivo,Data di registrazione,Quantità"]
        dict[L10n.noRecords] = [.chinese: "暂无记录", .traditionalChinese: "暫無記錄", .english: "No records", .japanese: "記録なし", .korean: "기록 없음", .spanish: "Sin registros", .german: "Keine Aufzeichnungen", .russian: "Нет записей", .italian: "Nessun record"]
        dict[L10n.weeklyGoals] = [.chinese: "周目标", .traditionalChinese: "週目標", .english: "Weekly Target", .japanese: "週間目標", .korean: "주간 목표", .spanish: "Objetivo semanal", .german: "Wöchentliches Ziel", .russian: "Еженедельная цель", .italian: "Obiettivo settimanale"]
        dict[L10n.monthlyTarget2] = [.chinese: "月目标", .traditionalChinese: "月目標", .english: "Monthly Target", .japanese: "月間目標", .korean: "월간 목표", .spanish: "Objetivo mensual", .german: "Monatsziel", .russian: "Ежемесячная цель", .italian: "Obiettivo mensile"]
        dict[L10n.selectIcon] = [.chinese: "选择图标", .traditionalChinese: "選擇圖示", .english: "Choose an Icon", .japanese: "アイコンを選択してください", .korean: "아이콘을 선택하세요", .spanish: "Elige un icono", .german: "Wählen Sie ein Symbol", .russian: "Выберите значок", .italian: "Scegli un'icona"]
        dict[L10n.totalValue] = [.chinese: "总数值", .traditionalChinese: "總數值", .english: "Total Amount", .japanese: "合計金額", .korean: "총액", .spanish: "Monto Total", .german: "Gesamtbetrag", .russian: "Общая сумма", .italian: "Importo totale"]
        dict[L10n.calm] = [.chinese: "平静", .traditionalChinese: "平靜", .english: "Normal", .japanese: "ノーマル", .korean: "보통", .spanish: "normales", .german: "Normal", .russian: "Нормальный", .italian: "Normale"]
        dict[L10n.down2] = [.chinese: "低落", .traditionalChinese: "低落", .english: "Down", .japanese: "ダウン", .korean: "아래로", .spanish: "abajo", .german: "Runter", .russian: "Вниз", .italian: "Giù"]
        dict[L10n.angry2] = [.chinese: "生气", .traditionalChinese: "生氣", .english: "Angry", .japanese: "怒っている", .korean: "화난", .spanish: "enojado", .german: "Wütend", .russian: "Злой", .italian: "Arrabbiato"]
        dict[L10n.monthlyDeduction] = [.chinese: "按月扣费", .traditionalChinese: "按月扣費", .english: "Billed monthly", .japanese: "毎月請求される", .korean: "매월 청구됨", .spanish: "Facturado mensualmente", .german: "Wird monatlich abgerechnet", .russian: "Оплата ежемесячно", .italian: "Fatturazione mensile"]
        dict[L10n.annualDeduction] = [.chinese: "按年扣费", .traditionalChinese: "按年扣費", .english: "Billed yearly", .japanese: "毎年請求される", .korean: "매년 청구됨", .spanish: "Facturado anualmente", .german: "Jährliche Abrechnung", .russian: "Оплата ежегодно", .italian: "Fatturato annualmente"]
        dict[L10n.oneTimePayment2] = [.chinese: "一次性付费", .traditionalChinese: "一次性付費", .english: "One-time payment", .japanese: "1回払い", .korean: "일회성 결제", .spanish: "Pago único", .german: "Einmalige Zahlung", .russian: "Единовременный платеж", .italian: "Pagamento una tantum"]
        dict[L10n.ok2] = [.chinese: "确定", .traditionalChinese: "確定", .english: "OK", .japanese: "OK", .korean: "알았어", .spanish: "bien", .german: "Okay", .russian: "ОК", .italian: "Va bene"]
                dict[L10n.checkedIn] = [.chinese: "已打卡", .english: "Checked In"]
        dict[L10n.unableToFetchProductPricingAndConfig] = [.chinese: "无法从 App Store 获取产品价格与配置，无法发起购买。请检查：1.网络连接 2.苹果后台产品状态(不能是需要开发者操作) 3.确保已签署《付费应用程序协议》。", .english: "Unable to fetch product pricing and config..."]
        dict[L10n.noData] = [.chinese: "暂无数据", .english: "No Data"]
        dict[L10n.mainTab] = [.chinese: "主页", .english: "Main"]
        return dict

    }()

    func tr(_ lang: AppLanguage) -> String {
        var actualLang = lang
        if lang == .system {
            let sysLang = Locale.preferredLanguages.first ?? "en"
            if sysLang.hasPrefix("zh-Hant") || sysLang.hasPrefix("zh-TW") || sysLang.hasPrefix("zh-HK") { actualLang = .traditionalChinese }
            else if sysLang.hasPrefix("zh") { actualLang = .chinese }
            else if sysLang.hasPrefix("ja") { actualLang = .japanese }
            else if sysLang.hasPrefix("ko") { actualLang = .korean }
            else if sysLang.hasPrefix("es") { actualLang = .spanish }
            else if sysLang.hasPrefix("de") { actualLang = .german }
            else if sysLang.hasPrefix("ru") { actualLang = .russian }
            else if sysLang.hasPrefix("it") { actualLang = .italian }
            else { actualLang = .english }
        }
        return String.translations[self]?[actualLang] ?? self
    }

    func wTr() -> String {
        let mode = UserDefaults(suiteName: "group.com.littlehabit.tracker")?.string(forKey: "appLanguage") ?? "system"
        var actualLang: AppLanguage = .english
        
        if mode != "system", let lang = AppLanguage(rawValue: mode) {
            actualLang = lang
        } else {
            let sysLang = Locale.preferredLanguages.first ?? "en"
            if sysLang.hasPrefix("zh-Hant") || sysLang.hasPrefix("zh-TW") || sysLang.hasPrefix("zh-HK") { actualLang = .traditionalChinese }
            else if sysLang.hasPrefix("zh") { actualLang = .chinese }
            else if sysLang.hasPrefix("ja") { actualLang = .japanese }
            else if sysLang.hasPrefix("ko") { actualLang = .korean }
            else if sysLang.hasPrefix("es") { actualLang = .spanish }
            else if sysLang.hasPrefix("de") { actualLang = .german }
            else if sysLang.hasPrefix("ru") { actualLang = .russian }
            else if sysLang.hasPrefix("it") { actualLang = .italian }
        }
        return String.translations[self]?[actualLang] ?? self
    }
}

func getWidgetLanguage() -> String {
    let mode = UserDefaults(suiteName: "group.com.littlehabit.tracker")?.string(forKey: "appLanguage") ?? "system"
    if mode != "system" { return mode }
    if let firstLang = Locale.preferredLanguages.first {
        if firstLang.hasPrefix("zh-Hant") || firstLang.hasPrefix("zh-TW") || firstLang.hasPrefix("zh-HK") { return "zh-Hant" }
        if firstLang.hasPrefix("zh") { return "zh" }
        if firstLang.hasPrefix("ja") { return "ja" }
        if firstLang.hasPrefix("ko") { return "ko" }
        if firstLang.hasPrefix("es") { return "es" }
        if firstLang.hasPrefix("de") { return "de" }
        if firstLang.hasPrefix("ru") { return "ru" }
        if firstLang.hasPrefix("it") { return "it" }
    }
    return "en"
}