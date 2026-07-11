import re

with open('Sources/HabitDetailView.swift', 'r') as f:
    content = f.read()

# Make layout more compact
content = content.replace('VStack(spacing: DS.spacingM)', 'VStack(spacing: DS.spacingS)')
content = content.replace('padding(.top, DS.spacingL)', 'padding(.top, 12)')
content = content.replace('Spacer().frame(height: 120)', 'Spacer().frame(height: 100)')

# Change background to uniform secondary color
content = content.replace('.background(AmbientBackground())', '.background(Color(hex: "#F8F9FA").ignoresSafeArea())')

# Change Icon picker items to Circle
old_icon_picker = """                                                    ZStack {
                                                        RoundedRectangle(cornerRadius: 10, style: .continuous)
                                                            .fill(icon == iconName ? DS.primaryContainer : DS.surfaceContainerLow)
                                                            .frame(width: 36, height: 36)
                                                            .overlay(
                                                                RoundedRectangle(cornerRadius: 10, style: .continuous)
                                                                    .stroke(icon == iconName ? Color.clear : DS.outlineVariant, lineWidth: 1)
                                                            )
                                                        
                                                        Image(systemName: iconName)
                                                            .font(.system(size: 16))
                                                            .foregroundColor(icon == iconName ? DS.onPrimaryContainer : DS.onSurfaceVariant)
                                                    }"""
new_icon_picker = """                                                    ZStack {
                                                        Circle()
                                                            .fill(icon == iconName ? DS.primaryContainer : DS.surfaceContainerLow)
                                                            .frame(width: 36, height: 36)
                                                            .overlay(
                                                                Circle()
                                                                    .stroke(icon == iconName ? Color.clear : DS.outlineVariant, lineWidth: 1)
                                                            )
                                                        
                                                        Image(systemName: iconName)
                                                            .font(.system(size: 16))
                                                            .foregroundColor(icon == iconName ? DS.onPrimaryContainer : DS.onSurfaceVariant)
                                                    }"""
content = content.replace(old_icon_picker, new_icon_picker)

with open('Sources/HabitDetailView.swift', 'w') as f:
    f.write(content)
