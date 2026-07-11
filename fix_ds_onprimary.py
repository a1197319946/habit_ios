import re

with open('Sources/DesignSystem.swift', 'r') as f:
    ds = f.read()

ds = ds.replace('static var primary: Color', 'static let onPrimary = Color.white\n    static var primary: Color')

with open('Sources/DesignSystem.swift', 'w') as f:
    f.write(ds)
