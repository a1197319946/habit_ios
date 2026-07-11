import re

with open('Sources/SettingsView.swift', 'r') as f:
    code = f.read()

target = '            .background(DS.bgPrimary)'
insertion = '            .background(AmbientBackground())'

code = code.replace(target, insertion)

with open('Sources/SettingsView.swift', 'w') as f:
    f.write(code)
