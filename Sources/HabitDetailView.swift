import SwiftUI
import SwiftData

struct HabitDetailView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    
    var habit: Habit?
    
    @State private var name: String = ""
    @State private var colorHex: String = Constants.allColors[0]
    @State private var icon: String = Constants.allIcons[0]
    
    @State private var goalType: String = "frequency" // frequency, amount
    @State private var frequencyType: String = "weekly" // weekly, monthly
    
    @State private var weeklyTarget: Int = 3
    @State private var monthlyTarget: Int = 10
    
    @State private var amountValue: Double = 0
    @State private var amountUnit: String = "km"
    
    @State private var isSubmitting = false
    
    let unitOptions = ["km", "公里", "米", "分钟", "小时", "组", "次", "页"]
    
    // Pagination data
    var colorPages: [[String]] {
        Array(Constants.allColors.chunked(into: 18))
    }
    var iconPages: [[String]] {
        Array(Constants.allIcons.chunked(into: 18))
    }
    
    var body: some View {
        ZStack {
            // Background
            Color(hex: "#F5F5F7").edgesIgnoringSafeArea(.all)
            
            ScrollView {
                VStack(spacing: 20) {
                    // Habit Name
                    VStack(alignment: .leading, spacing: 8) {
                        HStack {
                            Text("习惯名称").font(.subheadline).fontWeight(.semibold)
                            Text("*").foregroundColor(.red).font(.subheadline)
                        }
                        TextField("例如：早起喝水", text: $name)
                            .padding()
                            .background(Color(UIColor.systemBackground))
                            .cornerRadius(12)
                    }
                    .padding(.horizontal)
                    
                    // Colors
                    VStack(alignment: .leading, spacing: 8) {
                        Text("选择颜色").font(.subheadline).fontWeight(.semibold).padding(.horizontal)
                        
                        TabView {
                            ForEach(0..<colorPages.count, id: \.self) { pageIndex in
                                LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 6), spacing: 12) {
                                    ForEach(colorPages[pageIndex], id: \.self) { hex in
                                        Circle()
                                            .fill(Color(hex: hex))
                                            .frame(width: 30, height: 30)
                                            .overlay(
                                                Circle()
                                                    .stroke(Color.primary, lineWidth: colorHex == hex ? 2 : 0)
                                                    .scaleEffect(colorHex == hex ? 1.2 : 1.0)
                                            )
                                            .onTapGesture {
                                                withAnimation(.spring()) {
                                                    colorHex = hex
                                                }
                                            }
                                    }
                                }
                                .padding(.horizontal)
                                .padding(.bottom, 20)
                            }
                        }
                        .frame(height: 140)
                        .tabViewStyle(PageTabViewStyle(indexDisplayMode: .always))
                    }
                    
                    // Icons
                    VStack(alignment: .leading, spacing: 8) {
                        Text("选择图标").font(.subheadline).fontWeight(.semibold).padding(.horizontal)
                        
                        TabView {
                            ForEach(0..<iconPages.count, id: \.self) { pageIndex in
                                LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 6), spacing: 12) {
                                    ForEach(iconPages[pageIndex], id: \.self) { iconName in
                                        ZStack {
                                            RoundedRectangle(cornerRadius: 8)
                                                .fill(icon == iconName ? Color(hex: colorHex) : Color(UIColor.systemBackground))
                                                .frame(width: 40, height: 40)
                                                .shadow(color: Color.black.opacity(icon == iconName ? 0.2 : 0), radius: 4, y: 2)
                                            
                                            Image(systemName: iconName)
                                                .foregroundColor(icon == iconName ? .white : .primary)
                                                .font(.system(size: 20))
                                        }
                                        .onTapGesture {
                                            withAnimation(.spring()) {
                                                icon = iconName
                                            }
                                        }
                                    }
                                }
                                .padding(.horizontal)
                                .padding(.bottom, 20)
                            }
                        }
                        .frame(height: 180)
                        .tabViewStyle(PageTabViewStyle(indexDisplayMode: .always))
                    }
                    
                    // Goal Settings
                    VStack(alignment: .leading, spacing: 12) {
                        HStack {
                            Text("打卡目标").font(.subheadline).fontWeight(.semibold)
                            Text("*").foregroundColor(.red).font(.subheadline)
                        }
                        
                        // Goal Type Segment
                        Picker("目标类型", selection: $goalType) {
                            Text("次数目标").tag("frequency")
                            Text("总量目标").tag("amount")
                        }
                        .pickerStyle(SegmentedPickerStyle())
                        
                        // Frequency Type Segment
                        Picker("周期", selection: $frequencyType) {
                            Text("按周").tag("weekly")
                            Text("按月").tag("monthly")
                        }
                        .pickerStyle(SegmentedPickerStyle())
                        
                        // Settings Content
                        VStack(spacing: 16) {
                            if goalType == "frequency" {
                                if frequencyType == "weekly" {
                                    HStack {
                                        Text("每周目标次数").font(.subheadline)
                                        Spacer()
                                        Stepper("\(weeklyTarget)", value: $weeklyTarget, in: 1...7)
                                            .labelsHidden()
                                        Text("\(weeklyTarget)").frame(width: 30).font(.headline).multilineTextAlignment(.center)
                                    }
                                } else {
                                    HStack {
                                        Text("每月目标次数").font(.subheadline)
                                        Spacer()
                                        Stepper("\(monthlyTarget)", value: $monthlyTarget, in: 1...31)
                                            .labelsHidden()
                                        Text("\(monthlyTarget)").frame(width: 30).font(.headline).multilineTextAlignment(.center)
                                    }
                                }
                            } else {
                                HStack {
                                    Text("\(frequencyType == "weekly" ? "每周" : "每月")目标总量").font(.subheadline)
                                    Spacer()
                                    TextField("0", value: $amountValue, format: .number)
                                        .keyboardType(.decimalPad)
                                        .multilineTextAlignment(.center)
                                        .frame(width: 80, height: 36)
                                        .background(Color(UIColor.systemBackground))
                                        .cornerRadius(8)
                                        .overlay(RoundedRectangle(cornerRadius: 8).stroke(Color.gray.opacity(0.3), lineWidth: 1))
                                    
                                    Picker("Unit", selection: $amountUnit) {
                                        ForEach(unitOptions, id: \.self) { unit in
                                            Text(unit).tag(unit)
                                        }
                                    }
                                    .pickerStyle(MenuPickerStyle())
                                    .frame(width: 80, height: 36)
                                    .background(Color(UIColor.systemBackground))
                                    .cornerRadius(8)
                                    .overlay(RoundedRectangle(cornerRadius: 8).stroke(Color.gray.opacity(0.3), lineWidth: 1))
                                }
                            }
                        }
                        .padding()
                        .background(Color(UIColor.systemBackground))
                        .cornerRadius(12)
                    }
                    .padding(.horizontal)
                    
                    Spacer().frame(height: 100) // Padding for bottom button
                }
                .padding(.top, 16)
            }
            
            // Bottom Button
            VStack {
                Spacer()
                ZStack {
                    // Blur background
                    Rectangle()
                        .fill(Color(UIColor.systemBackground).opacity(0.8))
                        .frame(height: 100)
                        .blur(radius: 20)
                        .edgesIgnoringSafeArea(.bottom)
                    
                    Button(action: submit) {
                        HStack {
                            if isSubmitting {
                                ProgressView().progressViewStyle(CircularProgressViewStyle(tint: .white))
                            }
                            Text(isSubmitting ? "创建中..." : (habit == nil ? "完成创建" : "保存修改"))
                        }
                        .frame(maxWidth: .infinity)
                        .frame(height: 52)
                        .background(Color(hex: "#8B5CF6"))
                        .foregroundColor(.white)
                        .font(.headline)
                        .cornerRadius(26)
                        .padding(.horizontal, 20)
                    }
                    .disabled(name.isEmpty)
                }
            }
            .edgesIgnoringSafeArea(.bottom)
        }
        .navigationTitle(habit == nil ? "新建习惯" : "编辑习惯")
        .navigationBarTitleDisplayMode(.inline)
        .navigationBarItems(leading: Button(action: {
            dismiss()
        }) {
            Image(systemName: "xmark")
                .foregroundColor(Color(hex: "#9CA3AF"))
                .font(.system(size: 20, weight: .bold))
        })
        .onAppear {
            if let habit = habit {
                name = habit.name
                colorHex = habit.color
                icon = habit.icon
                goalType = habit.goalType
                frequencyType = habit.frequencyType
                weeklyTarget = habit.weeklyTarget
                monthlyTarget = habit.monthlyTarget
                amountValue = habit.amountValue
                amountUnit = habit.amountUnit
            }
        }
    }
    
    private func submit() {
        isSubmitting = true
        
        // Simulating delay
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
            if let habit = habit {
                habit.name = name
                habit.color = colorHex
                habit.icon = icon
                habit.goalType = goalType
                habit.frequencyType = frequencyType
                habit.weeklyTarget = weeklyTarget
                habit.monthlyTarget = monthlyTarget
                habit.amountValue = amountValue
                habit.amountUnit = amountUnit
            } else {
                let newHabit = Habit(name: name, color: colorHex, icon: icon)
                newHabit.goalType = goalType
                newHabit.frequencyType = frequencyType
                newHabit.weeklyTarget = weeklyTarget
                newHabit.monthlyTarget = monthlyTarget
                newHabit.amountValue = amountValue
                newHabit.amountUnit = amountUnit
                // Put at end of list
                // Order logic will be handled if needed, for now just 0
                modelContext.insert(newHabit)
            }
            isSubmitting = false
            dismiss()
        }
    }
}

extension Array {
    func chunked(into size: Int) -> [[Element]] {
        return stride(from: 0, to: count, by: size).map {
            Array(self[$0 ..< Swift.min($0 + size, count)])
        }
    }
}
