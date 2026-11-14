import AppKit

let app = NSApplication.shared
let reminder = Reminder()
app.delegate = reminder

app.run()
