import SwiftUI
import SwiftData
import PhotosUI

struct MoodRecorderView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject private var appSettings: AppSettings
    
    var habit: Habit?
    
    @State private var selectedMood: String = "happy"
    @State private var noteText: String = ""
    @State private var selectedItem: PhotosPickerItem? = nil
    @State private var selectedImageData: Data? = nil
    
    let moods = [
        ("excited", "😆", "激动"),
        ("happy", "🙂", "开心"),
        ("normal", "😐", "一般"),
        ("down", "😞", "失落"),
        ("angry", "😡", "愤怒")
    ]
    
    init(habit: Habit? = nil) {
        self.habit = habit
    }
    
    private var subtitle: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-M-d"
        let dateStr = formatter.string(from: Date())
        if let h = habit {
            return "\(dateStr) · \(h.name)"
        }
        return dateStr
    }
    
    var body: some View {
        ZStack {
            DS.bgPrimary.ignoresSafeArea()
            
            VStack(spacing: 0) {
                // Header & Close Button
                HStack(alignment: .top) {
                    VStack(alignment: .leading, spacing: 8) {
                        Text("记录心情")
                            .font(.system(size: 24, weight: .bold))
                            .foregroundColor(DS.onSurface)
                        Text(subtitle)
                            .font(.system(size: 14))
                            .foregroundColor(DS.onSurfaceVariant)
                    }
                    Spacer()
                    Button(action: { dismiss() }) {
                        Image(systemName: "xmark")
                            .foregroundColor(DS.onSurfaceVariant)
                            .font(.system(size: 20))
                            .padding(8)
                    }
                }
                .padding(.horizontal, DS.spacingL)
                .padding(.top, DS.spacingL)
                .padding(.bottom, DS.spacingM)
                
                ScrollView(showsIndicators: false) {
                    VStack(alignment: .leading, spacing: DS.spacingM) {
                        
                        // Mood Section
                        VStack(alignment: .leading, spacing: DS.spacingM) {
                            HStack(spacing: 4) {
                                Text("当前心情")
                                    .font(.system(size: 16, weight: .bold))
                                    .foregroundColor(DS.onSurface)
                                Text("*")
                                    .font(.system(size: 16, weight: .bold))
                                    .foregroundColor(.red)
                            }
                            
                            HStack(spacing: 12) {
                                ForEach(moods, id: \.0) { mood in
                                    Button(action: {
                                        withAnimation { selectedMood = mood.0 }
                                    }) {
                                        VStack(spacing: 8) {
                                            Text(mood.1)
                                                .font(.system(size: 32))
                                            Text(mood.2)
                                                .font(.system(size: 14))
                                                .foregroundColor(DS.onSurfaceVariant)
                                        }
                                        .frame(maxWidth: .infinity)
                                        .padding(.vertical, 12)
                                        .background(selectedMood == mood.0 ? DS.surfaceVariant : DS.surface)
                                        .clipShape(RoundedRectangle(cornerRadius: 16))
                                    }
                                }
                            }
                        }
                        
                        // Thoughts Section
                        VStack(alignment: .leading, spacing: DS.spacingM) {
                            Text("想法 (选填)")
                                .font(.system(size: 16, weight: .bold))
                                .foregroundColor(DS.onSurface)
                            
                            ZStack(alignment: .bottomTrailing) {
                                TextEditor(text: $noteText)
                                    .frame(height: 100)
                                    .padding(12)
                                    .background(DS.surfaceVariant)
                                    .clipShape(RoundedRectangle(cornerRadius: 12))
                                    .scrollContentBackground(.hidden)
                                    .overlay(
                                        VStack {
                                            HStack {
                                                if noteText.isEmpty {
                                                    Text("写下这一刻的想法...")
                                                        .foregroundColor(Color.gray.opacity(0.6))
                                                        .padding(.top, 20)
                                                        .padding(.leading, 16)
                                                }
                                                Spacer()
                                            }
                                            Spacer()
                                        }
                                    )
                                    .onChange(of: noteText) { newValue in
                                        if newValue.count > 200 {
                                            noteText = String(newValue.prefix(200))
                                        }
                                    }
                                
                                Text("\(noteText.count)/200")
                                    .font(.system(size: 14))
                                    .foregroundColor(DS.onSurfaceVariant)
                                    .padding(.bottom, -24)
                                    .padding(.trailing, 4)
                            }
                            .padding(.bottom, 24) // Space for the counter
                        }
                        
                        // Image Section
                        VStack(alignment: .leading, spacing: DS.spacingM) {
                            Text("图片 (选填)")
                                .font(.system(size: 16, weight: .bold))
                                .foregroundColor(DS.onSurface)
                            
                            if let data = selectedImageData, let uiImage = UIImage(data: data) {
                                ZStack(alignment: .topTrailing) {
                                    Image(uiImage: uiImage)
                                        .resizable()
                                        .scaledToFill()
                                        .frame(width: 80, height: 80)
                                        .clipShape(RoundedRectangle(cornerRadius: 12))
                                    
                                    Button(action: {
                                        selectedItem = nil
                                        selectedImageData = nil
                                    }) {
                                        Image(systemName: "xmark.circle.fill")
                                            .foregroundColor(.gray)
                                            .background(DS.surface.clipShape(Circle()))
                                            .offset(x: 8, y: -8)
                                    }
                                }
                            } else {
                                PhotosPicker(selection: $selectedItem, matching: .images, photoLibrary: .shared()) {
                                    VStack(spacing: 8) {
                                        Image(systemName: "camera")
                                            .font(.system(size: 24))
                                            .foregroundColor(.gray)
                                        Text("添加图片")
                                            .font(.system(size: 12))
                                            .foregroundColor(.gray)
                                    }
                                    .frame(width: 80, height: 80)
                                    .background(DS.surface)
                                    .clipShape(RoundedRectangle(cornerRadius: 12))
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 12)
                                            .strokeBorder(style: StrokeStyle(lineWidth: 1, dash: [4]))
                                            .foregroundColor(Color.gray.opacity(0.5))
                                    )
                                }
                                .onChange(of: selectedItem) { newItem in
                                    Task {
                                        if let data = try? await newItem?.loadTransferable(type: Data.self) {
                                            selectedImageData = data
                                        }
                                    }
                                }
                            }
                        }
                    }
                    .padding(.horizontal, DS.spacingL)
                    .padding(.bottom, 80)
                }
            }
            
            // Bottom Button
            VStack {
                Spacer()
                Button(action: saveMood) {
                    Text("记录")
                        .font(.system(size: 16, weight: .bold))
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .frame(height: 52)
                        .background(DS.primary)
                        .clipShape(Capsule())
                }
                .padding(.horizontal, DS.spacingL)
                .padding(.bottom, DS.spacingL)
                .background(
                    LinearGradient(
                        colors: [DS.surface.opacity(0), DS.surface],
                        startPoint: .top,
                        endPoint: .bottom
                    )
                    .frame(height: 100)
                    .offset(y: 20)
                )
            }
        }
    }
    
    private func saveMood() {
        let record = MoodRecord(type: selectedMood, text: noteText)
        if let data = selectedImageData {
            record.imageData = data
        }
        if let h = habit {
            record.habit = h
        }
        modelContext.insert(record)
        try? modelContext.save()
        dismiss()
    }
}
