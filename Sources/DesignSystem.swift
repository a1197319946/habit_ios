import SwiftUI

// MARK: - Bloom Design System (Material Design 3 based)

struct DS {
    // Primary Colors
    static var primary: Color {
        Color(hex: UserDefaults.standard.string(forKey: "themeColorHex") ?? "#5e4dbb")
    }
    static let onPrimary = Color.white
    static let primaryContainer = Color(hex: "#9d8dff")
    static let onPrimaryContainer = Color(hex: "#321b8e")
    
    // Secondary Colors
    static let secondary = Color(hex: "#2a6951")
    static let onSecondary = Color.white
    static let secondaryContainer = Color(hex: "#aceece")
    static let onSecondaryContainer = Color(hex: "#2f6e55")
    
    // Tertiary Colors
    static let tertiary = Color(hex: "#79573f")
    static let onTertiary = Color.white
    static let tertiaryContainer = Color(hex: "#bd9479")
    static let onTertiaryContainer = Color(hex: "#492e19")
    
    // Surface & Background Colors
    static let background = Color(hex: "#fbf8fe")
    static let onBackground = Color(hex: "#1b1b1f")
    static let surface = Color(hex: "#fbf8fe")
    static let onSurface = Color(hex: "#1b1b1f")
    static let surfaceVariant = Color(hex: "#e4e1e7")
    static let onSurfaceVariant = Color(hex: "#484552")
    static let surfaceContainerLow = Color(hex: "#f6f2f8")
    static let surfaceContainer = Color(hex: "#f0edf2")
    static let surfaceContainerHigh = Color(hex: "#eae7ed")
    static let surfaceContainerHighest = Color(hex: "#e4e1e7")
    
    // Fixed Colors
    static let primaryFixed = Color(hex: "#e5deff")
    static let primaryFixedDim = Color(hex: "#c8bfff")
    static let secondaryFixedDim = Color(hex: "#94d4b6")
    static let tertiaryFixedDim = Color(hex: "#eabea0")
    
    // Borders & Outlines
    static let outline = Color(hex: "#787584")
    static let outlineVariant = Color(hex: "#c9c4d5")
    
    // States
    static let error = Color(hex: "#ba1a1a")
    static let onError = Color.white
    static let errorContainer = Color(hex: "#ffdad6")
    static let onErrorContainer = Color(hex: "#93000a")

    // Mapping old tokens to new for backward compatibility during transition
    static var bgPrimary: Color { background }
    static var bgCard: Color { surface }
    static var bgSubtle: Color { surfaceContainer }
    static var textPrimary: Color { onSurface }
    static var textSecondary: Color { onSurfaceVariant }
    static var textTertiary: Color { outline }
    static var accent: Color { primary }
    static var accentMuted: Color { primaryContainer }
    static var success: Color { secondary }
    static var successMuted: Color { secondaryContainer }
    static var border: Color { outlineVariant }
    static var borderStrong: Color { outline }

    // Layout
    static let cornerCard: CGFloat    = 24 // Updated for softer MD3 style
    static let cornerSmall: CGFloat   = 16 // Updated
    static let cornerPill: CGFloat    = 100
    static let spacingXS: CGFloat     = 4
    static let spacingS: CGFloat      = 8
    static let spacingM: CGFloat      = 16
    static let spacingL: CGFloat      = 24
    static let spacingXL: CGFloat     = 32
}

// MARK: - Card Modifier (Glass/Bloom style)

struct CardModifier: ViewModifier {
    var cornerRadius: CGFloat
    func body(content: Content) -> some View {
        content
            .background(.ultraThinMaterial)
            .background(Color.white.opacity(0.7))
            .clipShape(RoundedRectangle(cornerRadius: cornerRadius, style: .continuous))
            .overlay(
                RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                    .stroke(Color.white, lineWidth: 1)
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

// MARK: - Typography helpers

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

// MARK: - Ambient Background
struct AmbientBackground: View {
    var body: some View {
        ZStack {
            DS.background.ignoresSafeArea()
            
            // Top Left / Left Blob
            Circle()
                .fill(Color(hex: "#C8BFFF").opacity(0.3)) // Primary fixed dim tinted
                .frame(width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.width)
                .blur(radius: 120)
                .offset(x: -UIScreen.main.bounds.width * 0.3, y: -UIScreen.main.bounds.height * 0.1)
            
            // Bottom Right / Right Blob
            Circle()
                .fill(Color(hex: "#ACEECE").opacity(0.3)) // Secondary container tinted
                .frame(width: UIScreen.main.bounds.width * 1.2, height: UIScreen.main.bounds.width * 1.2)
                .blur(radius: 140)
                .offset(x: UIScreen.main.bounds.width * 0.4, y: UIScreen.main.bounds.height * 0.2)
        }
        .ignoresSafeArea()
    }
}

// MARK: - Divider

struct JDivider: View {
    var body: some View {
        Rectangle()
            .fill(DS.outlineVariant.opacity(0.5))
            .frame(height: 1)
    }
}

// MARK: - Accent Dot

struct AccentDot: View {
    var color: Color
    var size: CGFloat = 10
    var body: some View {
        Circle()
            .fill(color)
            .frame(width: size, height: size)
    }
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
    
    func toHex() -> String? {
        let uic = UIColor(self)
        guard let components = uic.cgColor.components, components.count >= 3 else {
            return nil
        }
        let r = Float(components[0])
        let g = Float(components[1])
        let b = Float(components[2])
        var a = Float(1.0)
        
        if components.count >= 4 {
            a = Float(components[3])
        }
        
        if a != Float(1.0) {
            return String(format: "%02lX%02lX%02lX%02lX", lroundf(r * 255), lroundf(g * 255), lroundf(b * 255), lroundf(a * 255))
        } else {
            return String(format: "#%02lX%02lX%02lX", lroundf(r * 255), lroundf(g * 255), lroundf(b * 255))
        }
    }
}
