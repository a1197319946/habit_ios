import re

with open('Sources/HomeView.swift', 'r') as f:
    content = f.read()

# Change MoodRecorderView detents from .height(320) back to .large so it fits the new larger content
content = content.replace('.presentationDetents([.height(320)])', '.presentationDetents([.large])')

with open('Sources/HomeView.swift', 'w') as f:
    f.write(content)
