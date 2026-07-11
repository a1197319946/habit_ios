import re

with open('Sources/LittleHabitWidget/LittleHabitWidget.swift', 'r') as f:
    code = f.read()

old_intent = """                let fillAmount = targetHabit.goalType == "amount" ? targetHabit.amountValue : 1
                if targetHabit.frequencyType == "weekly" || targetHabit.frequencyType == "monthly" {
                    if let existing = todays.first { existing.amount += 1; existing.timestamp = today }
                    else { let newCheckin = Checkin(dateString: dateString, amount: 1); modelContainer.mainContext.insert(newCheckin); newCheckin.habit = targetHabit }
                } else {
                    let totalAmount = todays.reduce(0, { $0 + $1.amount })
                    if totalAmount > 0 {
                        // Undo: Delete all checkin records for today to cleanly undo
                        todays.forEach { modelContainer.mainContext.delete($0) }
                    } else {
                        // Checkin
                        let newCheckin = Checkin(dateString: dateString, amount: fillAmount)
                        modelContainer.mainContext.insert(newCheckin)
                        newCheckin.habit = targetHabit
                        newCheckin.timestamp = today
                    }
                }"""

new_intent = """                let fillAmount = targetHabit.goalType == "amount" ? targetHabit.amountValue : 1
                let totalAmount = todays.reduce(0, { $0 + $1.amount })
                if totalAmount > 0 {
                    // Undo: Delete all checkin records for today to cleanly undo
                    todays.forEach { modelContainer.mainContext.delete($0) }
                } else {
                    // Checkin
                    let newCheckin = Checkin(dateString: dateString, amount: fillAmount)
                    modelContainer.mainContext.insert(newCheckin)
                    newCheckin.habit = targetHabit
                    newCheckin.timestamp = today
                }"""

code = code.replace(old_intent, new_intent)

with open('Sources/LittleHabitWidget/LittleHabitWidget.swift', 'w') as f:
    f.write(code)
