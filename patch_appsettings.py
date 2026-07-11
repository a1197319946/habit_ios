with open('Sources/LittleHabitTrackerApp.swift', 'r') as f:
    code = f.read()

code = code.replace("@Published var showPaywall: Bool = false", "@Published var showPaywall: Bool = false\n    @Published var showPaywallFromSettings: Bool = false")

with open('Sources/LittleHabitTrackerApp.swift', 'w') as f:
    f.write(code)
