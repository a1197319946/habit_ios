with open('Sources/AmountCheckinSheet.swift', 'r') as f:
    content = f.read()

content = content.replace('Color(hex: "#F2F2F7")', 'DS.surface')

with open('Sources/AmountCheckinSheet.swift', 'w') as f:
    f.write(content)
