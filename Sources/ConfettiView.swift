import SwiftUI

struct ConfettiView: View {
    @State private var animate = false
    let colors: [Color] = [DS.primary, DS.secondary, Color(hex: "#F7C59F"), Color(hex: "#5B8A6E"), Color(hex: "#E8845C")]
    
    var body: some View {
        GeometryReader { geometry in
            ZStack {
                ForEach(0..<40, id: \.self) { i in
                    ConfettiParticle(
                        color: colors.randomElement()!,
                        animate: $animate,
                        screenSize: geometry.size
                    )
                }
            }
        }
        .allowsHitTesting(false)
        .onAppear { animate = true }
    }
}

struct ConfettiParticle: View {
    let color: Color
    @Binding var animate: Bool
    let screenSize: CGSize
    
    @State private var xOffset: CGFloat = 0
    @State private var yOffset: CGFloat = 0
    @State private var rotation: Double = 0
    
    let startX = CGFloat.random(in: 0.2...0.8)
    
    var body: some View {
        RoundedRectangle(cornerRadius: 2)
            .fill(color)
            .frame(width: CGFloat.random(in: 6...10), height: CGFloat.random(in: 6...10))
            .position(x: screenSize.width * startX, y: screenSize.height * 0.4)
            .offset(x: xOffset, y: yOffset)
            .rotationEffect(.degrees(rotation))
            .opacity(animate ? 0 : 1)
            .onAppear {
                withAnimation(.easeOut(duration: Double.random(in: 1.2...2.0))) {
                    xOffset = CGFloat.random(in: -180...180)
                    yOffset = CGFloat.random(in: -280...280)
                    rotation = Double.random(in: 360...1080)
                }
            }
    }
}
