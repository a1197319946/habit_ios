import re

with open('Sources/HomeView.swift', 'r') as f:
    content = f.read()

old_details = """                // Details
                VStack(alignment: .leading, spacing: 8) {
                    HStack(alignment: .lastTextBaseline, spacing: 6) {
                        Text(habit.name)
                            .font(.system(size: 16, weight: .bold))
                            .foregroundColor(DS.onSurface)
                            .lineLimit(1)
                        
                        Text(progressText)
                            .font(.system(size: 12, weight: .medium))
                            .foregroundColor(DS.onSurfaceVariant)
                    }
                    
                    HStack(spacing: 8) {
                        Text(habit.frequencyType == "weekly" ? "本周" : "本月")
                            .font(.system(size: 10, weight: .semibold))
                            .foregroundColor(Color(hex: habit.color))
                            .padding(.horizontal, 6)
                            .padding(.vertical, 3)
                            .background(Color(hex: habit.color).opacity(0.1))
                            .clipShape(Capsule())
                        
                        GeometryReader { geometry in
                            ZStack(alignment: .leading) {
                                Capsule()
                                    .fill(DS.surfaceVariant)
                                    .frame(height: 6)
                                Capsule()
                                    .fill(Color(hex: habit.color))
                                    .frame(width: max(0, min(geometry.size.width, geometry.size.width * CGFloat(progressFraction))), height: 6)
                            }
                        }
                        .frame(height: 6)
                    }
                }"""

new_details = """                // Details
                VStack(alignment: .leading, spacing: 8) {
                    HStack(alignment: .lastTextBaseline, spacing: 6) {
                        Text(habit.name)
                            .font(.system(size: 16, weight: .bold))
                            .foregroundColor(DS.onSurface)
                            .lineLimit(1)
                        
                        Text(progressText)
                            .font(.system(size: 12, weight: .medium))
                            .foregroundColor(DS.onSurfaceVariant)
                        
                        Spacer()
                        
                        Text(habit.frequencyType == "weekly" ? "本周" : "本月")
                            .font(.system(size: 10, weight: .semibold))
                            .foregroundColor(Color(hex: habit.color))
                            .padding(.horizontal, 6)
                            .padding(.vertical, 3)
                            .background(Color(hex: habit.color).opacity(0.1))
                            .clipShape(Capsule())
                    }
                    
                    HStack(spacing: 8) {
                        GeometryReader { geometry in
                            ZStack(alignment: .leading) {
                                Capsule()
                                    .fill(DS.surfaceVariant)
                                    .frame(height: 6)
                                Capsule()
                                    .fill(Color(hex: habit.color))
                                    .frame(width: max(0, min(geometry.size.width, geometry.size.width * CGFloat(progressFraction))), height: 6)
                            }
                        }
                        .frame(height: 6)
                        
                        Text("\\(Int(progressFraction * 100))%")
                            .font(.system(size: 11, weight: .bold))
                            .foregroundColor(DS.onSurfaceVariant)
                    }
                }"""

content = content.replace(old_details, new_details)

with open('Sources/HomeView.swift', 'w') as f:
    f.write(content)
