import re

with open('Sources/DesignSystem.swift', 'r') as f:
    ds = f.read()

card_code = """
    static let cornerCard: CGFloat = 24
"""

if "static let cornerCard" not in ds:
    ds = ds.replace("static let cornerPill: CGFloat = 999", "static let cornerPill: CGFloat = 999\n    static let cornerCard: CGFloat = 24")

view_ext = """
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
"""

if "struct CardModifier" not in ds:
    ds = ds + view_ext

with open('Sources/DesignSystem.swift', 'w') as f:
    f.write(ds)
