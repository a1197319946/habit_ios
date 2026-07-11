import re

with open('Sources/MoodRecorderView.swift', 'r') as f:
    content = f.read()

# Fix emoji picker layout
content = content.replace('HStack(spacing: 20)', 'HStack(spacing: 12)')
content = content.replace('frame(width: 56, height: 56)', 'frame(width: 48, height: 48)')
content = content.replace('font(.system(size: 28))', 'font(.system(size: 26))')

# Timeline styling (TimelineItem)
# We want to change the line and padding
# padding(.padding(.leading, DS.spacingM)) and padding(.bottom, DS.spacingXL) to be smaller
content = content.replace('.padding(.leading, DS.spacingM)', '.padding(.leading, DS.spacingS)')
content = content.replace('.padding(.bottom, DS.spacingXL)', '.padding(.bottom, DS.spacingL)')

with open('Sources/MoodRecorderView.swift', 'w') as f:
    f.write(content)
