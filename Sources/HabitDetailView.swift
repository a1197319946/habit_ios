import SwiftUI
import WidgetKit
import CoreData
import NotificationCenter

extension Array {
    func chunked(into size: Int) -> [[Element]] {
        return stride(from: 0, to: count, by: size).map {
            Array(self[$0 ..< Swift.min($0 + size, count)])
        }
    }
}

struct HabitDetailView: View {
    @Environment(\.managedObjectContext) private var viewContext
    @Environment(\.dismiss) private var dismiss
    @Environment(\.colorScheme) private var colorScheme
    @EnvironmentObject private var appSettings: AppSettings
    
    var habit: Habit?
    
    @State private var name: String = ""
    @State private var colorHex: String = Constants.allColors[0]
    @State private var icon: String = Constants.allIcons[0]
    
    @State private var goalType: String = "frequency" // "frequency" or "amount"
    @State private var frequencyType: String = "weekly"
    @State private var weeklyTarget: Int = 3
    @State private var monthlyTarget: Int = 10
    @State private var amountValue: Double = 0
    @State private var amountUnit: String = "次"
    @State private var isReminderEnabled: Bool = false
    @State private var reminderTime: Date = Calendar.current.date(from: DateComponents(hour: 20, minute: 0)) ?? Date()
    @State private var reminderText: String = ""
    @State private var isSubmitting = false
    @State private var showingDeleteAlert = false
    
    let unitOptions = ["公里", "米", "分钟", "小时", "次", "页"]
    
    var body: some View {
        NavigationView {
            ZStack(alignment: .bottom) {
                ScrollView(showsIndicators: false) {
                VStack(spacing: DS.spacingS) {
                    
                    // Card 1: Name
                    glassCard {
                        VStack(alignment: .leading, spacing: DS.spacingS) {
                            Text("习惯名称".tr(appSettings.resolvedLanguage))
                                .font(.system(size: 16, weight: .bold))
                                .foregroundColor(DS.onSurface)
                            
                            HStack {
                                Image(systemName: "pencil")
                                    .foregroundColor(DS.outline)
                                    .padding(.leading, DS.spacingS)
                                
                                TextField("e.g. Read 10 pages, Drink water...".tr(appSettings.resolvedLanguage), text: $name)
                                    .font(.system(size: 16, weight: .regular))
                                    .foregroundColor(DS.onSurface)
                                    .padding(.vertical, 14)
                            }
                            .background(DS.surface.opacity(0.9))
                            .cornerRadius(8)
                            .overlay(RoundedRectangle(cornerRadius: 8).stroke(DS.outlineVariant, lineWidth: 1))
                        }
                    }
                    
                    // Card 2: Color and Icon
                    glassCard {
                        VStack(alignment: .leading, spacing: DS.spacingL) {
                            
                            // Color Picker
                            VStack(alignment: .leading, spacing: DS.spacingS) {
                                Text("Pick a Theme Color".tr(appSettings.resolvedLanguage))
                                    .font(.system(size: 16, weight: .bold))
                                    .foregroundColor(DS.onSurface)
                                
                                let colorPages = Constants.allColors.chunked(into: 18)
                                TabView {
                                    ForEach(0..<colorPages.count, id: \.self) { pageIndex in
                                        LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 6), spacing: 8) {
                                            ForEach(colorPages[pageIndex], id: \.self) { hex in
                                                Button(action: {
                                                    withAnimation { colorHex = hex }
                                                    UIImpactFeedbackGenerator(style: .light).impactOccurred()
                                                }) {
                                                    ZStack {
                                                        Circle()
                                                            .fill(Color(hex: hex))
                                                            .frame(width: 32, height: 32)
                                                        
                                                        if colorHex == hex {
                                                            Circle()
                                                                .stroke(DS.primary, lineWidth: 2)
                                                                .frame(width: 38, height: 38)
                                                            Image(systemName: "checkmark")
                                                                .foregroundColor(.white)
                                                                .font(.system(size: 14, weight: .bold))
                                                        }
                                                    }
                                                }
                                                .padding(2)
                                            }
                                        }
                                        .padding(.horizontal, 4)
                                        .padding(.bottom, 36)
                                    }
                                }
                                .tabViewStyle(.page(indexDisplayMode: .always))
                                .frame(height: 170)
                            }
                            
                            // Icon Picker
                            VStack(alignment: .leading, spacing: DS.spacingS) {
                                Text("选择图标".tr(appSettings.resolvedLanguage))
                                    .font(.system(size: 16, weight: .bold))
                                    .foregroundColor(DS.onSurface)
                                
                                let iconPages = Constants.allIcons.chunked(into: 18)
                                TabView {
                                    ForEach(0..<iconPages.count, id: \.self) { pageIndex in
                                        LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 6), spacing: 8) {
                                            ForEach(iconPages[pageIndex], id: \.self) { iconName in
                                                Button(action: {
                                                    withAnimation { icon = iconName }
                                                    UIImpactFeedbackGenerator(style: .light).impactOccurred()
                                                }) {
                                                    ZStack {
                                                        Circle()
                                                            .fill(icon == iconName ? Color(hex: colorHex).opacity(0.15) : DS.surfaceContainerLow)
                                                            .frame(width: 36, height: 36)
                                                            .overlay(
                                                                Circle()
                                                                    .stroke(icon == iconName ? Color.clear : DS.outlineVariant, lineWidth: 1)
                                                            )
                                                        
                                                        Image(systemName: iconName)
                                                            .font(.system(size: 16))
                                                            .foregroundColor(icon == iconName ? Color(hex: colorHex) : DS.onSurfaceVariant)
                                                    }
                                                }
                                            }
                                        }
                                        .padding(.horizontal, 4)
                                        .padding(.bottom, 36)
                                    }
                                }
                                .tabViewStyle(.page(indexDisplayMode: .always))
                                .frame(height: 170)
                            }
                        }
                    }
                    
                    // Card 3: Target/Goal
                    glassCard {
                        VStack(alignment: .leading, spacing: DS.spacingL) {
                            
                            VStack(alignment: .leading, spacing: DS.spacingS) {
                                Text("Goal Type".tr(appSettings.resolvedLanguage))
                                    .font(.system(size: 16, weight: .bold))
                                    .foregroundColor(DS.onSurface)
                                
                                HStack(spacing: 0) {
                                    Button(action: { withAnimation { goalType = "frequency" } }) {
                                        Text("次数目标".tr(appSettings.resolvedLanguage))
                                            .font(.system(size: 13, weight: .medium))
                                            .frame(maxWidth: .infinity)
                                            .padding(.vertical, 10)
                                            .background(goalType == "frequency" ? (colorScheme == .dark ? Color(hex: "#3A3A3C") : DS.surface) : Color.clear)
                                            .foregroundColor(goalType == "frequency" ? DS.onSurface : DS.onSurfaceVariant)
                                            .cornerRadius(8)
                                            .overlay(RoundedRectangle(cornerRadius: 8).stroke(goalType == "frequency" ? (colorScheme == .dark ? Color(hex: "#636366") : Color.clear) : Color.clear, lineWidth: 1))
                                            .shadow(color: goalType == "frequency" ? .black.opacity(0.05) : .clear, radius: 2, x: 0, y: 1)
                                    }
                                    
                                    Button(action: { withAnimation { goalType = "amount" } }) {
                                        Text("总量目标".tr(appSettings.resolvedLanguage))
                                            .font(.system(size: 13, weight: .medium))
                                            .frame(maxWidth: .infinity)
                                            .padding(.vertical, 10)
                                            .background(goalType == "amount" ? (colorScheme == .dark ? Color(hex: "#3A3A3C") : DS.surface) : Color.clear)
                                            .foregroundColor(goalType == "amount" ? DS.onSurface : DS.onSurfaceVariant)
                                            .cornerRadius(8)
                                            .overlay(RoundedRectangle(cornerRadius: 8).stroke(goalType == "amount" ? (colorScheme == .dark ? Color(hex: "#636366") : Color.clear) : Color.clear, lineWidth: 1))
                                            .shadow(color: goalType == "amount" ? .black.opacity(0.05) : .clear, radius: 2, x: 0, y: 1)
                                    }
                                }
                                .padding(4)
                                .background(DS.surfaceContainerLow)
                                .cornerRadius(12)
                                
                                HStack(spacing: 0) {
                                    Button(action: { withAnimation { frequencyType = "weekly" } }) {
                                        Text("Per Week".tr(appSettings.resolvedLanguage))
                                            .font(.system(size: 13, weight: .medium))
                                            .frame(maxWidth: .infinity)
                                            .padding(.vertical, 10)
                                            .background(frequencyType == "weekly" ? (colorScheme == .dark ? Color(hex: "#3A3A3C") : DS.surface) : Color.clear)
                                            .foregroundColor(frequencyType == "weekly" ? DS.onSurface : DS.onSurfaceVariant)
                                            .cornerRadius(8)
                                            .overlay(RoundedRectangle(cornerRadius: 8).stroke(frequencyType == "weekly" ? (colorScheme == .dark ? Color(hex: "#636366") : Color.clear) : Color.clear, lineWidth: 1))
                                            .shadow(color: frequencyType == "weekly" ? .black.opacity(0.05) : .clear, radius: 2, x: 0, y: 1)
                                    }
                                    
                                    Button(action: { withAnimation { frequencyType = "monthly" } }) {
                                        Text("Per Month".tr(appSettings.resolvedLanguage))
                                            .font(.system(size: 13, weight: .medium))
                                            .frame(maxWidth: .infinity)
                                            .padding(.vertical, 10)
                                            .background(frequencyType == "monthly" ? (colorScheme == .dark ? Color(hex: "#3A3A3C") : DS.surface) : Color.clear)
                                            .foregroundColor(frequencyType == "monthly" ? DS.onSurface : DS.onSurfaceVariant)
                                            .cornerRadius(8)
                                            .overlay(RoundedRectangle(cornerRadius: 8).stroke(frequencyType == "monthly" ? (colorScheme == .dark ? Color(hex: "#636366") : Color.clear) : Color.clear, lineWidth: 1))
                                            .shadow(color: frequencyType == "monthly" ? .black.opacity(0.05) : .clear, radius: 2, x: 0, y: 1)
                                    }
                                }
                                .padding(4)
                                .background(DS.surfaceContainerLow)
                                .cornerRadius(12)
                                .padding(.top, DS.spacingS)
                            }
                            
                            VStack(alignment: .leading, spacing: DS.spacingS) {
                                if goalType == "frequency" {
                                    Text(frequencyType == "weekly" ? "Weekly Target".tr(appSettings.resolvedLanguage) : "Monthly Target".tr(appSettings.resolvedLanguage))
                                        .font(.system(size: 16, weight: .bold))
                                        .foregroundColor(DS.onSurface)
                                    
                                    if frequencyType == "weekly" {
                                        HStack {
                                            Button(action: { if weeklyTarget > 1 { weeklyTarget -= 1 } }) {
                                                Circle()
                                                    .fill(DS.surface)
                                                    .frame(width: 40, height: 40)
                                                    .shadow(color: .black.opacity(0.05), radius: 2)
                                                    .overlay(Image(systemName: "minus").foregroundColor(DS.onSurfaceVariant))
                                            }
                                            Spacer()
                                            VStack(spacing: 4) {
                                                Text("\(weeklyTarget)")
                                                    .font(.system(size: 24, weight: .bold))
                                                    .foregroundColor(DS.onSurface)
                                                Text("Times".tr(appSettings.resolvedLanguage))
                                                    .font(.system(size: 15, weight: .medium))
                                                    .foregroundColor(DS.onSurfaceVariant)
                                            }
                                            Spacer()
                                            Button(action: { if weeklyTarget < 7 { weeklyTarget += 1 } }) {
                                                Circle()
                                                    .fill(DS.surface)
                                                    .frame(width: 40, height: 40)
                                                    .shadow(color: .black.opacity(0.05), radius: 2)
                                                    .overlay(Image(systemName: "plus").foregroundColor(DS.onSurfaceVariant))
                                            }
                                        }
                                        .padding(DS.spacingS)
                                        .background(DS.surfaceContainerLow)
                                        .cornerRadius(12)
                                        .overlay(RoundedRectangle(cornerRadius: 12).stroke(DS.outlineVariant, lineWidth: 1))
                                    } else {
                                        HStack {
                                            Button(action: { if monthlyTarget > 1 { monthlyTarget -= 1 } }) {
                                                Circle()
                                                    .fill(DS.surface)
                                                    .frame(width: 40, height: 40)
                                                    .shadow(color: .black.opacity(0.05), radius: 2)
                                                    .overlay(Image(systemName: "minus").foregroundColor(DS.onSurfaceVariant))
                                            }
                                            Spacer()
                                            VStack(spacing: 4) {
                                                Text("\(monthlyTarget)")
                                                    .font(.system(size: 24, weight: .bold))
                                                    .foregroundColor(DS.onSurface)
                                                Text("Times".tr(appSettings.resolvedLanguage))
                                                    .font(.system(size: 15, weight: .medium))
                                                    .foregroundColor(DS.onSurfaceVariant)
                                            }
                                            Spacer()
                                            Button(action: { if monthlyTarget < 31 { monthlyTarget += 1 } }) {
                                                Circle()
                                                    .fill(DS.surface)
                                                    .frame(width: 40, height: 40)
                                                    .shadow(color: .black.opacity(0.05), radius: 2)
                                                    .overlay(Image(systemName: "plus").foregroundColor(DS.onSurfaceVariant))
                                            }
                                        }
                                        .padding(DS.spacingS)
                                        .background(DS.surfaceContainerLow)
                                        .cornerRadius(12)
                                        .overlay(RoundedRectangle(cornerRadius: 12).stroke(DS.outlineVariant, lineWidth: 1))
                                    }
                                } else {
                                    Text(frequencyType == "weekly" ? "Weekly Target Amount".tr(appSettings.resolvedLanguage) : "Monthly Target Amount".tr(appSettings.resolvedLanguage))
                                        .font(.system(size: 16, weight: .bold))
                                        .foregroundColor(DS.onSurface)
                                        
                                    HStack {
                                        TextField("0", value: $amountValue, format: .number)
                                            .keyboardType(.decimalPad)
                                            .multilineTextAlignment(.center)
                                            .font(.system(size: 24, weight: .bold))
                                            .foregroundColor(DS.onSurface)
                                            .frame(maxWidth: .infinity)
                                        
                                        Picker("", selection: $amountUnit) {
                                            ForEach(unitOptions, id: \.self) { Text($0.tr(appSettings.resolvedLanguage)).tag($0) }
                                        }
                                        .pickerStyle(MenuPickerStyle())
                                        .padding(.horizontal, DS.spacingS)
                                    }
                                    .padding(DS.spacingS)
                                    .background(DS.surfaceContainerLow)
                                    .cornerRadius(12)
                                    .overlay(RoundedRectangle(cornerRadius: 12).stroke(DS.outlineVariant, lineWidth: 1))
                                }
                            }
                        }
                    }
                    
                    // Card 4: Reminder
                    glassCard {
                        VStack(alignment: .leading, spacing: DS.spacingS) {
                            Toggle(isOn: $isReminderEnabled) {
                                HStack(spacing: 8) {
                                    Image(systemName: "bell.fill")
                                        .foregroundColor(isReminderEnabled ? Color(hex: colorHex) : DS.onSurfaceVariant)
                                    Text("打卡提醒".tr(appSettings.resolvedLanguage))
                                        .font(.system(size: 16, weight: .bold))
                                        .foregroundColor(DS.onSurface)
                                }
                            }
                            .tint(Color(hex: colorHex))
                            .onChange(of: isReminderEnabled) { newValue in
                                if newValue {
                                    NotificationManager.shared.requestAuthorization { _ in }
                                }
                            }
                            
                            if isReminderEnabled {
                                Divider().padding(.vertical, 4)
                                
                                HStack {
                                    Text("提醒时间".tr(appSettings.resolvedLanguage))
                                        .font(.system(size: 14, weight: .medium))
                                        .foregroundColor(DS.onSurfaceVariant)
                                    Spacer()
                                    DatePicker("", selection: $reminderTime, displayedComponents: .hourAndMinute)
                                        .labelsHidden()
                                        .environment(\.locale, Locale(identifier: appSettings.resolvedLanguage == .chinese ? "zh_CN" : "en_GB"))
                                }
                                
                                VStack(alignment: .leading, spacing: 6) {
                                    Text("自定义文案".tr(appSettings.resolvedLanguage))
                                        .font(.system(size: 14, weight: .medium))
                                        .foregroundColor(DS.onSurfaceVariant)
                                    
                                    TextField("该打卡啦！坚持就是胜利～".tr(appSettings.resolvedLanguage), text: $reminderText)
                                        .font(.system(size: 16, weight: .regular))
                                        .padding(14)
                                        .background(DS.surfaceContainerLow)
                                        .cornerRadius(8)
                                        .foregroundColor(DS.onSurface)
                                }
                                .padding(.top, 4)
                            }
                        }
                    }
                    
                    Spacer().frame(height: 100) // Give space for bottom sticky button
                }
                .padding(.horizontal, 16)
                .padding(.top, 12)
            }
            
            // Sticky Bottom Button
            VStack {
                Spacer()
                VStack(spacing: 0) {
                    Button(action: submit) {
                        Text(isSubmitting ? "Creating...".tr(appSettings.resolvedLanguage) : (habit == nil ? "Create Habit".tr(appSettings.resolvedLanguage) : "Save Changes".tr(appSettings.resolvedLanguage)))
                            .labelMd()
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 16)
                            .background(DS.primary)
                            .cornerRadius(100)
                            .shadow(color: DS.primary.opacity(0.3), radius: 10, x: 0, y: 5)
                    }
                    .disabled(name.isEmpty || isSubmitting)
                    .opacity(name.isEmpty ? 0.5 : 1)
                    .padding(.horizontal, DS.spacingL)
                    .padding(.top, 16)
                    .padding(.bottom, 24)
                }
                .background(
                    LinearGradient(colors: [DS.bgPrimary.opacity(0), DS.bgPrimary, DS.bgPrimary], startPoint: .top, endPoint: .bottom)
                )
                .ignoresSafeArea(edges: .bottom)
            }
        }
        .background(AmbientBackground())
        .navigationTitle(habit == nil ? "New Habit".tr(appSettings.resolvedLanguage) : "Edit Habit".tr(appSettings.resolvedLanguage))
        .navigationBarTitleDisplayMode(.inline)
        .toolbarBackground(.visible, for: .navigationBar)
        .toolbarBackground(.hidden, for: .navigationBar)
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button(action: { dismiss() }) {
                    Text("关闭")
                        .foregroundColor(DS.primary)
                        .font(.system(size: 16, weight: .medium))
                }
            }
            if let h = habit, h.isArchived {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Menu {
                        Button(action: {
                            h.isArchived = false
                            try? viewContext.save()
                            NotificationManager.shared.scheduleReminder(for: h)
                            WidgetCenter.shared.reloadAllTimelines()
                            dismiss()
                        }) {
                            Label("Restore".tr(appSettings.resolvedLanguage), systemImage: "arrow.uturn.backward")
                        }
                        
                        Button(role: .destructive, action: {
                            showingDeleteAlert = true
                        }) {
                            Label("Delete".tr(appSettings.resolvedLanguage), systemImage: "trash")
                        }
                    } label: {
                        Image(systemName: "ellipsis.circle")
                            .foregroundColor(DS.primary)
                    }
                }
            }
        }
        .alert("Warning", isPresented: $showingDeleteAlert) {
            Button("Cancel".tr(appSettings.resolvedLanguage), role: .cancel) { }
             Button("Delete".tr(appSettings.resolvedLanguage), role: .destructive) {
                if let h = habit {
                    NotificationManager.shared.cancelReminder(for: h)
                    viewContext.delete(h)
                    try? viewContext.save()
            WidgetCenter.shared.reloadAllTimelines()
                    dismiss()
                }
            }
        } message: {
            Text("This action will permanently delete this habit and all its check-in records. It cannot be recovered.".tr(appSettings.resolvedLanguage))
        }
         .onAppear {
            if let h = habit {
                name = h.name
                colorHex = h.color
                icon = h.icon
                goalType = h.goalType
                frequencyType = h.frequencyType
                weeklyTarget = h.weeklyTarget
                monthlyTarget = h.monthlyTarget
                amountValue = h.amountValue
                amountUnit = h.amountUnit
                isReminderEnabled = h.isReminderEnabled
                reminderTime = h.reminderTime
                reminderText = (h.reminderText == "该打卡啦！坚持就是胜利～" || h.reminderText == "Time to check in! Keep it up~") ? "" : h.reminderText
        }
        }
        }
    }
    
    private func submit() {
        isSubmitting = true
        UIImpactFeedbackGenerator(style: .medium).impactOccurred()
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
             let textToSave = (reminderText == "该打卡啦！坚持就是胜利～" || reminderText == "Time to check in! Keep it up~") ? "" : reminderText
             if let h = habit {
                h.name = name; h.color = colorHex; h.icon = icon
                h.goalType = goalType; h.frequencyType = frequencyType
                h.weeklyTarget = weeklyTarget; h.monthlyTarget = monthlyTarget
                h.amountValue = amountValue; h.amountUnit = amountUnit
                h.isReminderEnabled = isReminderEnabled
                h.reminderTime = reminderTime
                h.reminderText = textToSave
                try? viewContext.save()
                NotificationManager.shared.scheduleReminder(for: h)
            } else {
                let newHabit = Habit(context: viewContext)
                newHabit.name = name; newHabit.color = colorHex; newHabit.icon = icon
                newHabit.goalType = goalType; newHabit.frequencyType = frequencyType
                newHabit.weeklyTarget = weeklyTarget; newHabit.monthlyTarget = monthlyTarget
                newHabit.amountValue = amountValue; newHabit.amountUnit = amountUnit
                newHabit.isReminderEnabled = isReminderEnabled
                newHabit.reminderTime = reminderTime
                newHabit.reminderText = textToSave
                try? viewContext.save()
                NotificationManager.shared.scheduleReminder(for: newHabit)
            }
            WidgetCenter.shared.reloadAllTimelines()
            isSubmitting = false
            dismiss()
        }
    }
    
    private func glassCard<Content: View>(@ViewBuilder content: () -> Content) -> some View {
        content()
            .padding(16)
            .background(
                DS.surface.opacity(0.7)
            )
            .background(.ultraThinMaterial)
            .clipShape(RoundedRectangle(cornerRadius: 24, style: .continuous))
            .overlay(
                RoundedRectangle(cornerRadius: 24, style: .continuous)
                    .stroke(DS.outline, lineWidth: 1)
            )
            .shadow(color: DS.primary.opacity(0.08), radius: 20, x: 0, y: 10)
    }
}
