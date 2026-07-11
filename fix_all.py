import re

# 1. Update HabitMonthDetailView
with open('Sources/HabitMonthDetailView.swift', 'r') as f:
    hm_content = f.read()

# Replace toolbar item for month selection
old_toolbar = """        .navigationTitle("\\(String(format: "%04d", year))年 \\(String(format: "%02d", month))月 ｜ \\(habit.name)")
        .navigationBarTitleDisplayMode(.inline)
        .navigationBarBackButtonHidden(true)
        .toolbarBackground(.visible, for: .navigationBar)
        .toolbarBackground(Color(hex: "#F8F9FA"), for: .navigationBar)
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading) {
                Button(action: { dismiss() }) {
                    Image(systemName: "chevron.left")
                        .font(.system(size: 16, weight: .bold))
                        .foregroundColor(DS.onSurface)
                        .padding(8)
                        .background(Color.clear)
                        .clipShape(Circle())
                }
            }
            ToolbarItem(placement: .navigationBarTrailing) {
                HStack(spacing: 8) {
                    Button(action: { 
                        if let newDate = calendar.date(byAdding: .month, value: -1, to: currentMonthDate) {
                            currentMonthDate = newDate
                        }
                    }) {
                        Image(systemName: "chevron.left.circle.fill")
                            .font(.system(size: 22))
                            .foregroundColor(DS.surfaceContainerLow)
                            .overlay(Image(systemName: "chevron.left").font(.system(size: 10, weight: .bold)).foregroundColor(DS.onSurfaceVariant))
                    }
                    Button(action: { 
                        if let newDate = calendar.date(byAdding: .month, value: 1, to: currentMonthDate) {
                            currentMonthDate = newDate
                        }
                    }) {
                        Image(systemName: "chevron.right.circle.fill")
                            .font(.system(size: 22))
                            .foregroundColor(DS.surfaceContainerLow)
                            .overlay(Image(systemName: "chevron.right").font(.system(size: 10, weight: .bold)).foregroundColor(DS.onSurfaceVariant))
                    }
                }
            }
        }"""

new_toolbar = """        .navigationTitle(habit.name)
        .navigationBarTitleDisplayMode(.inline)
        .navigationBarBackButtonHidden(true)
        .toolbarBackground(.visible, for: .navigationBar)
        .toolbarBackground(Color(hex: "#F8F9FA"), for: .navigationBar)
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading) {
                Button(action: { dismiss() }) {
                    Image(systemName: "chevron.left")
                        .font(.system(size: 16, weight: .bold))
                        .foregroundColor(DS.onSurface)
                        .padding(8)
                        .background(Color.clear)
                        .clipShape(Circle())
                }
            }
        }"""
hm_content = hm_content.replace(old_toolbar, new_toolbar)

# Inject monthYearString property
month_prop = """    private var monthYearString: String {
        let df = DateFormatter()
        if appSettings.resolvedLanguage == .chinese {
            df.locale = Locale(identifier: "zh_CN")
            df.dateFormat = "yyyy年M月"
        } else {
            df.locale = Locale(identifier: "en_US")
            df.dateFormat = "MMMM yyyy"
        }
        return df.string(from: currentMonthDate)
    }"""
hm_content = hm_content.replace('    private let calendar = Calendar.current\n', '    private let calendar = Calendar.current\n' + month_prop + '\n')

# Inject the month selector above MonthGridCard
month_selector = """                    // Month Selector
                    HStack {
                        Button(action: { withAnimation { currentMonthDate = calendar.date(byAdding: .month, value: -1, to: currentMonthDate) ?? currentMonthDate } }) {
                            Image(systemName: "chevron.left")
                                .frame(width: 44, height: 44)
                                .background(Color.white.opacity(0.8))
                                .clipShape(Circle())
                                .foregroundColor(DS.onSurface)
                        }
                        
                        Spacer()
                        
                        HStack(spacing: 8) {
                            Image(systemName: "calendar")
                                .foregroundColor(DS.primary)
                            Text(monthYearString)
                                .font(.system(size: 16, weight: .bold))
                                .foregroundColor(DS.onSurface)
                        }
                        .padding(.horizontal, 20)
                        .padding(.vertical, 12)
                        .background(Color.white.opacity(0.8))
                        .clipShape(Capsule())
                        
                        Spacer()
                        
                        Button(action: { withAnimation { currentMonthDate = calendar.date(byAdding: .month, value: 1, to: currentMonthDate) ?? currentMonthDate } }) {
                            Image(systemName: "chevron.right")
                                .frame(width: 44, height: 44)
                                .background(Color.white.opacity(0.8))
                                .clipShape(Circle())
                                .foregroundColor(DS.onSurface)
                        }
                    }
                    .padding(.horizontal, 16)
                    
                    // Month Grid Card (Reused from StatisticsView)"""
hm_content = hm_content.replace('                    // Month Grid Card (Reused from StatisticsView)', month_selector)

with open('Sources/HabitMonthDetailView.swift', 'w') as f:
    f.write(hm_content)


# 2. Add translation for "习惯详情"
with open('Sources/LittleHabitTrackerApp.swift', 'r') as f:
    app_content = f.read()

if '"Habit Details": [' not in app_content:
    app_content = app_content.replace('            "Cancel": [', '            "Habit Details": [.chinese: "习惯详情", .english: "Habit Details"],\n            "Cancel": [')
    with open('Sources/LittleHabitTrackerApp.swift', 'w') as f:
        f.write(app_content)

# Apply the translation in HabitStatsDetailView
with open('Sources/HabitStatsDetailView.swift', 'r') as f:
    hs_content = f.read()
hs_content = hs_content.replace('Text("习惯详情")', 'Text("Habit Details".tr(appSettings.resolvedLanguage))')
with open('Sources/HabitStatsDetailView.swift', 'w') as f:
    f.write(hs_content)

