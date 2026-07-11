import re
with open('Sources/CheckinSuccessView.swift', 'r') as f:
    content = f.read()

# 1. Remove state variable
content = content.replace('    @State private var showConfetti = false\n', '')

# 2. Update Header
old_header = """            // Header + Icon + Name
            // Header + Icon + Name
            HStack(spacing: 8) {
                Text("Check-in Successful".tr(appSettings.resolvedLanguage))
                    .font(.system(size: 20, weight: .bold, design: .rounded))
                    .foregroundColor(DS.textPrimary)
                
                ZStack {
                    Circle()
                        .fill(Color(hex: habit.color).opacity(0.1))
                        .frame(width: 32, height: 32)
                    
                    Image(systemName: habit.icon)
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundColor(Color(hex: habit.color))
                }
                
                Text(habit.name)
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(DS.textSecondary)
            }
            .scaleEffect(appeared ? 1.0 : 0.6)
            .animation(.spring(response: 0.4, dampingFraction: 0.65), value: appeared)
            .padding(.bottom, 32)"""

new_header = """            // Header + Icon + Name
            VStack(spacing: 12) {
                Text("Check-in Successful".tr(appSettings.resolvedLanguage))
                    .font(.system(size: 24, weight: .bold, design: .rounded))
                    .foregroundColor(DS.textPrimary)
                
                HStack(spacing: 8) {
                    ZStack {
                        Circle()
                            .fill(Color(hex: habit.color).opacity(0.1))
                            .frame(width: 32, height: 32)
                        
                        Image(systemName: habit.icon)
                            .font(.system(size: 16, weight: .semibold))
                            .foregroundColor(Color(hex: habit.color))
                    }
                    
                    Text(habit.name)
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundColor(DS.textSecondary)
                }
            }
            .padding(.bottom, 32)"""
content = content.replace(old_header, new_header)

# 3. Remove overlay and onAppear showConfetti
old_overlay = """            .navigationBarHidden(true)
        }
        .overlay {
            if showConfetti {
                ConfettiView()
            }
        }
    }"""
new_overlay = """            .navigationBarHidden(true)
        }
    }"""
content = content.replace(old_overlay, new_overlay)

old_onAppear = """        .background(DS.bgPrimary)
            .onAppear {
                UIImpactFeedbackGenerator(style: .medium).impactOccurred()
                appeared = true
                showConfetti = true
                DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
                    showConfetti = false
                }
            }
            .navigationBarHidden(true)"""
new_onAppear = """        .background(DS.bgPrimary)
            .onAppear {
                UIImpactFeedbackGenerator(style: .medium).impactOccurred()
                appeared = true
            }
            .navigationBarHidden(true)"""
content = content.replace(old_onAppear, new_onAppear)

with open('Sources/CheckinSuccessView.swift', 'w') as f:
    f.write(content)

