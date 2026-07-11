with open('Sources/AmountCheckinSheet.swift', 'r') as f:
    content = f.read()

content = content.replace('DS.surface\n                        .frame(height: 100)', 'Color(UIColor.secondarySystemBackground)\n                        .frame(height: 100)')

with open('Sources/AmountCheckinSheet.swift', 'w') as f:
    f.write(content)
