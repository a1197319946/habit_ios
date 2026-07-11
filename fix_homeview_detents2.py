import re

with open('Sources/HomeView.swift', 'r') as f:
    content = f.read()

# Change CheckinSuccessView detents from .height(380) to .height(440)
content = content.replace('.presentationDetents([.height(380)])', '.presentationDetents([.height(440)])')

# Change MoodRecorderView detents from .large to .height(540)
content = content.replace('.presentationDetents([.large])', '.presentationDetents([.height(540)])')

with open('Sources/HomeView.swift', 'w') as f:
    f.write(content)
