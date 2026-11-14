import AppKit
import ServiceManagement

final class Reminder: NSObject, NSApplicationDelegate, NSMenuItemValidation {
    private let playChimeKey = "playChime"
    private let loginConfiguredKey = "loginConfigured"

    private let chime = Bundle.main.url(forResource: "ReminderChime", withExtension: "wav")
        .flatMap { NSSound(contentsOf: $0, byReference: false) }

    private let canvasColor = NSColor(srgbRed: 0.07, green: 0.07, blue: 0.105, alpha: 1)
    private let titleColor = NSColor(srgbRed: 0.945, green: 0.932, blue: 0.903, alpha: 1)
    private let captionColor = NSColor(srgbRed: 0.69, green: 0.65, blue: 0.79, alpha: 1)

    private var panel: ReminderPanel?
    private var statusItem: NSStatusItem?
    private var clockTimer: Timer?
    private var isLocked = false
    private var needsReminder = true

    func applicationDidFinishLaunching(_ notification: Notification) {
        UserDefaults.standard.register(defaults: [playChimeKey: true])
        chime?.volume = 0.65

        configureLogin()
        addStatusMenu()
        observeSession()
        returnedToMac()
    }

    private func observeSession() {
        let workspace = NSWorkspace.shared.notificationCenter
        workspace.addObserver(self, selector: #selector(leftMac), name: NSWorkspace.willSleepNotification, object: nil)
        workspace.addObserver(self, selector: #selector(leftMac), name: NSWorkspace.screensDidSleepNotification, object: nil)

        workspace.addObserver(self, selector: #selector(returnedToMac), name: NSWorkspace.didWakeNotification, object: nil)
        workspace.addObserver(self, selector: #selector(returnedToMac), name: NSWorkspace.screensDidWakeNotification, object: nil)

        // macOS sends these distributed notifications separately from display sleep and wake.
        let session = DistributedNotificationCenter.default()
        session.addObserver(self, selector: #selector(locked), name: .init("com.apple.screenIsLocked"), object: nil)
        session.addObserver(self, selector: #selector(unlocked), name: .init("com.apple.screenIsUnlocked"), object: nil)
    }

    @objc private func locked() {
        isLocked = true
        leftMac()
    }

    @objc private func unlocked() {
        isLocked = false
        returnedToMac()
    }

    @objc private func leftMac() {
        needsReminder = true
        dismiss()
    }

    @objc private func returnedToMac() {
        // Wait briefly for the display and menu bar to return from sleep.
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) { [weak self] in
            guard let self, self.needsReminder, !self.isLocked else { return }

            self.showReminder()
        }
    }

    @objc private func showReminder() {
        guard let screen = NSScreen.main, panel == nil else { return }

        let window = ReminderPanel(
            contentRect: screen.visibleFrame,
            styleMask: [.borderless, .nonactivatingPanel],
            backing: .buffered,
            defer: false
        )

        window.level = .floating
        window.hidesOnDeactivate = false
        window.collectionBehavior = [.canJoinAllSpaces, .fullScreenAuxiliary, .ignoresCycle]

        window.isReleasedWhenClosed = false
        window.backgroundColor = canvasColor
        window.contentView = reminderView(size: screen.visibleFrame.size)

        panel = window
        needsReminder = false
        window.orderFrontRegardless()

        if UserDefaults.standard.bool(forKey: playChimeKey) {
            chime?.play()
        }
    }

    private func reminderView(size: NSSize) -> NSView {
        let view = NSView()
        let clock = clockView()
        let fontSize = min(size.width * 0.088, size.height * 0.15)

        let font = NSFont(name: "AvenirNext-Heavy", size: fontSize) ?? .systemFont(ofSize: fontSize, weight: .black)
        let firstLine = titleLine("Add a", font: font)
        let entryLine = titleLine("TimeCamp entry", font: font)

        let subtitle = NSTextField(labelWithString: "Before your hours ghost you.")
        subtitle.font = .systemFont(ofSize: max(16, fontSize * 0.30), weight: .bold)
        subtitle.textColor = captionColor

        let done = doneButton(height: max(44, fontSize * 0.63))
        for item in [clock, firstLine, subtitle, done] {
            item.translatesAutoresizingMaskIntoConstraints = false
            view.addSubview(item)
            item.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        }

        entryLine.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(entryLine)
        centerEntry(entryLine, in: view, stickerSize: fontSize * 1.26)

        NSLayoutConstraint.activate([
            clock.topAnchor.constraint(equalTo: view.topAnchor, constant: min(40, size.height * 0.05)),
            firstLine.firstBaselineAnchor.constraint(equalTo: view.centerYAnchor, constant: -size.height * 0.065),
            entryLine.firstBaselineAnchor.constraint(equalTo: firstLine.firstBaselineAnchor, constant: fontSize * 0.92),
            subtitle.firstBaselineAnchor.constraint(equalTo: entryLine.firstBaselineAnchor, constant: fontSize * 0.65),
            done.topAnchor.constraint(equalTo: subtitle.firstBaselineAnchor, constant: fontSize * 0.48)
        ])

        return view
    }

    private func clockView() -> NSStackView {
        let date = NSTextField(labelWithString: "")
        date.font = .systemFont(ofSize: 20, weight: .semibold)
        date.textColor = NSColor(white: 0.64, alpha: 1)

        let time = NSTextField(labelWithString: "")
        time.font = .monospacedDigitSystemFont(ofSize: 56, weight: .medium)
        time.textColor = date.textColor

        let updateClock = { [weak date, weak time] (now: Date) in
            date?.stringValue = now.formatted(.dateTime.weekday(.wide).month(.wide).day())
            time?.stringValue = now.formatted(.dateTime.hour(.defaultDigits(amPM: .omitted)).minute(.twoDigits))
        }

        let now = Date()
        updateClock(now)

        let nextMinute = Calendar.current.dateInterval(of: .minute, for: now)?.end ?? now.addingTimeInterval(60)
        let timer = Timer(fire: nextMinute, interval: 60, repeats: true) { _ in
            updateClock(Date())
        }

        RunLoop.main.add(timer, forMode: .common)
        clockTimer = timer

        let clock = NSStackView(views: [date, time])
        clock.orientation = .vertical
        clock.alignment = .centerX

        clock.spacing = 0
        clock.translatesAutoresizingMaskIntoConstraints = false

        return clock
    }

    private func titleLine(_ text: String, font: NSFont) -> NSTextField {
        let title = NSTextField(labelWithString: text)

        title.attributedStringValue = NSAttributedString(string: text, attributes: [
            .font: font,
            .foregroundColor: titleColor,
            .kern: -font.pointSize * 0.012
        ])

        let width = ceil(title.attributedStringValue.size().width) + 4
        title.widthAnchor.constraint(equalToConstant: width).isActive = true

        return title
    }

    private func doneButton(height: CGFloat) -> NSButton {
        let button = DoneButton(frame: .zero)
        button.target = self
        button.action = #selector(dismiss)

        button.title = "Done"
        button.isBordered = false
        button.attributedTitle = NSAttributedString(string: "Done", attributes: [
            .font: NSFont.systemFont(ofSize: height * 0.45, weight: .bold),
            .foregroundColor: canvasColor
        ])

        button.restingColor = titleColor
        button.hoverColor = NSColor(srgbRed: 0.89, green: 0.83, blue: 0.98, alpha: 1)
        button.wantsLayer = true

        button.layer?.backgroundColor = button.restingColor.cgColor
        button.layer?.cornerRadius = height / 2

        NSLayoutConstraint.activate([
            button.widthAnchor.constraint(equalToConstant: height * 3.1),
            button.heightAnchor.constraint(equalToConstant: height)
        ])

        return button
    }

    private func centerEntry(_ title: NSTextField, in view: NSView, stickerSize: CGFloat) {
        guard let url = Bundle.main.url(forResource: "Ghost", withExtension: "png"),
              let image = NSImage(contentsOf: url) else {
            title.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
            return
        }

        let ghost = NSImageView(image: image)
        ghost.setAccessibilityElement(false)
        ghost.translatesAutoresizingMaskIntoConstraints = false

        view.addSubview(ghost)
        let overlap = stickerSize * 0.16
        let extensionWidth = stickerSize - overlap

        NSLayoutConstraint.activate([
            title.centerXAnchor.constraint(equalTo: view.centerXAnchor, constant: -extensionWidth / 2),
            ghost.leadingAnchor.constraint(equalTo: title.trailingAnchor, constant: -overlap),
            ghost.centerYAnchor.constraint(equalTo: title.centerYAnchor, constant: -stickerSize * 0.10),
            ghost.widthAnchor.constraint(equalToConstant: stickerSize),
            ghost.heightAnchor.constraint(equalTo: ghost.widthAnchor)
        ])

        guard !NSWorkspace.shared.accessibilityDisplayShouldReduceMotion else { return }

        ghost.wantsLayer = true
        let wiggle = CAKeyframeAnimation(keyPath: "transform.rotation.z")
        wiggle.values = [0, -0.09, 0.07, -0.035, 0]
        wiggle.duration = 0.42
        ghost.layer?.add(wiggle, forKey: "wiggle")
    }

    @objc private func dismiss() {
        clockTimer?.invalidate()
        clockTimer = nil

        panel?.orderOut(nil)
        panel = nil
    }

    private func addStatusMenu() {
        let item = NSStatusBar.system.statusItem(withLength: NSStatusItem.squareLength)
        item.button?.image = NSImage(systemSymbolName: "clock.badge.exclamationmark", accessibilityDescription: "TimeCamp Reminder")
        item.button?.toolTip = "TimeCamp Reminder"

        let menu = NSMenu()
        menu.addItem(withTitle: "Show Reminder", action: #selector(showReminder), keyEquivalent: "").target = self

        let sound = menu.addItem(withTitle: "Play Chime", action: #selector(toggleChime(_:)), keyEquivalent: "")
        sound.target = self
        sound.state = UserDefaults.standard.bool(forKey: playChimeKey) ? .on : .off

        let login = menu.addItem(withTitle: "Launch at Login", action: #selector(toggleLogin(_:)), keyEquivalent: "")
        login.target = self
        login.state = SMAppService.mainApp.status == .enabled ? .on : .off

        menu.addItem(.separator())
        menu.addItem(withTitle: "Quit TimeCamp Reminder", action: #selector(NSApplication.terminate(_:)), keyEquivalent: "q")

        item.menu = menu
        statusItem = item
    }

    @objc private func toggleChime(_ item: NSMenuItem) {
        let enabled = !UserDefaults.standard.bool(forKey: playChimeKey)
        UserDefaults.standard.set(enabled, forKey: playChimeKey)
        item.state = enabled ? .on : .off
    }

    private func configureLogin() {
        let defaults = UserDefaults.standard
        guard !defaults.bool(forKey: loginConfiguredKey) else { return }

        let login = SMAppService.mainApp
        defaults.set(true, forKey: loginConfiguredKey)
        guard login.status != .enabled, login.status != .requiresApproval else { return }

        do {
            try login.register()
        } catch {
            NSLog("Could not register TimeCamp Reminder at login: %@", error.localizedDescription)
        }
    }

    func validateMenuItem(_ item: NSMenuItem) -> Bool {
        if item.action == #selector(toggleLogin(_:)) {
            item.state = SMAppService.mainApp.status == .enabled ? .on : .off
        }

        return true
    }

    @objc private func toggleLogin(_ item: NSMenuItem) {
        let login = SMAppService.mainApp

        do {
            if login.status == .enabled {
                try login.unregister()
            } else {
                try login.register()
            }
        } catch {
            if login.status != .requiresApproval {
                let alert = NSAlert(error: error)
                alert.runModal()
            }
        }

        item.state = login.status == .enabled ? .on : .off

        if login.status == .requiresApproval {
            SMAppService.openSystemSettingsLoginItems()
        }
    }
}
