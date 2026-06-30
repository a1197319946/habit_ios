import Foundation
import SwiftUI

struct Constants {
    static let allColors: [String] = [
        // Page 1: Reds, Pinks, Oranges
        "#B71C1C", "#FF3B30", "#F87171", "#FCA5A5", "#FFADAD", "#FFB3BA",
        "#880E4F", "#E91E63", "#FF2D55", "#FB7185", "#FFC6FF", "#FDE2E4",
        "#BF360C", "#E65100", "#FF6F00", "#F57F17", "#FF9500", "#FFDFBA",
        
        // Page 2: Yellows, Limes, Greens
        "#FFD6A5", "#FFCC00", "#FBBF24", "#FDE047", "#FFFFBA", "#FDFFB6",
        "#827717", "#CDDC39", "#8BC34A", "#E2F0CB", "#33691E", "#1B5E20",
        "#4CAF50", "#4CD964", "#34D399", "#86EFAC", "#BAFFC9", "#CAFFBF",
        
        // Page 3: Teals, Cyans, Blues
        "#004D40", "#006064", "#009688", "#B5EAD7", "#00BCD4", "#67E8F9",
        "#9BF6FF", "#5AC8FA", "#38BDF8", "#BAE1FF", "#A0C4FF", "#01579B",
        "#0D47A1", "#007AFF", "#2196F3", "#1A237E", "#3F51B5", "#818CF8",
        
        // Page 4: Indigos, Purples, Neutrals
        "#311B92", "#5856D6", "#BDB2FF", "#C7CEEA", "#4A148C", "#673AB7",
        "#9C27B0", "#A78BFA", "#E879F9", "#E6B3FF", "#3E2723", "#78716C",
        "#212121", "#94A3B8", "#9CA3AF", "#A1A1AA", "#D4D4D8", "#E5E7EB"
    ]
    
    static let allIcons: [String] = [
        "star.fill", "heart.fill", "flame.fill", "book.fill", "figure.run", "drop.fill",
        "moon.fill", "sun.max.fill", "figure.walk", "bicycle", "cup.and.saucer.fill", "fork.knife",
        "leaf.fill", "cart.fill", "bag.fill", "creditcard.fill", "banknote.fill", "gift.fill",
        
        "house.fill", "bed.double.fill", "sofa.fill", "chair.lounge.fill", "tv.fill", "gamecontroller.fill",
        "headphones", "music.note", "mic.fill", "video.fill", "camera.fill", "photo.fill",
        "paintbrush.fill", "pencil", "highlighter", "scissors", "hammer.fill", "wrench.and.screwdriver.fill",
        
        "pills.fill", "cross.case.fill", "heart.text.square.fill", "bandage.fill", "brain.head.profile", "eye.fill",
        "lungs.fill", "figure.yoga", "figure.mind.and.body", "dumbell.fill", "sportscourt.fill", "soccerball",
        "basketball.fill", "tennis.racket", "volleyball.fill", "baseball.fill", "trophy.fill", "medal.fill",
        
        "car.fill", "bus.fill", "tram.fill", "airplane", "ferry.fill", "suitcase.fill",
        "map.fill", "globe.americas.fill", "tent.fill", "tree.fill", "mountain.2.fill", "pawprint.fill",
        "bird.fill", "fish.fill", "tortoise.fill", "ladybug.fill", "ant.fill", "leaf.arrow.triangle.circlepath"
    ]
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
