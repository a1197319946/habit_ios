import re
with open('Sources/HomeView.swift', 'r') as f:
    content = f.read()

content = content.replace('    @State private var showConfetti = false\n', '')
content = content.replace('        .overlay { if showConfetti { ConfettiView() } }\n', '')

old_trigger = """    private func triggerSuccessSequence() {
        showConfetti = true
        let impact = UIImpactFeedbackGenerator(style: .medium)
        impact.impactOccurred()
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            showConfetti = false
            showingSuccessModal = true
        }
    }"""
new_trigger = """    private func triggerSuccessSequence() {
        let impact = UIImpactFeedbackGenerator(style: .medium)
        impact.impactOccurred()
        showingSuccessModal = true
    }"""
content = content.replace(old_trigger, new_trigger)

with open('Sources/HomeView.swift', 'w') as f:
    f.write(content)
