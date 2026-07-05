import SwiftUI
import WidgetKit
import SwiftData

extension Array {
    func chunked(into size: Int) -> [[Element]] {
        return stride(from: 0, to: count, by: size).map {
            Array(self[$0 ..< Swift.min($0 + size, count)])
        }
    }
}

struct HabitDetailView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
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
                            Text("What do you want to build?".tr(appSettings.resolvedLanguage))
                                .labelMd()
                                .foregroundColor(DS.onSurfaceVariant)
                            
                            HStack {
                                Image(systemName: "pencil")
                                    .foregroundColor(DS.outline)
                                    .padding(.leading, DS.spacingS)
                                
                                TextField("e.g. Read 10 pages, Drink water...".tr(appSettings.resolvedLanguage), text: $name)
                                    .font(.system(size: 16, weight: .regular))
                                    .foregroundColor(DS.onSurface)
                                    .padding(.vertical, DS.spacingS)
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
                                    .labelMd()
                                    .foregroundColor(DS.onSurfaceVariant)
                                
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
                                Text("Choose an Icon".tr(appSettings.resolvedLanguage))
                                    .labelMd()
                                    .foregroundColor(DS.onSurfaceVariant)
                                
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
                                                            .fill(icon == iconName ? DS.primaryContainer : DS.surfaceContainerLow)
                                                            .frame(width: 36, height: 36)
                                                            .overlay(
                                                                Circle()
                                                                    .stroke(icon == iconName ? Color.clear : DS.outlineVariant, lineWidth: 1)
                                                            )
                                                        
                                                        Image(systemName: iconName)
                                                            .font(.system(size: 16))
                                                            .foregroundColor(icon == iconName ? DS.onPrimaryContainer : DS.onSurfaceVariant)
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
                                    .labelMd()
                                    .foregroundColor(DS.onSurfaceVariant)
                                
                                HStack(spacing: 0) {
                                    Button(action: { withAnimation { goalType = "frequency" } }) {
                                        Text("次数目标".tr(appSettings.resolvedLanguage))
                                            .labelMd()
                                            .frame(maxWidth: .infinity)
                                            .padding(.vertical, 10)
                                            .background(goalType == "frequency" ? DS.surface : Color.clear)
                                            .foregroundColor(goalType == "frequency" ? DS.primary : DS.onSurfaceVariant)
                                            .cornerRadius(8)
                                            .shadow(color: goalType == "frequency" ? .black.opacity(0.05) : .clear, radius: 2, x: 0, y: 1)
                                    }
                                    
                                    Button(action: { withAnimation { goalType = "amount" } }) {
                                        Text("总量目标".tr(appSettings.resolvedLanguage))
                                            .labelMd()
                                            .frame(maxWidth: .infinity)
                                            .padding(.vertical, 10)
                                            .background(goalType == "amount" ? DS.surface : Color.clear)
                                            .foregroundColor(goalType == "amount" ? DS.primary : DS.onSurfaceVariant)
                                            .cornerRadius(8)
                                            .shadow(color: goalType == "amount" ? .black.opacity(0.05) : .clear, radius: 2, x: 0, y: 1)
                                    }
                                }
                                .padding(4)
                                .background(DS.surfaceContainerLow)
                                .cornerRadius(12)
                                
                                HStack(spacing: 0) {
                                    Button(action: { withAnimation { frequencyType = "weekly" } }) {
                                        Text("Per Week".tr(appSettings.resolvedLanguage))
                                            .labelMd()
                                            .frame(maxWidth: .infinity)
                                            .padding(.vertical, 10)
                                            .background(frequencyType == "weekly" ? DS.surface : Color.clear)
                                            .foregroundColor(frequencyType == "weekly" ? DS.primary : DS.onSurfaceVariant)
                                            .cornerRadius(8)
                                            .shadow(color: frequencyType == "weekly" ? .black.opacity(0.05) : .clear, radius: 2, x: 0, y: 1)
                                    }
                                    
                                    Button(action: { withAnimation { frequencyType = "monthly" } }) {
                                        Text("Per Month".tr(appSettings.resolvedLanguage))
                                            .labelMd()
                                            .frame(maxWidth: .infinity)
                                            .padding(.vertical, 10)
                                            .background(frequencyType == "monthly" ? DS.surface : Color.clear)
                                            .foregroundColor(frequencyType == "monthly" ? DS.primary : DS.onSurfaceVariant)
                                            .cornerRadius(8)
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
                                        .labelMd()
                                        .foregroundColor(DS.onSurfaceVariant)
                                    
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
                                                    .labelSm()
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
                                                    .labelSm()
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
                                        .labelMd()
                                        .foregroundColor(DS.onSurfaceVariant)
                                        
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
                    
                    Spacer().frame(height: 100) // Give space for bottom sticky button
                }
                .padding(.horizontal, DS.spacingL)
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
                            try? modelContext.save()
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
                    modelContext.delete(h)
                    try? modelContext.save()
            WidgetCenter.shared.reloadAllTimelines()
                    dismiss()
                }
            }
        } message: {
            Text("This action will permanently delete this habit and all its check-in records. It cannot be recovered.".tr(appSettings.resolvedLanguage))
        }
        .onAppear {
            if let h = habit {
                name = h.name; colorHex = h.color; icon = h.icon
                goalType = h.goalType; frequencyType = h.frequencyType
                weeklyTarget = h.weeklyTarget; monthlyTarget = h.monthlyTarget
                amountValue = h.amountValue; amountUnit = h.amountUnit
            }
        }
        }
    }
    
    private func submit() {
        isSubmitting = true
        UIImpactFeedbackGenerator(style: .medium).impactOccurred()
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
            if let h = habit {
                h.name = name; h.color = colorHex; h.icon = icon
                h.goalType = goalType; h.frequencyType = frequencyType
                h.weeklyTarget = weeklyTarget; h.monthlyTarget = monthlyTarget
                h.amountValue = amountValue; h.amountUnit = amountUnit
            } else {
                let newHabit = Habit(name: name, color: colorHex, icon: icon)
                newHabit.goalType = goalType; newHabit.frequencyType = frequencyType
                newHabit.weeklyTarget = weeklyTarget; newHabit.monthlyTarget = monthlyTarget
                newHabit.amountValue = amountValue; newHabit.amountUnit = amountUnit
                modelContext.insert(newHabit)
            }
            WidgetCenter.shared.reloadAllTimelines()
            isSubmitting = false
            dismiss()
        }
    }
    
    private func glassCard<Content: View>(@ViewBuilder content: () -> Content) -> some View {
        content()
            .padding(DS.spacingL)
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

struct HabitSection<Content: View>: View {
    let title: String
    let content: Content
    
    init(title: String, @ViewBuilder content: () -> Content) {
        self.title = title
        self.content = content()
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: DS.spacingS) {
            Text(title)
                .font(.system(size: 14, weight: .bold))
                .foregroundColor(DS.onSurfaceVariant)
                .padding(.horizontal, DS.spacingL)
                .padding(.leading, 8)
            
            VStack(spacing: DS.spacingS) {
                content
            }
            .padding(DS.spacingL)
            .background(
                DS.surface.opacity(0.7)
            )
            .background(.ultraThinMaterial)
            .clipShape(RoundedRectangle(cornerRadius: 24, style: .continuous))
            .overlay(
                RoundedRectangle(cornerRadius: 24, style: .continuous)
                    .stroke(DS.outlineVariant, lineWidth: 1)
            )
            .shadow(color: Color.black.opacity(0.03), radius: 10, x: 0, y: 5)
            .padding(.horizontal, DS.spacingL)
        }
    }
}
                    .stroke(DS.outlineVariant, lineWidth: 1)
            )
            .shadow(color: Color.black.opacity(0.03), radius: 10, x: 0, y: 5)
            .padding(.horizontal, DS.spacingL)
        }
    }
}
