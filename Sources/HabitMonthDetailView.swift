import SwiftUI
import UIKit
import CoreData

struct HabitMonthRoute: Hashable {
    let habit: Habit
    let year: Int
    let month: Int
}

struct HabitMonthDetailView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.managedObjectContext) private var viewContext
    @EnvironmentObject private var appSettings: AppSettings
    @FetchRequest(sortDescriptors: []) private var checkins: FetchedResults<Checkin>
    @FetchRequest(sortDescriptors: []) private var moodRecords: FetchedResults<MoodRecord>
    
    @ObservedObject var habit: Habit
    @State private var selectedImageForFullscreen: IdentifiableImage? = nil
    @State var year: Int
    @State var month: Int
    
    @State private var currentMonthDate: Date
    private var calendar: Calendar { appSettings.customCalendar }
    private var monthYearString: String {
        let df = DateFormatter()
        if appSettings.resolvedLanguage == .chinese {
            df.locale = Locale(identifier: "zh_CN")
            df.dateFormat = appSettings.resolvedLanguage == .chinese ? "yyyy年M月" : "MMM yyyy"
        } else {
            df.locale = Locale(identifier: "en_US")
            df.dateFormat = "MMMM yyyy"
        }
        return df.string(from: currentMonthDate)
    }
    
    init(habit: Habit, year: Int, month: Int) {
        self.habit = habit
        self._selectedImageForFullscreen = State(initialValue: nil)
        self._year = State(initialValue: year)
        self._month = State(initialValue: month)
        var comp = DateComponents()
        comp.year = year
        comp.month = month
        comp.day = 1
        self._currentMonthDate = State(initialValue: Calendar.current.date(from: comp) ?? Date())
    }
    var body: some View {
        ScrollView(showsIndicators: false) {
            VStack(spacing: DS.spacingM) {
                
                // Month Selector
                HStack {
                    Button(action: { withAnimation { currentMonthDate = calendar.date(byAdding: .month, value: -1, to: currentMonthDate) ?? currentMonthDate } }) {
                        Image(systemName: "chevron.left")
                            .frame(width: 44, height: 44)
                            .background(DS.surface.opacity(0.8))
                            .background(.ultraThinMaterial)
                            .clipShape(Circle())
                            .foregroundColor(DS.onSurface)
                    }
                    
                    Spacer()
                    
                    HStack(spacing: 8) {
                        Image(systemName: "calendar")
                            .foregroundColor(DS.primary)
                        Text(monthYearString)
                            .font(.system(size: 16, weight: .bold))
                            .foregroundColor(DS.onSurface)
                    }
                    .padding(.horizontal, 20)
                    .padding(.vertical, 12)
                    .background(DS.surface.opacity(0.8))
                    .background(.ultraThinMaterial)
                    .clipShape(Capsule())
                    
                    Spacer()
                    
                    Button(action: { withAnimation { currentMonthDate = calendar.date(byAdding: .month, value: 1, to: currentMonthDate) ?? currentMonthDate } }) {
                        Image(systemName: "chevron.right")
                            .frame(width: 44, height: 44)
                            .background(DS.surface.opacity(0.8))
                            .background(.ultraThinMaterial)
                            .clipShape(Circle())
                            .foregroundColor(DS.onSurface)
                    }
                }
                .padding(.horizontal, 16)
                
                // Month Grid Card (Reused from StatisticsView)
                MonthGridCard(
                    habits: [habit],
                    checkins: checkins.filter { $0.habit?.id == habit.id },
                    appSettings: appSettings,
                    currentMonthDate: $currentMonthDate
                )
                
                // Stats Summary Card
                    let currentMonthCheckins = checkinsForCurrentMonth()
                    let completedDaysCount = Set(currentMonthCheckins.map { $0.dateString }).count
                    let totalAmount = currentMonthCheckins.reduce(0) { $0 + $1.amount }
                    let allCheckinDays = Set(checkins.filter { $0.habit?.id == habit.id }.map { $0.dateString }).count
                    
                    HStack(spacing: 14) {
                        // Days card
                        VStack(spacing: 4) {
                            Text("\(completedDaysCount)")
                                .font(.system(size: 24, weight: .bold))
                                .foregroundColor(DS.onSurface)
                                .lineLimit(1)
                                .minimumScaleFactor(0.5)
                            Text("Check-in Days".tr(appSettings.resolvedLanguage))
                                .font(.system(size: 13, weight: .medium))
                                .foregroundColor(DS.onSurfaceVariant)
                                .lineLimit(1)
                                .minimumScaleFactor(0.8)
                        }
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 16)
                        .background(DS.surface)
                        .clipShape(RoundedRectangle(cornerRadius: 20, style: .continuous))
                        .overlay(RoundedRectangle(cornerRadius: 20, style: .continuous).stroke(DS.outlineVariant, lineWidth: 1))
                        .shadow(color: Color.black.opacity(0.04), radius: 10, x: 0, y: 4)
                        
                        if habit.goalType == "amount" {
                            VStack(spacing: 4) {
                                Text("\(String(format: "%.1f", totalAmount).replacingOccurrences(of: ".0", with: ""))")
                                    .font(.system(size: 24, weight: .bold))
                                    .foregroundColor(DS.onSurface)
                                    .lineLimit(1)
                                    .minimumScaleFactor(0.5)
                                Text("Check-in Amount".tr(appSettings.resolvedLanguage))
                                    .font(.system(size: 13, weight: .medium))
                                    .foregroundColor(DS.onSurfaceVariant)
                                    .lineLimit(1)
                                    .minimumScaleFactor(0.8)
                            }
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 16)
                            .background(DS.surface)
                            .clipShape(RoundedRectangle(cornerRadius: 20, style: .continuous))
                            .overlay(RoundedRectangle(cornerRadius: 20, style: .continuous).stroke(DS.outlineVariant, lineWidth: 1))
                            .shadow(color: Color.black.opacity(0.04), radius: 10, x: 0, y: 4)
                        }
                    }
                    .padding(.horizontal, 16)
                    
                    // Timeline Records
                    VStack(alignment: .leading, spacing: 10) {
                        HStack {
                            Image(systemName: "clock.arrow.circlepath")
                                .foregroundColor(Color(hex: habit.color))
                            Text("Check-in Records".tr(appSettings.resolvedLanguage))
                                .font(.system(size: 18, weight: .bold))
                                .foregroundColor(DS.onSurface)
                            Spacer()
                        }
                        
                        if currentMonthCheckins.isEmpty {
                            Text("No check-in records".tr(appSettings.resolvedLanguage))
                                .font(.system(size: 14))
                                .foregroundColor(DS.onSurfaceVariant)
                                .padding(.vertical, 10)
                        } else {
                            // Sort descending
                            let sortedCheckins = currentMonthCheckins.sorted(by: { $0.timestamp > $1.timestamp })
                            
                            VStack(alignment: .leading, spacing: 0) {
                                ForEach(Array(sortedCheckins.enumerated()), id: \.element.id) { index, checkin in
                                    timelineItem(checkin: checkin, isLast: index == sortedCheckins.count - 1)
                                }
                            }
                        }
                    }
                    .padding(20)
                    .background(DS.surface)
                    .clipShape(RoundedRectangle(cornerRadius: 24, style: .continuous))
                    .overlay(RoundedRectangle(cornerRadius: 24, style: .continuous).stroke(DS.outlineVariant, lineWidth: 1))
                    .shadow(color: Color.black.opacity(0.04), radius: 12, x: 0, y: 6)
                    .padding(.horizontal, 16)
                    Spacer().frame(height: 40)
                }
                .padding(.top, 16)
            }
        .background(AmbientBackground())
        .navigationTitle(habit.name)
        .navigationBarTitleDisplayMode(.inline)
        .toolbarBackground(.visible, for: .navigationBar)
        .toolbar(.hidden, for: .tabBar)
        .onChange(of: currentMonthDate) { newValue in
            year = calendar.component(.year, from: newValue)
            month = calendar.component(.month, from: newValue)
        }
        .fullScreenCover(item: $selectedImageForFullscreen) { identImg in
            FullscreenImageView(image: identImg.image) {
                selectedImageForFullscreen = nil
            }
            .environmentObject(appSettings)
        }
    }
    
    private func checkinsForCurrentMonth() -> [Checkin] {
        let prefix = String(format: "%04d-%02d-", year, month)
        return checkins.filter { $0.habit?.id == habit.id && $0.dateString.hasPrefix(prefix) }
    }
    
    private func getMoodForDate(_ dateStr: String) -> MoodRecord? {
        // Find a mood record for this habit on this date
        return moodRecords.first { $0.habit?.id == habit.id && formattedDateString($0.timestamp) == dateStr }
    }
    
    private func formattedDateString(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        return formatter.string(from: date)
    }
    
    private func statItem(value: String, label: String) -> some View {
        VStack(spacing: 4) {
            Text(value)
                .font(.system(size: 20, weight: .bold))
                .foregroundColor(DS.onSurface)
            Text(label)
                .font(.system(size: 12))
                .foregroundColor(DS.onSurfaceVariant)
        }
    }
    
    private func emoji(for type: String) -> String {
        switch type {
        case "excited": return "🤩"
        case "happy": return "😊"
        case "normal": return "😐"
        case "down": return "😔"
        case "angry": return "😡"
        default: return "✨"
        }
    }
    
    @ViewBuilder
    private func timelineItem(checkin: Checkin, isLast: Bool) -> some View {
        HStack(alignment: .top, spacing: 0) {
            // Timeline Node
            ZStack(alignment: .top) {
                if !isLast {
                    Rectangle()
                        .fill(DS.primary.opacity(0.2))
                        .frame(width: 2)
                        .padding(.top, 24)
                }
                
                Circle()
                    .fill(DS.primary.opacity(0.15))
                    .frame(width: 12, height: 12)
                    .overlay(Circle().stroke(DS.primary, lineWidth: 2))
                    .padding(.top, 4)
            }
            .frame(width: 32)
            
            // Content Card
            VStack(alignment: .leading, spacing: 12) {
                // Header (Date and Time)
                HStack(alignment: .center) {
                    Text(formattedDisplayDate(checkin.timestamp))
                        .font(.system(size: 15, weight: .semibold))
                        .foregroundColor(DS.onSurface)
                    
                    Spacer()
                    
                    if habit.goalType == "amount" && checkin.amount > 0 {
                        Text("+\(String(format: "%.1f", checkin.amount).replacingOccurrences(of: ".0", with: "")) \(habit.amountUnit.tr(appSettings.resolvedLanguage))")
                            .font(.system(size: 13, weight: .bold))
                            .foregroundColor(DS.primary)
                            .padding(.horizontal, 8)
                            .padding(.vertical, 4)
                            .background(DS.primary.opacity(0.1))
                            .clipShape(Capsule())
                    } else {
                        Image(systemName: "checkmark.circle.fill")
                            .foregroundColor(DS.primary)
                            .font(.system(size: 16))
                    }
                }
                
                // Mood Log (if exists)
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
                                selectedImageForFullscreen = IdentifiableImage(image: uiImage)
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
                }
            }
            .padding(16)
            .background(DS.surface)
            .clipShape(RoundedRectangle(cornerRadius: 16))
            .shadow(color: Color.black.opacity(0.02), radius: 6, x: 0, y: 2)
            .padding(.bottom, isLast ? 0 : 16)
            .padding(.leading, 8)
        }
    }
    
    private func formattedDisplayDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        if appSettings.resolvedLanguage == .chinese {
            formatter.locale = Locale(identifier: "zh_CN")
            formatter.dateFormat = "MM月dd日 HH:mm"
        } else {
            formatter.locale = Locale(identifier: "en_US")
            formatter.dateFormat = "MMM dd, HH:mm"
        }
        return formatter.string(from: date)
    }
}

struct IdentifiableImage: Identifiable {
    let id = UUID()
    let image: UIImage
}

struct FullscreenImageView: View {
    let image: UIImage
    let onDismiss: () -> Void
    @EnvironmentObject private var appSettings: AppSettings
    @State private var showingSaveAlert = false
    @State private var scale: CGFloat = 1.0
    @State private var lastScale: CGFloat = 1.0

    var body: some View {
        ZStack {
            Color.black.ignoresSafeArea()
            
            Image(uiImage: image)
                .resizable()
                .scaledToFit()
                .scaleEffect(scale)
                .gesture(
                    MagnificationGesture()
                        .onChanged { val in
                            scale = lastScale * val
                        }
                        .onEnded { val in
                            lastScale = scale
                        }
                )
                .onTapGesture(count: 2) {
                    withAnimation {
                        scale = scale > 1 ? 1.0 : 2.0
                        lastScale = scale
                    }
                }
            
            VStack {
                HStack {
                    Button(action: onDismiss) {
                        Image(systemName: "xmark")
                            .font(.system(size: 20, weight: .bold))
                            .foregroundColor(.white)
                            .padding(16)
                            .background(Color.black.opacity(0.5))
                            .clipShape(Circle())
                    }
                    Spacer()
                    Button(action: {
                        UIImageWriteToSavedPhotosAlbum(image, nil, nil, nil)
                        showingSaveAlert = true
                    }) {
                        Image(systemName: "square.and.arrow.down")
                            .font(.system(size: 20, weight: .bold))
                            .foregroundColor(.white)
                            .padding(16)
                            .background(Color.black.opacity(0.5))
                            .clipShape(Circle())
                    }
                }
                .padding()
                Spacer()
            }
        }
        .alert("Saved to Album".tr(appSettings.resolvedLanguage), isPresented: $showingSaveAlert) {
            Button("OK".tr(appSettings.resolvedLanguage), role: .cancel) { }
        }
    }
}
