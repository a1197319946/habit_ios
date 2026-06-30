import SwiftUI
import SwiftData

struct HabitDetailView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    
    var habit: Habit?
    
    @State private var name: String = ""
    @State private var colorHex: String = Constants.allColors[0]
    @State private var icon: String = Constants.allIcons[0]
    
    @State private var goalType: String = "frequency"
    @State private var frequencyType: String = "weekly"
    @State private var weeklyTarget: Int = 3
    @State private var monthlyTarget: Int = 10
    @State private var amountValue: Double = 0
    @State private var amountUnit: String = "次"
    @State private var isSubmitting = false
    
    let unitOptions = ["km", "公里", "米", "分钟", "小时", "组", "次", "页"]
    
    var colorPages: [[String]] { Array(Constants.allColors.chunked(into: 18)) }
    var iconPages: [[String]] { Array(Constants.allIcons.chunked(into: 18)) }
    
    var body: some View {
        ZStack {
            DS.bgPrimary.edgesIgnoringSafeArea(.all)
            
            ScrollView {
                VStack(spacing: DS.spacingM) {
                    
                    // ── Live Preview Card ──
                    VStack(spacing: DS.spacingM) {
                        ZStack {
                            Circle()
                                .fill(Color(hex: colorHex).opacity(0.15))
                                .frame(width: 80, height: 80)
                            
                            Image(systemName: icon)
                                .font(.system(size: 34, weight: .semibold))
                                .foregroundColor(Color(hex: colorHex))
                        }
                        
                        TextField("给习惯起个好名字", text: $name)
                            .font(.system(size: 26, weight: .bold, design: .rounded))
                            .multilineTextAlignment(.center)
                            .foregroundColor(DS.textPrimary)
                            .padding(.horizontal)
                    }
                    .padding(.vertical, DS.spacingXL)
                    .frame(maxWidth: .infinity)
                    .card()
                    .padding(.horizontal, DS.spacingL)
                    
                    // ── Color Selection ──
                    VStack(alignment: .leading, spacing: DS.spacingM) {
                        Label("颜色", systemImage: "paintpalette")
                            .font(.system(size: 14, weight: .semibold))
                            .foregroundColor(DS.textSecondary)
                            .padding(.horizontal, 4)
                        
                        TabView {
                            ForEach(0..<colorPages.count, id: \.self) { pageIndex in
                                LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 6), spacing: DS.spacingM) {
                                    ForEach(colorPages[pageIndex], id: \.self) { hex in
                                        Button(action: {
                                            withAnimation(.spring(response: 0.25, dampingFraction: 0.7)) {
                                                colorHex = hex
                                                UIImpactFeedbackGenerator(style: .light).impactOccurred()
                                            }
                                        }) {
                                            ZStack {
                                                Circle()
                                                    .fill(Color(hex: hex))
                                                    .frame(width: 36, height: 36)
                                                
                                                if colorHex == hex {
                                                    Circle()
                                                        .stroke(Color.white, lineWidth: 3)
                                                        .frame(width: 36, height: 36)
                                                    Circle()
                                                        .stroke(Color(hex: hex), lineWidth: 2)
                                                        .frame(width: 42, height: 42)
                                                }
                                            }
                                        }
                                    }
                                }
                                .padding(.horizontal, DS.spacingS)
                                .padding(.bottom, 28)
                            }
                        }
                        .frame(height: 140)
                        .tabViewStyle(PageTabViewStyle(indexDisplayMode: .always))
                    }
                    .padding(DS.spacingL)
                    .card()
                    .padding(.horizontal, DS.spacingL)
                    
                    // ── Icon Selection ──
                    VStack(alignment: .leading, spacing: DS.spacingM) {
                        Label("图标", systemImage: "square.grid.2x2")
                            .font(.system(size: 14, weight: .semibold))
                            .foregroundColor(DS.textSecondary)
                            .padding(.horizontal, 4)
                        
                        TabView {
                            ForEach(0..<iconPages.count, id: \.self) { pageIndex in
                                LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 6), spacing: DS.spacingM) {
                                    ForEach(iconPages[pageIndex], id: \.self) { iconName in
                                        Button(action: {
                                            withAnimation(.spring(response: 0.25, dampingFraction: 0.7)) {
                                                icon = iconName
                                                UIImpactFeedbackGenerator(style: .light).impactOccurred()
                                            }
                                        }) {
                                            ZStack {
                                                RoundedRectangle(cornerRadius: 10)
                                                    .fill(icon == iconName ? Color(hex: colorHex) : DS.bgSubtle)
                                                    .frame(width: 44, height: 44)
                                                
                                                Image(systemName: iconName)
                                                    .foregroundColor(icon == iconName ? .white : DS.textSecondary)
                                                    .font(.system(size: 18, weight: .medium))
                                            }
                                        }
                                    }
                                }
                                .padding(.horizontal, DS.spacingS)
                                .padding(.bottom, 28)
                            }
                        }
                        .frame(height: 180)
                        .tabViewStyle(PageTabViewStyle(indexDisplayMode: .always))
                    }
                    .padding(DS.spacingL)
                    .card()
                    .padding(.horizontal, DS.spacingL)
                    
                    // ── Goal Settings ──
                    VStack(alignment: .leading, spacing: DS.spacingM) {
                        Label("打卡目标", systemImage: "target")
                            .font(.system(size: 14, weight: .semibold))
                            .foregroundColor(DS.textSecondary)
                            .padding(.horizontal, 4)
                        
                        Picker("目标类型", selection: $goalType) {
                            Text("次数").tag("frequency")
                            Text("数值").tag("amount")
                        }
                        .pickerStyle(SegmentedPickerStyle())
                        
                        Picker("周期", selection: $frequencyType) {
                            Text("按周").tag("weekly")
                            Text("按月").tag("monthly")
                        }
                        .pickerStyle(SegmentedPickerStyle())
                        
                        JDivider()
                        
                        if goalType == "frequency" {
                            HStack {
                                Text(frequencyType == "weekly" ? "每周目标次数" : "每月目标次数")
                                    .font(.system(size: 16, weight: .medium))
                                    .foregroundColor(DS.textPrimary)
                                Spacer()
                                HStack(spacing: DS.spacingM) {
                                    Button(action: {
                                        if frequencyType == "weekly" && weeklyTarget > 1 { weeklyTarget -= 1 }
                                        else if frequencyType == "monthly" && monthlyTarget > 1 { monthlyTarget -= 1 }
                                    }) {
                                        Image(systemName: "minus")
                                            .frame(width: 32, height: 32)
                                            .background(DS.bgSubtle)
                                            .cornerRadius(8)
                                            .foregroundColor(DS.textPrimary)
                                    }
                                    
                                    Text("\(frequencyType == "weekly" ? weeklyTarget : monthlyTarget)")
                                        .font(.system(size: 20, weight: .bold, design: .monospaced))
                                        .foregroundColor(DS.accent)
                                        .frame(minWidth: 32, alignment: .center)
                                    
                                    Button(action: {
                                        if frequencyType == "weekly" && weeklyTarget < 7 { weeklyTarget += 1 }
                                        else if frequencyType == "monthly" && monthlyTarget < 31 { monthlyTarget += 1 }
                                    }) {
                                        Image(systemName: "plus")
                                            .frame(width: 32, height: 32)
                                            .background(DS.bgSubtle)
                                            .cornerRadius(8)
                                            .foregroundColor(DS.textPrimary)
                                    }
                                }
                            }
                            .padding(.top, DS.spacingS)
                        } else {
                            HStack {
                                Text("\(frequencyType == "weekly" ? "每周" : "每月")目标总量")
                                    .font(.system(size: 16, weight: .medium))
                                    .foregroundColor(DS.textPrimary)
                                Spacer()
                                TextField("0", value: $amountValue, format: .number)
                                    .keyboardType(.decimalPad)
                                    .multilineTextAlignment(.center)
                                    .font(.system(size: 18, weight: .bold, design: .monospaced))
                                    .foregroundColor(DS.accent)
                                    .frame(width: 70)
                                    .padding(.vertical, 8)
                                    .background(DS.bgSubtle)
                                    .cornerRadius(8)
                                
                                Picker("", selection: $amountUnit) {
                                    ForEach(unitOptions, id: \.self) { Text($0).tag($0) }
                                }
                                .pickerStyle(MenuPickerStyle())
                                .padding(.vertical, 8)
                                .background(DS.bgSubtle)
                                .cornerRadius(8)
                            }
                            .padding(.top, DS.spacingS)
                        }
                    }
                    .padding(DS.spacingL)
                    .card()
                    .padding(.horizontal, DS.spacingL)
                    
                    Spacer().frame(height: 110)
                }
                .padding(.top, DS.spacingM)
            }
            
            // ── Floating Submit Button ──
            VStack {
                Spacer()
                Button(action: submit) {
                    HStack {
                        if isSubmitting {
                            ProgressView().progressViewStyle(CircularProgressViewStyle(tint: .white))
                        }
                        Text(isSubmitting ? "保存中..." : (habit == nil ? "创建习惯" : "保存修改"))
                            .font(.system(size: 17, weight: .bold))
                            .foregroundColor(.white)
                    }
                    .frame(maxWidth: .infinity)
                    .frame(height: 56)
                    .background(name.isEmpty ? DS.textTertiary : DS.accent)
                    .cornerRadius(DS.cornerPill)
                    .padding(.horizontal, DS.spacingXL)
                }
                .disabled(name.isEmpty)
                .padding(.bottom, 36)
                .background(
                    LinearGradient(
                        colors: [DS.bgPrimary.opacity(0), DS.bgPrimary],
                        startPoint: .top, endPoint: .bottom
                    )
                    .frame(height: 120)
                    .allowsHitTesting(false)
                )
            }
            .edgesIgnoringSafeArea(.bottom)
        }
        .navigationTitle(habit == nil ? "新建习惯" : "编辑习惯")
        .navigationBarTitleDisplayMode(.inline)
        .toolbarBackground(DS.bgPrimary, for: .navigationBar)
        .onAppear {
            if let h = habit {
                name = h.name; colorHex = h.color; icon = h.icon
                goalType = h.goalType; frequencyType = h.frequencyType
                weeklyTarget = h.weeklyTarget; monthlyTarget = h.monthlyTarget
                amountValue = h.amountValue; amountUnit = h.amountUnit
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
            isSubmitting = false
            dismiss()
        }
    }
}

extension Array {
    func chunked(into size: Int) -> [[Element]] {
        stride(from: 0, to: count, by: size).map {
            Array(self[$0 ..< Swift.min($0 + size, count)])
        }
    }
}
