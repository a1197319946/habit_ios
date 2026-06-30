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
                DS.bgPrimary.edgesIgnoringSafeArea(.all)
                
                ScrollView {
                    VStack(spacing: DS.spacingL) {
                        
                        // ── Avatar & Name ──
                        VStack(spacing: DS.spacingM) {
                            Button(action: {
                                tempNickname = nickname
                                tempAvatarData = avatarData
                                showEditSheet = true
                            }) {
                                ZStack(alignment: .bottomTrailing) {
                                    if let avatarData = avatarData, let uiImage = UIImage(data: avatarData) {
                                        Image(uiImage: uiImage)
                                            .resizable()
                                            .scaledToFill()
                                            .frame(width: 88, height: 88)
                                            .clipShape(Circle())
                                    } else {
                                        Circle()
                                            .fill(DS.accentMuted)
                                            .frame(width: 88, height: 88)
                                            .overlay(
                                                Text(nickname.isEmpty ? "?" : String(nickname.prefix(1)))
                                                    .font(.system(size: 36, weight: .bold, design: .rounded))
                                                    .foregroundColor(DS.accent)
                                            )
                                    }
                                    
                                    Circle()
                                        .fill(DS.accent)
                                        .frame(width: 26, height: 26)
                                        .overlay(
                                            Image(systemName: "pencil")
                                                .font(.system(size: 12, weight: .bold))
                                                .foregroundColor(.white)
                                        )
                                }
                            }
                            
                            VStack(spacing: 4) {
                                Text(nickname.isEmpty ? "点击设置昵称" : nickname)
                                    .font(.system(size: 20, weight: .bold, design: .rounded))
                                    .foregroundColor(DS.textPrimary)
                                
                                Text("坚持打卡，遇见更好的自己")
                                    .font(.system(size: 14))
                                    .foregroundColor(DS.textSecondary)
                            }
                        }
                        .padding(.top, DS.spacingXL)
                        .padding(.bottom, DS.spacingM)
                        
                        // ── Menu List ──
                        VStack(spacing: 0) {
                            ProfileMenuRow(icon: "square.and.pencil", iconColor: DS.accent, label: "心情记录") {
                            }
                            .overlay(NavigationLink(destination: MoodListView()) { EmptyView() }.opacity(0))
                            
                            JDivider().padding(.leading, 56)
                            
                            ProfileMenuRow(icon: "paperplane", iconColor: DS.success, label: "分享好友") {
                                shareApp()
                            }
                            
                            JDivider().padding(.leading, 56)
                            
                            ProfileMenuRow(icon: "bubble.left", iconColor: Color(hex: "#F59E0B"), label: "建议与反馈") {}
                            
                            JDivider().padding(.leading, 56)
                            
                            ProfileMenuRow(icon: "info.circle", iconColor: Color(hex: "#3B82F6"), label: "关于小习惯") {
                                showAboutAlert = true
                            }
                            
                            JDivider().padding(.leading, 56)
                            
                            ProfileMenuRow(icon: "person.2", iconColor: Color(hex: "#8B5CF6"), label: "合作联系") {}
                        }
                        .card()
                        .padding(.horizontal, DS.spacingL)
                        
                        // App version
                        Text("小习惯 v1.0")
                            .font(.system(size: 12))
                            .foregroundColor(DS.textTertiary)
                            .padding(.top, DS.spacingS)
                    }
                }
            }
            .navigationTitle("我的")
            .navigationBarHidden(true)
            .sheet(isPresented: $showEditSheet) {
                EditProfileSheet(
                    nickname: $tempNickname,
                    avatarData: $tempAvatarData,
                    selectedItem: $tempSelectedItem,
                    onSave: {
                        nickname = tempNickname
                        avatarData = tempAvatarData
                        showEditSheet = false
                    },
                    onDismiss: { showEditSheet = false }
                )
            }
            .alert("关于小习惯", isPresented: $showAboutAlert) {
                Button("好的") {}
            } message: {
                Text("小习惯帮助你建立并坚持好习惯。\n版本 1.0.0")
            }
        }
    }
    
    private func shareApp() {
        let text = "我在用「小习惯」记录我的每日习惯打卡，你也来试试吧！"
        let activityVC = UIActivityViewController(activityItems: [text], applicationActivities: nil)
        if let scene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
           let window = scene.windows.first,
           let rootVC = window.rootViewController {
            activityVC.popoverPresentationController?.sourceView = window
            rootVC.present(activityVC, animated: true)
        }
    }
}

// MARK: - Profile Menu Row

struct ProfileMenuRow: View {
    let icon: String
    let iconColor: Color
    let label: String
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: DS.spacingM) {
                ZStack {
                    RoundedRectangle(cornerRadius: 8)
                        .fill(iconColor.opacity(0.12))
                        .frame(width: 36, height: 36)
                    Image(systemName: icon)
                        .font(.system(size: 16, weight: .medium))
                        .foregroundColor(iconColor)
                }
                
                Text(label)
                    .font(.system(size: 16, weight: .medium))
                    .foregroundColor(DS.textPrimary)
                
                Spacer()
                
                Image(systemName: "chevron.right")
                    .font(.system(size: 12, weight: .semibold))
                    .foregroundColor(DS.textTertiary)
            }
            .padding(.horizontal, DS.spacingL)
            .padding(.vertical, DS.spacingM)
        }
        .buttonStyle(PlainButtonStyle())
    }
}

// MARK: - Edit Profile Sheet

struct EditProfileSheet: View {
    @Binding var nickname: String
    @Binding var avatarData: Data?
    @Binding var selectedItem: PhotosPickerItem?
    let onSave: () -> Void
    let onDismiss: () -> Void
    
    var body: some View {
        NavigationView {
            ZStack {
                DS.bgPrimary.edgesIgnoringSafeArea(.all)
                
                VStack(spacing: DS.spacingXL) {
                    // Avatar
                    PhotosPicker(selection: $selectedItem, matching: .images, photoLibrary: .shared()) {
                        ZStack(alignment: .bottomTrailing) {
                            if let data = avatarData, let uiImage = UIImage(data: data) {
                                Image(uiImage: uiImage)
                                    .resizable()
                                    .scaledToFill()
                                    .frame(width: 96, height: 96)
                                    .clipShape(Circle())
                            } else {
                                Circle()
                                    .fill(DS.accentMuted)
                                    .frame(width: 96, height: 96)
                                    .overlay(
                                        Image(systemName: "person")
                                            .font(.system(size: 40))
                                            .foregroundColor(DS.accent)
                                    )
                            }
                            
                            Circle()
                                .fill(DS.accent)
                                .frame(width: 30, height: 30)
                                .overlay(
                                    Image(systemName: "camera")
                                        .font(.system(size: 14, weight: .medium))
                                        .foregroundColor(.white)
                                )
                        }
                    }
                    .onChange(of: selectedItem) { _, newItem in
                        Task {
                            if let data = try? await newItem?.loadTransferable(type: Data.self) {
                                avatarData = data
                            }
                        }
                    }
                    
                    // Nickname Field
                    VStack(alignment: .leading, spacing: DS.spacingS) {
                        Text("昵称")
                            .font(.system(size: 13, weight: .semibold))
                            .foregroundColor(DS.textSecondary)
                        
                        TextField("输入你的昵称", text: $nickname)
                            .font(.system(size: 18, weight: .medium))
                            .foregroundColor(DS.textPrimary)
                            .padding(DS.spacingM)
                            .background(DS.bgSubtle)
                            .cornerRadius(DS.cornerSmall)
                    }
                    .padding(.horizontal, DS.spacingL)
                    
                    Spacer()
                }
                .padding(.top, DS.spacingXL)
            }
            .navigationTitle("编辑资料")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("取消") { onDismiss() }
                        .foregroundColor(DS.textSecondary)
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("保存") { onSave() }
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundColor(DS.accent)
                }
            }
        }
    }
}
// MARK: - Mood List View

struct MoodListView: View {
    @Query(sort: \MoodRecord.timestamp, order: .reverse) private var moodRecords: [MoodRecord]
    
    var body: some View {
        ZStack {
            DS.bgPrimary.edgesIgnoringSafeArea(.all)
            
            if moodRecords.isEmpty {
                VStack(spacing: DS.spacingL) {
                    Image(systemName: "face.smiling")
                        .font(.system(size: 52))
                        .foregroundColor(DS.textTertiary)
                    Text("还没有记录过心情")
                        .font(.system(size: 18, weight: .semibold, design: .rounded))
                        .foregroundColor(DS.textSecondary)
                }
            } else {
                ScrollView {
                    VStack(spacing: DS.spacingM) {
                        ForEach(moodRecords) { record in
                            VStack(alignment: .leading, spacing: DS.spacingM) {
                                HStack {
                                    Text(moodEmoji(for: record.type))
                                        .font(.title2)
                                    
                                    Text(record.habit?.name ?? "未知习惯")
                                        .font(.system(size: 16, weight: .semibold))
                                        .foregroundColor(DS.textPrimary)
                                    
                                    Spacer()
                                    
                                    Text(formatDate(record.timestamp))
                                        .font(.system(size: 12))
                                        .foregroundColor(DS.textSecondary)
                                }
                                
                                if !record.text.isEmpty {
                                    Text(record.text)
                                        .font(.system(size: 15))
                                        .foregroundColor(DS.textSecondary)
                                }
                                
                                if let data = record.imageData, let uiImage = UIImage(data: data) {
                                    Image(uiImage: uiImage)
                                        .resizable()
                                        .scaledToFill()
                                        .frame(maxHeight: 180)
                                        .clipped()
                                        .cornerRadius(DS.cornerSmall)
                                }
                            }
                            .padding(DS.spacingL)
                            .card()
                        }
                    }
                    .padding(.horizontal, DS.spacingL)
                    .padding(.vertical, DS.spacingM)
                }
            }
        }
        .navigationTitle("心情日记")
        .navigationBarTitleDisplayMode(.large)
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
