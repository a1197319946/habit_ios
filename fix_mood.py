import re

with open('Sources/MoodRecorderView.swift', 'r') as f:
    content = f.read()

# Make layout more compact
content = content.replace('spacing: DS.spacingXL', 'spacing: DS.spacingM')
content = content.replace('spacing: DS.spacingL', 'spacing: 16')
content = content.replace('.frame(height: 120)', '.frame(height: 100)')
content = content.replace('.padding(.bottom, 100)', '.padding(.bottom, 80)')

# Fix button style
old_button = """                Button(action: saveMood) {
                    Text("记录")
                        .font(.system(size: 18, weight: .bold))
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 16)
                        .background(Color(hex: "#5C55D9")) // Purple/Blue color from screenshot
                        .clipShape(Capsule())
                }"""
new_button = """                Button(action: saveMood) {
                    Text("记录")
                        .font(.system(size: 16, weight: .bold))
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .frame(height: 52)
                        .background(DS.primary)
                        .clipShape(Capsule())
                }"""
content = content.replace(old_button, new_button)

with open('Sources/MoodRecorderView.swift', 'w') as f:
    f.write(content)
