import re

with open('Sources/HomeView.swift', 'r') as f:
    content = f.read()

# Change MoodRecorderView detents from .height(540) to .height(680)
content = content.replace('.presentationDetents([.height(540)])', '.presentationDetents([.height(680)])')

with open('Sources/HomeView.swift', 'w') as f:
    f.write(content)
