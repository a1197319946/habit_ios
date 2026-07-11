import re

with open('Sources/HabitMonthDetailView.swift', 'r') as f:
    code = f.read()

code = code.replace('@State var year: Int', '@State private var selectedFullscreenImage: UIImage? = nil\n    @State var year: Int')

with open('Sources/HabitMonthDetailView.swift', 'w') as f:
    f.write(code)

