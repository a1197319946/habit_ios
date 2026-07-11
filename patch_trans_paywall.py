import re

with open('Sources/LittleHabitTrackerApp.swift', 'r') as f:
    code = f.read()

target = '            "Mock Premium Status": [.chinese: "模拟高级版状态", .english: "Mock Premium Status"],'
insertion = """            "Mock Premium Status": [.chinese: "模拟高级版状态", .english: "Mock Premium Status"],
            "Little Habit Premium": [.chinese: "小习惯高级版", .english: "Little Habit Premium"],
            "Unlock your full potential": [.chinese: "解锁所有特权与功能", .english: "Unlock your full potential"],
            "Theme Colors": [.chinese: "自定义主题", .english: "Theme Colors"],
            "Personalize your app with custom colors": [.chinese: "丰富的主题色彩个性化你的应用", .english: "Personalize your app with custom colors"],
            "Dark Mode": [.chinese: "深色模式", .english: "Dark Mode"],
            "Reduce eye strain with a sleek dark theme": [.chinese: "时尚的深色主题，缓解眼睛疲劳", .english: "Reduce eye strain with a sleek dark theme"],
            "Protect your habits with Face ID / Touch ID": [.chinese: "使用 Face ID 或 Touch ID 保护你的隐私", .english: "Protect your habits with Face ID / Touch ID"],
            "Unlimited Habits": [.chinese: "无限习惯", .english: "Unlimited Habits"],
            "Create as many habits as you want": [.chinese: "突破限制，创建任意数量的习惯", .english: "Create as many habits as you want"],
            "Import / Export Data": [.chinese: "导入 / 导出数据", .english: "Import / Export Data"],
            "Backup your data to JSON files": [.chinese: "将数据安全备份到 JSON 文件中", .english: "Backup your data to JSON files"],
            "Keep your habits synced across all devices": [.chinese: "让你的习惯在所有设备上保持同步", .english: "Keep your habits synced across all devices"],
            "Monthly": [.chinese: "月度", .english: "Monthly"],
            "Billed monthly": [.chinese: "按月扣款", .english: "Billed monthly"],
            "Yearly": [.chinese: "年度", .english: "Yearly"],
            "Billed yearly": [.chinese: "按年扣款", .english: "Billed yearly"],
            "POPULAR": [.chinese: "最受欢迎", .english: "POPULAR"],
            "Lifetime": [.chinese: "终身买断", .english: "Lifetime"],
            "One-time payment": [.chinese: "一次性支付", .english: "One-time payment"],
            "BEST VALUE": [.chinese: "最超值", .english: "BEST VALUE"],
            "Continue": [.chinese: "继续", .english: "Continue"],
            "By continuing, you agree to our": [.chinese: "继续即表示您同意我们的", .english: "By continuing, you agree to our"],
            "and": [.chinese: "和", .english: "and"],"""

code = code.replace(target, insertion)

with open('Sources/LittleHabitTrackerApp.swift', 'w') as f:
    f.write(code)
