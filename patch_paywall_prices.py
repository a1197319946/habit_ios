import re

with open('Sources/PaywallView.swift', 'r') as f:
    code = f.read()

code = code.replace('price: "¥1"', 'price: "¥1.9"')
code = code.replace('price: "¥6"', 'price: "¥6.9"')
code = code.replace('price: "¥36"', 'price: "¥39.9"')

with open('Sources/PaywallView.swift', 'w') as f:
    f.write(code)
