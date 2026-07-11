with open('Sources/LittleHabitTrackerApp.swift', 'r') as f:
    code = f.read()

target = '            "Today": ["zh": "今日", "en": "Today"],'
insertion = """            "Today": ["zh": "今日", "en": "Today"],
            "Upgrade to Premium": ["zh": "升级至高级版", "en": "Upgrade to Premium"],
            "Unlock all features": ["zh": "解锁全部特权与功能", "en": "Unlock all features"],
            "Premium Member": ["zh": "高级版会员", "en": "Premium Member"],
            "All features unlocked": ["zh": "已解锁全部特权与功能", "en": "All features unlocked"],
"""

code = code.replace(target, insertion)

with open('Sources/LittleHabitTrackerApp.swift', 'w') as f:
    f.write(code)
