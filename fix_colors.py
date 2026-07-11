import os

files_to_check = []
for root, _, files in os.walk('Sources'):
    for f in files:
        if f.endswith('.swift'):
            files_to_check.append(os.path.join(root, f))

for filepath in files_to_check:
    with open(filepath, 'r') as f:
        content = f.read()
    
    content = content.replace("Color.white.opacity(0.8)", "DS.surface.opacity(0.8)")
    content = content.replace("Color.white.opacity(0.9)", "DS.surface.opacity(0.9)")
    content = content.replace("Color.white.opacity(0.7)", "DS.surface.opacity(0.7)")
    content = content.replace("Color.white.opacity(0.6)", "DS.surface.opacity(0.6)")
    content = content.replace(".background(Color.white)", ".background(DS.surface)")
    content = content.replace(".fill(Color.white)", ".fill(DS.surface)")
    
    content = content.replace("Color.white : Color.clear", "DS.surface : Color.clear")
    content = content.replace("Color.white.ignoresSafeArea()", "DS.bgPrimary.ignoresSafeArea()")
    content = content.replace('Color(hex: "#F5F5F5") : Color.white', 'Color(hex: "#F5F5F5") : DS.surface')
    
    with open(filepath, 'w') as f:
        f.write(content)

