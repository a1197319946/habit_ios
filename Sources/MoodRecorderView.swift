import SwiftUI
import SwiftData
import PhotosUI

struct MoodRecorderView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    
    let habit: Habit
    
    @State private var selectedMood: String = "normal"
    @State private var thoughtsText: String = ""
    @State private var selectedItem: PhotosPickerItem?
    @State private var imageData: Data?
    
    let moods = [
        ("excited", "🤩", "激动"),
        ("happy", "😊", "开心"),
        ("normal", "😐", "一般"),
        ("down", "😔", "失落"),
        ("angry", "😡", "愤怒")
    ]
    
    var body: some View {
        VStack(spacing: 0) {
            // Header
            HStack {
                Button(action: { dismiss() }) {
                    Image(systemName: "xmark.circle.fill")
                        .font(.system(size: 24))
                        .foregroundColor(Color(UIColor.systemGray4))
                }
                Spacer()
                Text("记录心情")
                    .font(.headline)
                    .fontWeight(.semibold)
                Spacer()
                Button(action: saveMood) {
                    Text("完成")
                        .font(.headline)
                        .foregroundColor(.white)
                        .padding(.horizontal, 16)
                        .padding(.vertical, 6)
                        .background(Color(hex: "#8B5CF6"))
                        .cornerRadius(16)
                }
            }
            .padding()
            
            ScrollView {
                VStack(spacing: 24) {
                    Text("刚刚完成了「\(habit.name)」，现在感觉怎么样？")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                        .padding(.top, 8)
                    
                    // Moods Grid
                    HStack(spacing: 16) {
                        ForEach(moods, id: \.0) { mood in
                            VStack(spacing: 8) {
                                Text(mood.1)
                                    .font(.system(size: 40))
                                    .opacity(selectedMood == mood.0 ? 1.0 : 0.4)
                                    .scaleEffect(selectedMood == mood.0 ? 1.2 : 1.0)
                                    .animation(.spring(response: 0.3, dampingFraction: 0.6), value: selectedMood)
                                
                                Text(mood.2)
                                    .font(.caption)
                                    .foregroundColor(selectedMood == mood.0 ? .primary : .secondary)
                                    .fontWeight(selectedMood == mood.0 ? .semibold : .regular)
                            }
                            .frame(maxWidth: .infinity)
                            .onTapGesture {
                                selectedMood = mood.0
                            }
                        }
                    }
                    .padding(.horizontal)
                    
                    // Text Editor
                    VStack(alignment: .leading, spacing: 8) {
                        Text("碎碎念 (选填)").font(.subheadline).foregroundColor(.secondary)
                        
                        TextEditor(text: $thoughtsText)
                            .frame(height: 100)
                            .padding(8)
                            .background(Color(UIColor.systemGray6))
                            .cornerRadius(12)
                    }
                    .padding(.horizontal)
                    
                    // Image Picker
                    VStack(alignment: .leading, spacing: 8) {
                        Text("添加图片 (选填)").font(.subheadline).foregroundColor(.secondary)
                        
                        if let imageData = imageData, let uiImage = UIImage(data: imageData) {
                            ZStack(alignment: .topTrailing) {
                                Image(uiImage: uiImage)
                                    .resizable()
                                    .scaledToFill()
                                    .frame(height: 160)
                                    .frame(maxWidth: .infinity)
                                    .clipped()
                                    .cornerRadius(12)
                                
                                Button(action: {
                                    self.imageData = nil
                                    self.selectedItem = nil
                                }) {
                                    Image(systemName: "xmark.circle.fill")
                                        .font(.title2)
                                        .foregroundColor(.black.opacity(0.6))
                                        .background(Circle().fill(Color.white))
                                        .padding(8)
                                }
                            }
                        } else {
                            PhotosPicker(selection: $selectedItem, matching: .images, photoLibrary: .shared()) {
                                RoundedRectangle(cornerRadius: 12)
                                    .stroke(Color.gray.opacity(0.3), style: StrokeStyle(lineWidth: 1, dash: [5]))
                                    .frame(height: 100)
                                    .frame(maxWidth: .infinity)
                                    .overlay(
                                        VStack(spacing: 8) {
                                            Image(systemName: "camera.fill")
                                                .font(.title2)
                                                .foregroundColor(.gray)
                                            Text("点击上传")
                                                .font(.footnote)
                                                .foregroundColor(.gray)
                                        }
                                    )
                            }
                            .onChange(of: selectedItem) { _, newItem in
                                Task {
                                    if let data = try? await newItem?.loadTransferable(type: Data.self) {
                                        imageData = data
                                    }
                                }
                            }
                        }
                    }
                    .padding(.horizontal)
                    .padding(.bottom, 40)
                }
            }
        }
        .background(Color(UIColor.systemBackground))
    }
    
    private func saveMood() {
        let newMood = MoodRecord(type: selectedMood, text: thoughtsText)
        newMood.imageData = imageData
        newMood.habit = habit
        modelContext.insert(newMood)
        dismiss()
    }
}
