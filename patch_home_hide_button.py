import re

with open('Sources/HomeView.swift', 'r') as f:
    content = f.read()

old_header = """                        // Top Actions
                        HStack {
                            Button(action: {
                                withAnimation { hideCompleted.toggle() }
                            }) {
                                Text(hideCompleted ? "显示已打卡" : "隐藏已打卡")
                                    .font(.system(size: 13, weight: .medium))
                                    .foregroundColor(DS.onSurfaceVariant)
                            }
                            
                            Spacer()
                            
                            NavigationLink(destination: HabitListView()) {
                                Text("管理习惯 >")
                                    .font(.system(size: 13, weight: .medium))
                                    .foregroundColor(DS.primary)
                            }
                        }
                        .padding(.horizontal, DS.spacingL)
                        .padding(.bottom, 4)"""

new_header = """                        // Top Actions
                        HStack {
                            Spacer()
                            
                            Button(action: {
                                withAnimation { hideCompleted.toggle() }
                            }) {
                                Text(hideCompleted ? "显示已打卡" : "隐藏已打卡")
                                    .font(.system(size: 12, weight: .bold))
                                    .foregroundColor(hideCompleted ? DS.onPrimary : DS.primary)
                                    .padding(.horizontal, 12)
                                    .padding(.vertical, 6)
                                    .background(hideCompleted ? DS.primary : Color.clear)
                                    .overlay(
                                        Capsule()
                                            .stroke(DS.primary, lineWidth: hideCompleted ? 0 : 1)
                                    )
                                    .clipShape(Capsule())
                            }
                        }
                        .padding(.horizontal, DS.spacingL)
                        .padding(.bottom, 4)"""

content = content.replace(old_header, new_header)

with open('Sources/HomeView.swift', 'w') as f:
    f.write(content)
