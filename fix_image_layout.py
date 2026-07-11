import re

with open('Sources/HabitMonthDetailView.swift', 'r') as f:
    code = f.read()

old_block = """                // Mood Log (if exists)
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
                        }
                        
                        Spacer(minLength: 8)
                        if let imageData = mood.imageData, let uiImage = UIImage(data: imageData) {
                            Button(action: {
                                selectedFullscreenImage = uiImage
                            }) {
                                Image(uiImage: uiImage)
                                    .resizable()
                                    .scaledToFill()
                                    .frame(width: 48, height: 48)
                                    .clipShape(RoundedRectangle(cornerRadius: 8))
                                    .shadow(color: Color.black.opacity(0.1), radius: 2)
                            }
                            .buttonStyle(PlainButtonStyle())
                        }
                    }
                    .padding(10)
                    .background(Color.black.opacity(0.02))
                    .clipShape(RoundedRectangle(cornerRadius: 12))
                }"""

new_block = """                // Mood Log (if exists)
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
                        
                        Spacer(minLength: 8)
                        
                        if let imageData = mood.imageData, let uiImage = UIImage(data: imageData) {
                            Button(action: {
                                selectedFullscreenImage = uiImage
                            }) {
                                Image(uiImage: uiImage)
                                    .resizable()
                                    .scaledToFill()
                                    .frame(width: 48, height: 48)
                                    .clipShape(RoundedRectangle(cornerRadius: 8))
                                    .shadow(color: Color.black.opacity(0.1), radius: 2)
                            }
                            .buttonStyle(PlainButtonStyle())
                        }
                    }
                    .padding(10)
                    .background(Color.black.opacity(0.02))
                    .clipShape(RoundedRectangle(cornerRadius: 12))
                }"""

code = code.replace(old_block, new_block)

with open('Sources/HabitMonthDetailView.swift', 'w') as f:
    f.write(code)
