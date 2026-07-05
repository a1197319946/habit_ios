
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
    static let cornerCard: CGFloat = 24
    
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
    
    static let onPrimary = Color.white
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


extension Color {
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hex.count {
        case 3: // RGB (12-bit)
            (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6: // RGB (24-bit)
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8: // ARGB (32-bit)
            (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            (a, r, g, b) = (1, 1, 1, 0)
        }
        self.init(
            .sRGB,
            red: Double(r) / 255,
            green: Double(g) / 255,
            blue:  Double(b) / 255,
            opacity: Double(a) / 255
        )
    }
}

extension Text {
    func display() -> Text { self.font(.system(size: 34, weight: .bold)) } // Down from 48
    func headlineLg() -> Text { self.font(.system(size: 28, weight: .semibold)) } // Down from 32
    func headlineLgMobile() -> Text { self.font(.system(size: 22, weight: .semibold)) } // Down from 24
    func headlineMd() -> Text { self.font(.system(size: 20, weight: .semibold)) } // Down from 24
    func bodyLg() -> Text { self.font(.system(size: 17, weight: .regular)) } // Down from 18
    func bodyMd() -> Text { self.font(.system(size: 15, weight: .regular)) } // Down from 16
    func labelMd() -> Text { self.font(.system(size: 13, weight: .medium)) } // Down from 14
    func labelSm() -> Text { self.font(.system(size: 11, weight: .semibold)) } // Down from 12
}

struct AmbientBackground: View {
    var body: some View {
        ZStack {
            DS.bgPrimary.ignoresSafeArea()
            
            Circle()
                .fill(Color(hex: "#C8BFFF").opacity(0.3)) 
                .frame(width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.width)
                .blur(radius: 120)
                .offset(x: -UIScreen.main.bounds.width * 0.3, y: -UIScreen.main.bounds.height * 0.1)
            
            Circle()
                .fill(Color(hex: "#ACEECE").opacity(0.3)) 
                .frame(width: UIScreen.main.bounds.width * 1.2, height: UIScreen.main.bounds.width * 1.2)
                .blur(radius: 140)
                .offset(x: UIScreen.main.bounds.width * 0.4, y: UIScreen.main.bounds.height * 0.2)
        }
        .ignoresSafeArea()
    }
}

struct JDivider: View {
    var body: some View {
        Rectangle()
            .fill(DS.outlineVariant.opacity(0.5))
            .frame(height: 1)
    }
}

struct AccentDot: View {
    var color: Color
    var size: CGFloat = 10
    var body: some View {
        Circle()
            .fill(color)
            .frame(width: size, height: size)
    }
}

// Ensure Color.toHex() is present
extension Color {
    func toHex() -> String? {
        let uic = UIColor(self)
        guard let components = uic.cgColor.components, components.count >= 3 else {
            return nil
        }
        let r = Float(components[0])
        let g = Float(components[1])
        let b = Float(components[2])
        var a = Float(1.0)
        if components.count >= 4 { a = Float(components[3]) }
        if a != Float(1.0) {
            return String(format: "%02lX%02lX%02lX%02lX", lroundf(r * 255), lroundf(g * 255), lroundf(b * 255), lroundf(a * 255))
        } else {
            return String(format: "#%02lX%02lX%02lX", lroundf(r * 255), lroundf(g * 255), lroundf(b * 255))
        }
    }
}

struct CardModifier: ViewModifier {
    var cornerRadius: CGFloat
    func body(content: Content) -> some View {
        content
            .background(.ultraThinMaterial)
            .background(DS.surface.opacity(0.7))
            .clipShape(RoundedRectangle(cornerRadius: cornerRadius, style: .continuous))
            .overlay(
                RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                    .stroke(DS.surface, lineWidth: 1)
            )
            .shadow(color: DS.primary.opacity(0.08), radius: 20, x: 0, y: 10)
    }
}

extension View {
    func card(cornerRadius: CGFloat = DS.cornerCard) -> some View {
        self.modifier(CardModifier(cornerRadius: cornerRadius))
    }
    
    func subtleCard(cornerRadius: CGFloat = DS.cornerCard) -> some View {
        self
            .background(DS.surfaceContainer)
            .cornerRadius(cornerRadius)
    }
    
    func accentPill() -> some View {
        self
            .background(DS.primary)
            .cornerRadius(DS.cornerPill)
    }
}
