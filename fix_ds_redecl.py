import re

with open('Sources/DesignSystem.swift', 'r') as f:
    content = f.read()

bad_code = """import UIKit

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
}"""
content = content.replace(bad_code, "", 1) # remove first occurence only

with open('Sources/DesignSystem.swift', 'w') as f:
    f.write(content)
