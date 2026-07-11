import re

with open('Sources/HabitMonthDetailView.swift', 'r') as f:
    code = f.read()

# Add UIKit
if 'import UIKit' not in code:
    code = code.replace('import SwiftUI', 'import SwiftUI\nimport UIKit')

# Change state variable
code = code.replace('@State private var selectedFullscreenImage: UIImage? = nil', '@State private var selectedImageForFullscreen: IdentifiableImage? = nil')

# Change button action
old_button = """                            Button(action: {
                                selectedFullscreenImage = uiImage
                            })"""
new_button = """                            Button(action: {
                                selectedImageForFullscreen = IdentifiableImage(image: uiImage)
                            })"""
code = code.replace(old_button, new_button)

# Change fullScreenCover
old_cover = """        .fullScreenCover(item: Binding(
            get: { selectedFullscreenImage.map { IdentifiableImage(image: $0) } },
            set: { if $0 == nil { selectedFullscreenImage = nil } }
        )) { identImg in
            FullscreenImageView(image: identImg.image) {
                selectedFullscreenImage = nil
            }
        }"""
new_cover = """        .fullScreenCover(item: $selectedImageForFullscreen) { identImg in
            FullscreenImageView(image: identImg.image) {
                selectedImageForFullscreen = nil
            }
        }"""
code = code.replace(old_cover, new_cover)

with open('Sources/HabitMonthDetailView.swift', 'w') as f:
    f.write(code)

