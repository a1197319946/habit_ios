import re
with open('Sources/HomeView.swift', 'r') as f:
    content = f.read()

# Make sure we didn't miss replacing "This Week" to "Week"
content = content.replace('"This Week"', '"Week"')
content = content.replace('"This Month"', '"Month"')
content = content.replace('.padding(.horizontal, DS.spacingL)', '.padding(.horizontal, 16)')

with open('Sources/HomeView.swift', 'w') as f:
    f.write(content)
