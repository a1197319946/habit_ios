import re

with open('Sources/HabitMonthDetailView.swift', 'r') as f:
    code = f.read()

# 1. Add state var
code = code.replace('@State private var year: Int', '@State private var selectedFullscreenImage: UIImage? = nil\n    @State private var year: Int')

# 2. Add fullScreenCover
cover_str = """        .onChange(of: currentMonthDate) { _, newValue in
            year = calendar.component(.year, from: newValue)
            month = calendar.component(.month, from: newValue)
        }
        .fullScreenCover(item: Binding(
            get: { selectedFullscreenImage.map { IdentifiableImage(image: $0) } },
            set: { if $0 == nil { selectedFullscreenImage = nil } }
        )) { identImg in
            FullscreenImageView(image: identImg.image) {
                selectedFullscreenImage = nil
            }
        }"""
code = code.replace("""        .onChange(of: currentMonthDate) { _, newValue in
            year = calendar.component(.year, from: newValue)
            month = calendar.component(.month, from: newValue)
        }""", cover_str)


# 3. Change image display
old_mood = """                        if let imageData = mood.imageData, let uiImage = UIImage(data: imageData) {
                            Image(uiImage: uiImage)
                                .resizable()
                                .scaledToFill()
                                .frame(height: 120)
                                .frame(maxWidth: .infinity)
                                .clipShape(RoundedRectangle(cornerRadius: 8))
                                .padding(.top, 4)
                        }"""

new_mood = """                        Spacer(minLength: 8)
                        if let imageData = mood.imageData, let uiImage = UIImage(data: imageData) {
                            Button(action: {
                                selectedFullscreenImage = uiImage
                            }) {
                                Image(uiImage: uiImage)
                                    .resizable()
                                    .scaledToFill()
                                    .frame(width: 48, height: 48)
                                    .clipShape(RoundedRectangle(cornerRadius: 8))
                                    .shadow(color: Color.black.opacity(0.1), radius: 2)
                            }
                            .buttonStyle(PlainButtonStyle())
                        }"""
code = code.replace(old_mood, new_mood)
code = code.replace('                            Spacer()\n                        }\n                        \n                        Spacer(minLength: 8)', '                        }\n                        \n                        Spacer(minLength: 8)')

# Add missing struct at the bottom
structs = """
struct IdentifiableImage: Identifiable {
    let id = UUID()
    let image: UIImage
}

struct FullscreenImageView: View {
    let image: UIImage
    let onDismiss: () -> Void
    @State private var showingSaveAlert = false
    @State private var scale: CGFloat = 1.0
    @State private var lastScale: CGFloat = 1.0

    var body: some View {
        ZStack {
            Color.black.ignoresSafeArea()
            
            Image(uiImage: image)
                .resizable()
                .scaledToFit()
                .scaleEffect(scale)
                .gesture(
                    MagnificationGesture()
                        .onChanged { val in
                            scale = lastScale * val
                        }
                        .onEnded { val in
                            lastScale = scale
                        }
                )
                .onTapGesture(count: 2) {
                    withAnimation {
                        scale = scale > 1 ? 1.0 : 2.0
                        lastScale = scale
                    }
                }
            
            VStack {
                HStack {
                    Button(action: onDismiss) {
                        Image(systemName: "xmark")
                            .font(.system(size: 20, weight: .bold))
                            .foregroundColor(.white)
                            .padding(16)
                            .background(Color.black.opacity(0.5))
                            .clipShape(Circle())
                    }
                    Spacer()
                    Button(action: {
                        UIImageWriteToSavedPhotosAlbum(image, nil, nil, nil)
                        showingSaveAlert = true
                    }) {
                        Image(systemName: "square.and.arrow.down")
                            .font(.system(size: 20, weight: .bold))
                            .foregroundColor(.white)
                            .padding(16)
                            .background(Color.black.opacity(0.5))
                            .clipShape(Circle())
                    }
                }
                .padding()
                Spacer()
            }
        }
        .alert("已保存到相册", isPresented: $showingSaveAlert) {
            Button("好的", role: .cancel) { }
        }
    }
}
"""
code = code + structs

with open('Sources/HabitMonthDetailView.swift', 'w') as f:
    f.write(code)

