import re

with open('Sources/HabitMonthDetailView.swift', 'r') as f:
    code = f.read()

old_mood = """                // Mood Log (if exists)
                if let mood = getMoodForDate(checkin.dateString) {
                    HStack(alignment: .top, spacing: 10) {
                        Text(emoji(for: mood.type))
                            .font(.system(size: 20))
                            
                        if !mood.text.isEmpty {
                            Text(mood.text)
                                .font(.system(size: 13))
                                .foregroundColor(DS.onSurfaceVariant)
                                .fixedSize(horizontal: false, vertical: true)
                        }
                        Spacer()
                    }
                    .padding(10)
                    .background(Color.black.opacity(0.02))
                    .clipShape(RoundedRectangle(cornerRadius: 12))
                }"""

new_mood = """                // Mood Log (if exists)
                if let mood = getMoodForDate(checkin.dateString) {
                    VStack(alignment: .leading, spacing: 8) {
                        HStack(alignment: .top, spacing: 10) {
                            Text(emoji(for: mood.type))
                                .font(.system(size: 20))
                                
                            if !mood.text.isEmpty {
                                Text(mood.text)
                                    .font(.system(size: 13))
                                    .foregroundColor(DS.onSurfaceVariant)
                                    .fixedSize(horizontal: false, vertical: true)
                            }
                            Spacer()
                        }
                        
                        if let imageData = mood.imageData, let uiImage = UIImage(data: imageData) {
                            Image(uiImage: uiImage)
                                .resizable()
                                .scaledToFill()
                                .frame(height: 120)
                                .frame(maxWidth: .infinity)
                                .clipShape(RoundedRectangle(cornerRadius: 8))
                                .padding(.top, 4)
                        }
                    }
                    .padding(10)
                    .background(Color.black.opacity(0.02))
                    .clipShape(RoundedRectangle(cornerRadius: 12))
                }"""
code = code.replace(old_mood, new_mood)

with open('Sources/HabitMonthDetailView.swift', 'w') as f:
    f.write(code)

