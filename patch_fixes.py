import re

with open('Sources/AmountCheckinSheet.swift', 'r') as f:
    amount_content = f.read()

# Fix AmountCheckinSheet TextField layout and add dismiss
amount_content = amount_content.replace(
    'TextField("0", text: $amountString)',
    '@Environment(\\.dismiss) private var dismiss\n    TextField("0", text: $amountString)'
)

# Put the dismiss environment var at the top
amount_content = re.sub(r'(@FocusState private var isFocused: Bool)', r'@Environment(\\.dismiss) private var dismiss\n    \1', amount_content)
# Clean up duplicate dismiss if I made a mistake
amount_content = amount_content.replace('@Environment(\\.dismiss) private var dismiss\n    @Environment(\\.dismiss) private var dismiss', '@Environment(\\.dismiss) private var dismiss')

old_textfield = """                    TextField("0", text: $amountString)
                        .focused($isFocused)
                        .keyboardType(.decimalPad)
                        .font(.system(size: 56, weight: .heavy, design: .rounded))
                        .foregroundColor(Color(hex: habit.color))
                        .multilineTextAlignment(.center)
                        .frame(minWidth: 100)"""

new_textfield = """                    TextField("0", text: $amountString)
                        .focused($isFocused)
                        .keyboardType(.decimalPad)
                        .font(.system(size: 56, weight: .heavy, design: .rounded))
                        .foregroundColor(Color(hex: habit.color))
                        .multilineTextAlignment(.center)
                        .fixedSize(horizontal: true, vertical: false)
                        .frame(minWidth: 40)"""

amount_content = amount_content.replace(old_textfield, new_textfield)

old_submit = """            } else {
                let newCheckin = Checkin(dateString: dateString, amount: val)
                newCheckin.habit = habit
                modelContext.insert(newCheckin)
            }
            isFocused = false
            onComplete()"""

new_submit = """            } else {
                let newCheckin = Checkin(dateString: dateString, amount: val)
                newCheckin.habit = habit
                modelContext.insert(newCheckin)
            }
            try? modelContext.save()
            isFocused = false
            onComplete()
            dismiss()"""

amount_content = amount_content.replace(old_submit, new_submit)

with open('Sources/AmountCheckinSheet.swift', 'w') as f:
    f.write(amount_content)


# HabitListView drag and drop opacity removal
with open('Sources/HabitListView.swift', 'r') as f:
    list_content = f.read()

list_content = list_content.replace('.opacity(draggedHabit?.id == habit.id ? 0.01 : 1.0)', '')

with open('Sources/HabitListView.swift', 'w') as f:
    f.write(list_content)
