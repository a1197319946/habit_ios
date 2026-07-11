import re

# 1. Modify HomeView.swift
with open('Sources/HomeView.swift', 'r') as f:
    content = f.read()

content = content.replace('.presentationDetents([.height(480)])', '.presentationDetents([.height(380)])', 1)
content = content.replace('.presentationDetents([.height(480)])', '.presentationDetents([.height(320)])', 1)

with open('Sources/HomeView.swift', 'w') as f:
    f.write(content)


# 2. Modify CheckinSuccessView.swift
with open('Sources/CheckinSuccessView.swift', 'r') as f:
    content = f.read()

old_vstack = """        VStack(spacing: 0) {
            
            // Icon + name
            VStack(spacing: DS.spacingM) {"""
new_vstack = """        VStack(spacing: 0) {
            Spacer().frame(height: 32)
            // Icon + name
            VStack(spacing: DS.spacingM) {"""
content = content.replace(old_vstack, new_vstack)

with open('Sources/CheckinSuccessView.swift', 'w') as f:
    f.write(content)


# 3. Modify MoodRecorderView.swift
with open('Sources/MoodRecorderView.swift', 'r') as f:
    content = f.read()

# We need to rewrite MoodRecorderView's body to be simpler, without ScrollView and without Timeline.
new_body = """    var body: some View {
        ZStack {
            AmbientBackground()
            
            VStack(spacing: 0) {
                // Toolbar
                HStack {
                    Spacer()
                    Button(action: { dismiss() }) {
                        Image(systemName: "xmark.circle.fill")
                            .foregroundColor(DS.onSurfaceVariant)
                            .font(.system(size: 24))
                    }
                }
                .padding(.horizontal, DS.spacingL)
                .padding(.top, DS.spacingM)
                .padding(.bottom, 8)
                
                VStack(alignment: .leading, spacing: DS.spacingL) {
                    
                    // Header
                    VStack(alignment: .leading, spacing: DS.spacingS) {
                        Text("记录心情")
                            .font(.system(size: 32, weight: .bold))
                            .foregroundColor(DS.onSurface)
                        Text("此刻感觉如何？")
                            .font(.system(size: 16))
                            .foregroundColor(DS.onSurfaceVariant)
                    }
                    .padding(.horizontal, DS.spacingL)
                    .padding(.top, 8)
                    
                    // Input Form
                    VStack(spacing: DS.spacingL) {
                        HStack(spacing: 12) {
                            ForEach(moods, id: \.self) { mood in
                                Button(action: {
                                    withAnimation { selectedMood = mood }
                                }) {
                                    ZStack {
                                        Circle()
                                            .fill(selectedMood == mood ? DS.primaryContainer : DS.surfaceContainer)
                                            .frame(width: 48, height: 48)
                                            
                                        if selectedMood == mood {
                                            Circle()
                                                .stroke(DS.primary, lineWidth: 2)
                                                .frame(width: 48, height: 48)
                                        }
                                        
                                        Image(systemName: moodIcon(for: mood))
                                            .font(.system(size: 24))
                                            .foregroundColor(moodColor(for: mood))
                                    }
                                }
                            }
                        }
                        
                        TextField("写点什么...", text: $noteText)
                            .padding(16)
                            .background(Color.white.opacity(0.8))
                            .clipShape(RoundedRectangle(cornerRadius: 16))
                            .overlay(RoundedRectangle(cornerRadius: 16).stroke(DS.outlineVariant, lineWidth: 1))
                        
                        Button(action: saveMood) {
                            Text("保存")
                                .font(.system(size: 16, weight: .bold))
                                .foregroundColor(.white)
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 14)
                                .background(DS.primary)
                                .clipShape(Capsule())
                        }
                    }
                    .padding(.horizontal, DS.spacingL)
                    
                    Spacer()
                }
            }
        }
    }"""

# Use regex to replace the entire body property
pattern = re.compile(r'    var body: some View \{.*?(?=^\s+private func saveMood\(\))', re.MULTILINE | re.DOTALL)
content = re.sub(pattern, new_body + '\n    \n', content)

with open('Sources/MoodRecorderView.swift', 'w') as f:
    f.write(content)
