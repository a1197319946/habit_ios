import SwiftUI
import SwiftData
import PhotosUI

struct ProfileView: View {
    @AppStorage("userNickname") private var nickname: String = ""
    @AppStorage("userAvatarData") private var avatarData: Data?
    
    @State private var showEditSheet = false
    @State private var tempNickname: String = ""
    @State private var tempSelectedItem: PhotosPickerItem?
    @State private var tempAvatarData: Data?
    @State private var showAboutAlert = false
    
    var body: some View {
        NavigationView {
            ZStack {
                Color(hex: "#F5F5F7").edgesIgnoringSafeArea(.all)
                
                ScrollView {
                    VStack(spacing: 24) {
                        // User Header Glass Panel
                        HStack(spacing: 16) {
                            ZStack {
                                if let avatarData = avatarData, let uiImage = UIImage(data: avatarData) {
                                    Image(uiImage: uiImage)
                                        .resizable()
                                        .scaledToFill()
                                        .frame(width: 64, height: 64)
                                        .clipShape(Circle())
                                } else {
                                    ZStack {
                                        Circle()
                                            .fill(Color(hex: "#8B5CF6").opacity(0.1))
                                            .frame(width: 64, height: 64)
                                        Image(systemName: "person.fill")
                                            .font(.system(size: 32))
                                            .foregroundColor(Color(hex: "#8B5CF6"))
                                    }
                                }
                            }
                            
                            VStack(alignment: .leading, spacing: 4) {
                                Text(nickname.isEmpty ? "神秘打卡人" : nickname)
                                    .font(.system(size: 20, weight: .bold))
                                    .foregroundColor(.primary)
                                Text("坚持打卡，遇见更好的自己")
                                    .font(.system(size: 13))
                                    .foregroundColor(.secondary)
                            }
                            Spacer()
                            Image(systemName: "chevron.right")
                                .foregroundColor(.gray)
                                .font(.system(size: 14, weight: .bold))
                        }
                        .padding(24)
                        .background(Color.white.opacity(0.8))
                        .cornerRadius(16)
                        .shadow(color: Color.black.opacity(0.05), radius: 10, y: 5)
                        .padding(.horizontal)
                        .onTapGesture {
                            tempNickname = nickname
                            tempAvatarData = avatarData
                            showEditSheet = true
                        }
                        
                        // Function List
                        VStack(spacing: 0) {
                            ProfileListItem(icon: "square.and.pencil", color: "#8B5CF6", text: "心情记录") {
                                // Handled by NavigationLink overlay later, but keeping structure
                            }
                            .overlay(NavigationLink(destination: MoodListView()) { EmptyView() }.opacity(0))
                            
                            Divider().padding(.leading, 56)
                            
                            ProfileListItem(icon: "paperplane.fill", color: "#8B5CF6", text: "分享好友") {
                                shareApp()
                            }
                            
                            Divider().padding(.leading, 56)
                            
                            ProfileListItem(icon: "message.fill", color: "#8B5CF6", text: "建议与反馈") {
                                // Stub
                            }
                            
                            Divider().padding(.leading, 56)
                            
                            ProfileListItem(icon: "info.circle.fill", color: "#8B5CF6", text: "关于小程序") {
                                showAboutAlert = true
                            }
                            
                            Divider().padding(.leading, 56)
                            
                            ProfileListItem(icon: "person.2.fill", color: "#8B5CF6", text: "合作联系") {
                                // Stub
                            }
                        }
                        .background(Color.white.opacity(0.8))
                        .cornerRadius(16)
                        .shadow(color: Color.black.opacity(0.05), radius: 10, y: 5)
                        .padding(.horizontal)
                    }
                    .padding(.top, 24)
                }
            }
            .navigationTitle("我的")
            .navigationBarHidden(true)
            .sheet(isPresented: $showEditSheet) {
                // Profile Edit Popup BottomSheet
                VStack(spacing: 24) {
                    HStack {
                        VStack(alignment: .leading) {
                            Text("完善个人资料").font(.system(size: 18, weight: .bold))
                            Text("让大家认识你").font(.system(size: 12)).foregroundColor(.secondary)
                        }
                        Spacer()
                        Button(action: { showEditSheet = false }) {
                            Image(systemName: "xmark")
                                .foregroundColor(Color(hex: "#9CA3AF"))
                                .font(.system(size: 20))
                        }
                    }
                    .padding(.top, 24)
                    .padding(.horizontal, 20)
                    
                    PhotosPicker(selection: $tempSelectedItem, matching: .images, photoLibrary: .shared()) {
                        ZStack {
                            if let data = tempAvatarData, let uiImage = UIImage(data: data) {
                                Image(uiImage: uiImage)
                                    .resizable()
                                    .scaledToFill()
                                    .frame(width: 80, height: 80)
                                    .clipShape(Circle())
                                    .overlay(Circle().stroke(Color.white, lineWidth: 2))
                            } else {
                                ZStack {
                                    Circle()
                                        .fill(Color(UIColor.systemGray6))
                                        .frame(width: 80, height: 80)
                                        .overlay(Circle().stroke(Color.white, lineWidth: 2))
                                    Image(systemName: "person.fill")
                                        .font(.system(size: 40))
                                        .foregroundColor(Color(UIColor.systemGray3))
                                }
                            }
                            
                            Circle()
                                .fill(Color(hex: "#8B5CF6"))
                                .frame(width: 24, height: 24)
                                .overlay(Circle().stroke(Color.white, lineWidth: 2))
                                .overlay(
                                    Image(systemName: "camera.fill")
                                        .font(.system(size: 10))
                                        .foregroundColor(.white)
                                )
                                .offset(x: 28, y: 28)
                        }
                        .shadow(color: Color.black.opacity(0.05), radius: 6, y: 4)
                    }
                    .onChange(of: tempSelectedItem) { _, newItem in
                        Task {
                            if let data = try? await newItem?.loadTransferable(type: Data.self) {
                                tempAvatarData = data
                            }
                        }
                    }
                    
                    Text("点击更换头像")
                        .font(.system(size: 12))
                        .foregroundColor(Color(hex: "#9CA3AF"))
                        .padding(.top, -16)
                    
                    TextField("请输入昵称", text: $tempNickname)
                        .font(.system(size: 16))
                        .multilineTextAlignment(.center)
                        .padding(.vertical, 12)
                        .padding(.horizontal, 20)
                        .background(Color(UIColor.systemGray6))
                        .cornerRadius(100)
                        .padding(.horizontal, 40)
                    
                    Spacer()
                    
                    Button(action: saveProfile) {
                        Text("保 存")
                            .font(.system(size: 16, weight: .bold))
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .frame(height: 48)
                            .background(Color(hex: "#8B5CF6"))
                            .cornerRadius(24)
                    }
                    .padding(.horizontal, 20)
                    .padding(.bottom, 30)
                }
                .presentationDetents([.height(400)])
                .presentationDragIndicator(.visible)
            }
            .alert(isPresented: $showAboutAlert) {
                Alert(
                    title: Text("关于小习惯打卡"),
                    message: Text("版本：v1.0.0\n愿你在坚持中遇见更好的自己！\n\n小程序还在打磨优化，将永久免费开放使用，欢迎深度体验！后续将继续推出 ios 版本！"),
                    dismissButton: .default(Text("我知道了"))
                )
            }
        }
    }
    
    private func saveProfile() {
        nickname = tempNickname
        if let data = tempAvatarData {
            avatarData = data
        }
        showEditSheet = false
    }
    
    private func shareApp() {
        let text = "小习惯 - 坚持每天微小的改变"
        let activityVC = UIActivityViewController(activityItems: [text], applicationActivities: nil)
        if let scene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
           let window = scene.windows.first,
           let rootVC = window.rootViewController {
            activityVC.popoverPresentationController?.sourceView = window
            rootVC.present(activityVC, animated: true, completion: nil)
        }
    }
}

struct ProfileListItem: View {
    let icon: String
    let color: String
    let text: String
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: 12) {
                Image(systemName: icon)
                    .font(.system(size: 24))
                    .foregroundColor(Color(hex: color))
                    .frame(width: 24)
                
                Text(text)
                    .font(.system(size: 15, weight: .medium))
                    .foregroundColor(.primary)
                
                Spacer()
                
                Image(systemName: "chevron.right")
                    .foregroundColor(Color(hex: "#9CA3AF"))
                    .font(.system(size: 14, weight: .bold))
            }
            .padding(.vertical, 16)
            .padding(.horizontal, 24)
            .contentShape(Rectangle())
        }
        .buttonStyle(PlainButtonStyle())
    }
}

// Keep MoodListView simple for now
struct MoodListView: View {
    @Query(sort: \MoodRecord.timestamp, order: .reverse) private var moodRecords: [MoodRecord]
    
    var body: some View {
        ZStack {
            Color(hex: "#F5F5F7").edgesIgnoringSafeArea(.all)
            
            if moodRecords.isEmpty {
                VStack {
                    Image(systemName: "doc.text.image")
                        .font(.system(size: 50))
                        .foregroundColor(.gray.opacity(0.5))
                        .padding()
                    Text("还没有记录过心情哦")
                        .foregroundColor(.secondary)
                }
            } else {
                ScrollView {
                    VStack(spacing: 16) {
                        ForEach(moodRecords) { record in
                            VStack(alignment: .leading, spacing: 12) {
                                HStack {
                                    Text(moodEmoji(for: record.type))
                                        .font(.title2)
                                    
                                    Text(record.habit?.name ?? "未知习惯")
                                        .font(.headline)
                                        .foregroundColor(.primary)
                                    
                                    Spacer()
                                    
                                    Text(formatDate(record.timestamp))
                                        .font(.caption)
                                        .foregroundColor(.secondary)
                                }
                                
                                if !record.text.isEmpty {
                                    Text(record.text)
                                        .font(.body)
                                        .foregroundColor(Color(UIColor.darkGray))
                                }
                                
                                if let data = record.imageData, let uiImage = UIImage(data: data) {
                                    Image(uiImage: uiImage)
                                        .resizable()
                                        .scaledToFill()
                                        .frame(maxHeight: 180)
                                        .clipped()
                                        .cornerRadius(8)
                                }
                            }
                            .padding()
                            .background(Color(UIColor.systemBackground))
                            .cornerRadius(16)
                        }
                    }
                    .padding()
                }
            }
        }
        .navigationTitle("心情日记")
    }
    
    private func moodEmoji(for type: String) -> String {
        switch type {
        case "excited": return "🤩"
        case "happy": return "😊"
        case "normal": return "😐"
        case "down": return "😔"
        case "angry": return "😡"
        default: return "😐"
        }
    }
    
    private func formatDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "MM-dd HH:mm"
        return formatter.string(from: date)
    }
}
