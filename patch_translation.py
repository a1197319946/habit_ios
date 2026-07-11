with open('Sources/LittleHabitTrackerApp.swift', 'r') as f:
    code = f.read()

target = '            "Today": ["zh": "今日", "en": "Today"],'
insertion = """            "Today": ["zh": "今日", "en": "Today"],
            "Little Habit Premium": ["zh": "小日常高级版", "en": "Little Habit Premium"],
            "Unlock your full potential": ["zh": "解锁全部高级功能", "en": "Unlock your full potential"],
            "Theme Colors": ["zh": "专属主题色", "en": "Theme Colors"],
            "Personalize your app with custom colors": ["zh": "个性化定制你的专属色彩", "en": "Personalize your app with custom colors"],
            "Dark Mode": ["zh": "暗黑模式", "en": "Dark Mode"],
            "Reduce eye strain with a sleek dark theme": ["zh": "夜间模式，呵护双眼", "en": "Reduce eye strain with a sleek dark theme"],
            "App Lock": ["zh": "应用锁", "en": "App Lock"],
            "Protect your habits with Face ID / Touch ID": ["zh": "支持面容与指纹，保护隐私", "en": "Protect your habits with Face ID / Touch ID"],
            "Unlimited Habits": ["zh": "无限习惯数量", "en": "Unlimited Habits"],
            "Create as many habits as you want": ["zh": "告别数量限制，养成无限可能", "en": "Create as many habits as you want"],
            "Import / Export Data": ["zh": "导入与导出", "en": "Import / Export Data"],
            "Backup your data to JSON files": ["zh": "自由备份数据，永不丢失", "en": "Backup your data to JSON files"],
            "iCloud Sync": ["zh": "iCloud 同步", "en": "iCloud Sync"],
            "Keep your habits synced across all devices": ["zh": "多设备无缝自动同步", "en": "Keep your habits synced across all devices"],
            "Monthly": ["zh": "月度会员", "en": "Monthly"],
            "Billed monthly": ["zh": "按月续订", "en": "Billed monthly"],
            "Yearly": ["zh": "年度会员", "en": "Yearly"],
            "Billed yearly": ["zh": "按年续订", "en": "Billed yearly"],
            "Lifetime": ["zh": "终身会员", "en": "Lifetime"],
            "One-time payment": ["zh": "一次性买断，终身可用", "en": "One-time payment"],
            "BEST VALUE": ["zh": "最划算", "en": "BEST VALUE"],
            "POPULAR": ["zh": "最受欢迎", "en": "POPULAR"],
            "Continue": ["zh": "继续并购买", "en": "Continue"],
            "By continuing, you agree to our": ["zh": "继续即表示您同意我们的", "en": "By continuing, you agree to our"],
            "Terms of Service": ["zh": "使用条款", "en": "Terms of Service"],
            "and": ["zh": "与", "en": "and"],
            "Privacy Policy": ["zh": "隐私政策", "en": "Privacy Policy"],
"""

code = code.replace(target, insertion)

with open('Sources/LittleHabitTrackerApp.swift', 'w') as f:
    f.write(code)
