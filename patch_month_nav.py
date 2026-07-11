import re

with open('Sources/HabitMonthDetailView.swift', 'r') as f:
    content = f.read()

old_toolbar = """        .toolbar {
            ToolbarItem(placement: .navigationBarLeading) {
                Button(action: { dismiss() }) {
                    Image(systemName: "chevron.left")
                        .font(.system(size: 16, weight: .bold))
                        .foregroundColor(DS.onSurface)
                        .padding(8)
                        .background(Color.clear)
                        .clipShape(Circle())
                }
            }
        }"""

new_toolbar = """        .toolbar {
            ToolbarItem(placement: .navigationBarLeading) {
                Button(action: { dismiss() }) {
                    Image(systemName: "chevron.left")
                        .font(.system(size: 16, weight: .bold))
                        .foregroundColor(DS.onSurface)
                        .padding(8)
                        .background(Color.clear)
                        .clipShape(Circle())
                }
            }
            ToolbarItem(placement: .navigationBarTrailing) {
                HStack(spacing: 8) {
                    Button(action: { 
                        if let newDate = calendar.date(byAdding: .month, value: -1, to: currentMonthDate) {
                            currentMonthDate = newDate
                        }
                    }) {
                        Image(systemName: "chevron.left.circle.fill")
                            .font(.system(size: 22))
                            .foregroundColor(DS.surfaceContainerLow)
                            .overlay(Image(systemName: "chevron.left").font(.system(size: 10, weight: .bold)).foregroundColor(DS.onSurfaceVariant))
                    }
                    Button(action: { 
                        if let newDate = calendar.date(byAdding: .month, value: 1, to: currentMonthDate) {
                            currentMonthDate = newDate
                        }
                    }) {
                        Image(systemName: "chevron.right.circle.fill")
                            .font(.system(size: 22))
                            .foregroundColor(DS.surfaceContainerLow)
                            .overlay(Image(systemName: "chevron.right").font(.system(size: 10, weight: .bold)).foregroundColor(DS.onSurfaceVariant))
                    }
                }
            }
        }"""

content = content.replace(old_toolbar, new_toolbar)

with open('Sources/HabitMonthDetailView.swift', 'w') as f:
    f.write(content)
