files = ['Sources/AmountCheckinSheet.swift', 'Sources/CheckinSuccessView.swift']
for filepath in files:
    with open(filepath, 'r') as f:
        content = f.read()
    
    # AmountCheckinSheet uses `let calendar = Calendar.current`
    new_calendar = """        var calendar = Calendar.current
        calendar.firstWeekday = UserDefaults.standard.integer(forKey: "firstWeekday") == 0 ? 2 : UserDefaults.standard.integer(forKey: "firstWeekday")"""
    content = content.replace("let calendar = Calendar.current", new_calendar)
    # CheckinSuccessView uses `Calendar.current.component`
    content = content.replace("Calendar.current.component", "Calendar.current.component") # Oh wait, we don't care about week start for `.day` or `.month` component!
    
    with open(filepath, 'w') as f:
        f.write(content)
