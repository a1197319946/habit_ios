import re

code = """
import SwiftUI
import UIKit

// Dynamic Color Helper
extension Color {
    init(light: Color, dark: Color) {
        self.init(UIColor { traitCollection in
            if traitCollection.userInterfaceStyle == .dark {
                return UIColor(dark)
            } else {
                return UIColor(light)
            }
        })
    }
}

struct DS {
    // spacing and corner radius
    static let spacingXS: CGFloat = 4
    static let spacingS: CGFloat = 8
    static let spacingM: CGFloat = 16
    static let spacingL: CGFloat = 24
    static let spacingXL: CGFloat = 32
    
    static let cornerS: CGFloat = 8
    static let cornerM: CGFloat = 16
    static let cornerL: CGFloat = 24
    static let cornerXL: CGFloat = 32
    static let cornerPill: CGFloat = 999
    
    static let bgPrimary = Color(light: Color(hex: "#F9FAFC"), dark: Color(hex: "#121212"))
    static let bgSubtle = Color(light: Color(hex: "#F0F2F5"), dark: Color(hex: "#1E1E1E"))
    
    static let surface = Color(light: .white, dark: Color(hex: "#1C1C1E"))
    static let surfaceVariant = Color(light: Color(hex: "#F3F4F6"), dark: Color(hex: "#2C2C2E"))
    static let uncheckedPlaceholder = Color(light: Color(hex: "#F3F4F6"), dark: Color(hex: "#3A3A3C"))
    static let surfaceContainerLow = Color(light: Color(hex: "#F9FAFB"), dark: Color(hex: "#1C1C1E"))
    static let surfaceContainer = Color(light: Color(hex: "#F3F4F6"), dark: Color(hex: "#2C2C2E"))
    static let surfaceContainerHigh = Color(light: Color(hex: "#E5E7EB"), dark: Color(hex: "#3A3A3C"))
    static let surfaceContainerHighest = Color(light: Color(hex: "#D1D5DB"), dark: Color(hex: "#48484A"))
    
    static let textPrimary = Color(light: Color(hex: "#111827"), dark: Color(hex: "#F9FAFB"))
    static let textSecondary = Color(light: Color(hex: "#4B5563"), dark: Color(hex: "#D1D5DB"))
    static let textTertiary = Color(light: Color(hex: "#9CA3AF"), dark: Color(hex: "#6B7280"))
    
    static let onBackground = textPrimary
    static let onSurface = textPrimary
    static let onSurfaceVariant = textSecondary
    
    static let outline = Color(light: Color(hex: "#E5E7EB"), dark: Color(hex: "#374151"))
    static let outlineVariant = Color(light: Color(hex: "#F3F4F6"), dark: Color(hex: "#2C2C2E"))
    static let border = outline
    
    static var primary: Color {
        let hex = UserDefaults(suiteName: "group.com.littlehabit.tracker")?.string(forKey: "themeColorHex") ?? "#5e4dbb"
        return Color(hex: hex)
    }
    static let primaryFixed = Color(hex: "#e5deff")
    
    static let primaryContainer = Color(light: Color(hex: "#E8E5F4"), dark: Color(hex: "#342C4C"))
    static let onPrimaryContainer = Color(light: Color(hex: "#2A1E5C"), dark: Color(hex: "#D0C8EF"))
    
    static let secondary = Color(light: Color(hex: "#10B981"), dark: Color(hex: "#059669"))
    static let tertiary = Color(light: Color(hex: "#F59E0B"), dark: Color(hex: "#D97706"))
    static let accent = Color(light: Color(hex: "#3B82F6"), dark: Color(hex: "#2563EB"))
    
    static let success = Color(light: Color(hex: "#10B981"), dark: Color(hex: "#34D399"))
    static let successMuted = Color(light: Color(hex: "#D1FAE5"), dark: Color(hex: "#064E3B"))
    static let warning = Color(light: Color(hex: "#F59E0B"), dark: Color(hex: "#FBBF24"))
    static let warningMuted = Color(light: Color(hex: "#FEF3C7"), dark: Color(hex: "#78350F"))
    static let error = Color(light: Color(hex: "#EF4444"), dark: Color(hex: "#F87171"))
    static let errorMuted = Color(light: Color(hex: "#FEE2E2"), dark: Color(hex: "#7F1D1D"))
}
"""
with open('Sources/DesignSystem.swift', 'w') as f:
    f.write(code)
