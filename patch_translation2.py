with open('Sources/LittleHabitTrackerApp.swift', 'r') as f:
    code = f.read()

target = '            "Today": ["zh": "今日", "en": "Today"],'
insertion = """            "Today": ["zh": "今日", "en": "Today"],
            "App Locked": ["zh": "应用已锁定", "en": "App Locked"],
            "Unlock": ["zh": "解锁", "en": "Unlock"],
            "Unlock Little Habit": ["zh": "解锁小日常", "en": "Unlock Little Habit"],
            "Data": ["zh": "数据", "en": "Data"],
            "About": ["zh": "关于", "en": "About"],
            "Export Data": ["zh": "导出数据", "en": "Export Data"],
            "Import Data": ["zh": "导入数据", "en": "Import Data"],
            "Requires Premium": ["zh": "需要高级版", "en": "Requires Premium"],
            "Habit Limit Reached": ["zh": "习惯数量已达上限", "en": "Habit Limit Reached"],
            "You can only create up to 5 habits for free.": ["zh": "免费版最多只能创建 5 个习惯。", "en": "You can only create up to 5 habits for free."],
"""

code = code.replace(target, insertion)

with open('Sources/LittleHabitTrackerApp.swift', 'w') as f:
    f.write(code)
