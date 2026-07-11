import re

with open('Sources/LittleHabitTrackerApp.swift', 'r') as f:
    code = f.read()

new_translations = """
            "Appearance": [.chinese: "外观", .english: "Appearance"],
            "App Lock": [.chinese: "应用锁", .english: "App Lock"],
            "Data": [.chinese: "数据", .english: "Data"],
            "About": [.chinese: "关于", .english: "About"],
            "Start of Week": [.chinese: "每周第一天", .english: "Start of Week"],
            "Monday": [.chinese: "周一", .english: "Monday"],
            "Sunday": [.chinese: "周日", .english: "Sunday"],
            "iCloud Sync": [.chinese: "iCloud 同步", .english: "iCloud Sync"],
            "Import Data": [.chinese: "导入数据", .english: "Import Data"],
            "Export Data": [.chinese: "导出数据", .english: "Export Data"],
            "Terms of Service": [.chinese: "使用条款", .english: "Terms of Service"],
            "Privacy Policy": [.chinese: "隐私政策", .english: "Privacy Policy"],
            "On": [.chinese: "开启", .english: "On"],
            "Off": [.chinese: "关闭", .english: "Off"],
            "Upgrade to Premium": [.chinese: "升级至高级版", .english: "Upgrade to Premium"],
            "Unlock all features": [.chinese: "解锁全部特权与功能", .english: "Unlock all features"],
            "Premium Member": [.chinese: "高级版会员", .english: "Premium Member"],
            "All features unlocked": [.chinese: "已解锁全部特权与功能", .english: "All features unlocked"],
"""

# Try to insert them after "Settings"
target = '            "Settings": [.chinese: "设置", .english: "Settings"],'
if target in code:
    code = code.replace(target, target + new_translations)
else:
    print("Warning: Could not find target insertion point")

with open('Sources/LittleHabitTrackerApp.swift', 'w') as f:
    f.write(code)
