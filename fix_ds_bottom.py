import re

with open('Sources/DesignSystem.swift', 'r') as f:
    ds = f.read()

bottom_part = """
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
"""

if "func display() -> Text" not in ds:
    ds = ds + bottom_part

with open('Sources/DesignSystem.swift', 'w') as f:
    f.write(ds)
