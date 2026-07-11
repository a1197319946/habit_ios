import re

# 1. Update ConfettiView.swift
with open('Sources/ConfettiView.swift', 'r') as f:
    cv_content = f.read()

# Animate opacity inside the withAnimation block in ConfettiParticle
old_particle = """            .opacity(animate ? 0 : 1)
            .onAppear {
                withAnimation(.easeOut(duration: Double.random(in: 1.2...2.0))) {
                    xOffset = CGFloat.random(in: -180...180)
                    yOffset = CGFloat.random(in: -280...280)
                    rotation = Double.random(in: 360...1080)
                }
            }"""

new_particle = """            .opacity(animate ? 0 : 1)
            .onAppear {
                withAnimation(.easeOut(duration: Double.random(in: 1.2...2.0))) {
                    xOffset = CGFloat.random(in: -180...180)
                    yOffset = CGFloat.random(in: -280...280)
                    rotation = Double.random(in: 360...1080)
                    animate = true
                }
            }"""
cv_content = cv_content.replace(old_particle, new_particle)
cv_content = cv_content.replace('@Binding var animate: Bool', '@State var animate: Bool = false')

# In ConfettiView body
cv_content = cv_content.replace('animate: $animate,', 'animate: false,')
cv_content = cv_content.replace('.onAppear { animate = true }', '')

with open('Sources/ConfettiView.swift', 'w') as f:
    f.write(cv_content)


# 2. Update StatisticsView.swift
with open('Sources/StatisticsView.swift', 'r') as f:
    stats_content = f.read()

old_stats_header = """                    // Title
                    HStack {
                        VStack(alignment: .leading, spacing: 4) {
                            Text("Stats".tr(appSettings.resolvedLanguage))
                                .display()
                                .foregroundColor(DS.primary)
                            Text("A detailed look at your journey.".tr(appSettings.resolvedLanguage))
                                .bodyLg()
                                .foregroundColor(DS.onSurfaceVariant)
                        }
                        
                        Spacer()
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.top, DS.spacingM)
                    .padding(.bottom, DS.spacingS)
                    .padding(.horizontal, 16)
                    
                    // Tabs
                    HStack(spacing: 24) {
                        ForEach(["Weekly", "Monthly", "Yearly", "All"], id: \.self) { tab in
                            Button(action: {
                                withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                                    selectedTab = tab
                                }
                            }) {
                                VStack(spacing: 6) {
                                    Text(tab.tr(appSettings.resolvedLanguage))
                                        .font(.system(size: 18, weight: selectedTab == tab ? .bold : .medium))
                                        .foregroundColor(selectedTab == tab ? DS.onSurface : DS.onSurfaceVariant)
                                    
                                    if selectedTab == tab {
                                        Capsule()
                                            .fill(DS.primary)
                                            .frame(height: 3)
                                            .matchedGeometryEffect(id: "tab_underline", in: animationNamespace)
                                    } else {
                                        Capsule()
                                            .fill(Color.clear)
                                            .frame(height: 3)
                                    }
                                }
                                .padding(.vertical, 8)
                                .fixedSize(horizontal: true, vertical: false)
                            }
                        }
                        Spacer()
                        
                        Button(action: { showArchived.toggle() }) {
                            Text(showArchived ? "Hide Archived".tr(appSettings.resolvedLanguage) : "Show Archived".tr(appSettings.resolvedLanguage))
                                .font(.system(size: 12, weight: .bold))
                                .foregroundColor(showArchived ? DS.onPrimary : DS.primary)
                                .padding(.horizontal, 12)
                                .padding(.vertical, 6)
                                .background(showArchived ? DS.primary : Color.clear)
                                .overlay(
                                    Capsule()
                                        .stroke(DS.primary, lineWidth: showArchived ? 0 : 1)
                                )
                                .clipShape(Capsule())
                        }
                    }"""

new_stats_header = """                    // Title
                    HStack(alignment: .bottom) {
                        VStack(alignment: .leading, spacing: 4) {
                            Text("Stats".tr(appSettings.resolvedLanguage))
                                .display()
                                .foregroundColor(DS.primary)
                            Text("A detailed look at your journey.".tr(appSettings.resolvedLanguage))
                                .bodyLg()
                                .foregroundColor(DS.onSurfaceVariant)
                        }
                        
                        Spacer()
                        
                        Button(action: { showArchived.toggle() }) {
                            Text(showArchived ? "Hide Archived".tr(appSettings.resolvedLanguage) : "Show Archived".tr(appSettings.resolvedLanguage))
                                .font(.system(size: 12, weight: .bold))
                                .foregroundColor(showArchived ? DS.onPrimary : DS.primary)
                                .padding(.horizontal, 12)
                                .padding(.vertical, 6)
                                .background(showArchived ? DS.primary : Color.clear)
                                .overlay(
                                    Capsule()
                                        .stroke(DS.primary, lineWidth: showArchived ? 0 : 1)
                                )
                                .clipShape(Capsule())
                        }
                        .padding(.bottom, 2)
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.top, DS.spacingS)
                    .padding(.bottom, 0)
                    .padding(.horizontal, 16)
                    
                    // Tabs
                    HStack(spacing: 24) {
                        ForEach(["Weekly", "Monthly", "Yearly", "All"], id: \.self) { tab in
                            Button(action: {
                                withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                                    selectedTab = tab
                                }
                            }) {
                                VStack(spacing: 6) {
                                    Text(tab.tr(appSettings.resolvedLanguage))
                                        .font(.system(size: 18, weight: selectedTab == tab ? .bold : .medium))
                                        .foregroundColor(selectedTab == tab ? DS.onSurface : DS.onSurfaceVariant)
                                    
                                    if selectedTab == tab {
                                        Capsule()
                                            .fill(DS.primary)
                                            .frame(height: 3)
                                            .matchedGeometryEffect(id: "tab_underline", in: animationNamespace)
                                    } else {
                                        Capsule()
                                            .fill(Color.clear)
                                            .frame(height: 3)
                                    }
                                }
                                .padding(.vertical, 8)
                                .fixedSize(horizontal: true, vertical: false)
                            }
                        }
                        Spacer()
                    }"""

stats_content = stats_content.replace(old_stats_header, new_stats_header)

with open('Sources/StatisticsView.swift', 'w') as f:
    f.write(stats_content)

