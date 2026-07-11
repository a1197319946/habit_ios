import re

with open('Sources/CheckinSuccessView.swift', 'r') as f:
    content = f.read()

# Add state variable
content = content.replace('@State private var appeared = false', '@State private var appeared = false\n    @State private var showConfetti = false')

# Add overlay and update onAppear
old_onAppear = """        .background(DS.bgPrimary)
            .onAppear {
                UIImpactFeedbackGenerator(style: .medium).impactOccurred()
                appeared = true
            }
            .navigationBarHidden(true)
        }
    }"""

new_onAppear = """        .background(DS.bgPrimary)
            .onAppear {
                UIImpactFeedbackGenerator(style: .medium).impactOccurred()
                appeared = true
                showConfetti = true
                DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
                    showConfetti = false
                }
            }
            .navigationBarHidden(true)
        }
        .overlay {
            if showConfetti {
                ConfettiView()
            }
        }
    }"""
content = content.replace(old_onAppear, new_onAppear)

with open('Sources/CheckinSuccessView.swift', 'w') as f:
    f.write(content)

