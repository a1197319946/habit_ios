import SwiftUI

// MARK: - Japandi Design Tokens

struct DS {
    // Backgrounds
    static let bgPrimary    = Color(hex: "#F7F4EF")   // Warm off-white
    static let bgCard       = Color.white
    static let bgSubtle     = Color(hex: "#F0EDE8")   // Slightly darker warm white

    // Text
    static let textPrimary   = Color(hex: "#2D2D2D")  // Near black
    static let textSecondary = Color(hex: "#9B9088")  // Sand gray
    static let textTertiary  = Color(hex: "#C4BDB6")  // Light sand

    // Accent
    static let accent        = Color(hex: "#E8845C")  // Terracotta orange
    static let accentMuted   = Color(hex: "#F7E0D6")  // Light terracotta
    static let success       = Color(hex: "#5B8A6E")  // Moss green
    static let successMuted  = Color(hex: "#DCF0E7")  // Light moss

    // Borders
    static let border        = Color(hex: "#EAE6E0")  // Warm light border
    static let borderStrong  = Color(hex: "#D4CEC7")  // Stronger border

    // Layout
    static let cornerCard: CGFloat    = 20
    static let cornerSmall: CGFloat   = 12
    static let cornerPill: CGFloat    = 100
    static let spacingXS: CGFloat     = 4
    static let spacingS: CGFloat      = 8
    static let spacingM: CGFloat      = 16
    static let spacingL: CGFloat      = 24
    static let spacingXL: CGFloat     = 32
}

// MARK: - Card Modifier (clean, no glass)

struct CardModifier: ViewModifier {
    var cornerRadius: CGFloat
    func body(content: Content) -> some View {
        content
            .background(DS.bgCard)
            .cornerRadius(cornerRadius)
            .shadow(color: Color.black.opacity(0.05), radius: 8, x: 0, y: 2)
    }
}

extension View {
    func card(cornerRadius: CGFloat = DS.cornerCard) -> some View {
        self.modifier(CardModifier(cornerRadius: cornerRadius))
    }
    
    func subtleCard(cornerRadius: CGFloat = DS.cornerCard) -> some View {
        self
            .background(DS.bgSubtle)
            .cornerRadius(cornerRadius)
    }
    
    func accentPill() -> some View {
        self
            .background(DS.accent)
            .cornerRadius(DS.cornerPill)
    }
}

// MARK: - Typography helpers

extension Text {
    func display() -> Text {
        self.font(.system(size: 48, weight: .heavy, design: .rounded))
    }
    func headline1() -> Text {
        self.font(.system(size: 28, weight: .bold, design: .rounded))
    }
    func headline2() -> Text {
        self.font(.system(size: 22, weight: .bold, design: .rounded))
    }
    func bodyBold() -> Text {
        self.font(.system(size: 17, weight: .semibold))
    }
    func bodyRegular() -> Text {
        self.font(.system(size: 17, weight: .regular))
    }
    func caption1() -> Text {
        self.font(.system(size: 13, weight: .medium))
    }
    func mono() -> Text {
        self.font(.system(size: 17, weight: .semibold, design: .monospaced))
    }
}

// MARK: - Divider

struct JDivider: View {
    var body: some View {
        Rectangle()
            .fill(DS.border)
            .frame(height: 1)
    }
}

// MARK: - Accent Dot (replaces glow/neon effects)

struct AccentDot: View {
    var color: Color
    var size: CGFloat = 10
    var body: some View {
        Circle()
            .fill(color)
            .frame(width: size, height: size)
    }
}
