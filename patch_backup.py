import re
with open('Sources/DataBackupManager.swift', 'r') as f:
    code = f.read()

target = "    var dateString: String // I need to save the checkin date some other way if we relate it to habit. Wait, in Models.swift MoodRecord has a timestamp, not dateString. Let's use timestamp!\n"
code = code.replace(target, "")

with open('Sources/DataBackupManager.swift', 'w') as f:
    f.write(code)
