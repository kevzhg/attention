import SwiftUI
import Combine

@MainActor
class FocusSessionViewModel: ObservableObject {
    @Published var sessionState: SessionState = .idle
    @Published var sessionDuration: Int = 25  // minutes
    @Published var clearDesktop: Bool = true
    @Published var selectedAppBundleIdentifier: String = ""
    @Published var startMusic: Bool = false
    @Published var musicSource: MusicSource = .appleMusic
    @Published var showStarterTask: Bool = true
    @Published var installedApps: [InstalledApp] = []

    private var timer: Timer?
    private var sessionStartTime: Date?
    private var sessionConfiguration: FocusSessionConfiguration?

    // Services
    private let appService = AppService()
    private let desktopService = DesktopService()
    private let musicService = MusicService()

    func loadInstalledApps() {
        installedApps = appService.getInstalledApplications()
    }

    func startSession() {
        let configuration = FocusSessionConfiguration(
            duration: TimeInterval(sessionDuration * 60),
            clearDesktop: clearDesktop,
            appToOpen: selectedAppBundleIdentifier.isEmpty ? nil : selectedAppBundleIdentifier,
            startMusic: startMusic,
            musicSource: musicSource,
            showStarterTask: showStarterTask,
            starterTaskPrompt: ""
        )
        sessionConfiguration = configuration

        // Execute pre-session tasks
        Task {
            await executeSessionStart(configuration: configuration)
        }

        sessionStartTime = Date()
        sessionState = .running(configuration.duration)
        startTimer()
    }

    private func executeSessionStart(configuration: FocusSessionConfiguration) async {
        // Clear desktop if requested
        if configuration.clearDesktop {
            desktopService.clearDesktop()
        }

        // Open specified app
        if let appBundle = configuration.appToOpen {
            appService.openApplication(bundleIdentifier: appBundle)
        }

        // Start music if requested
        if configuration.startMusic {
            musicService.startMusic(source: configuration.musicSource)
        }

        // Show starter task prompt if requested
        if configuration.showStarterTask {
            showStarterTaskPrompt()
        }
    }

    private func showStarterTaskPrompt() {
        let alert = NSAlert()
        alert.messageText = "Ready to focus?"
        alert.informativeText = "What's one small task you'll start with?"
        alert.addButton(withTitle: "Start Focusing")
        alert.addButton(withTitle: "Cancel")

        let textField = NSTextField(frame: NSRect(x: 0, y: 0, width: 300, height: 24))
        textField.placeholderString = "e.g., Read the first paragraph"
        alert.accessoryView = textField

        alert.window.initialFirstResponder = textField

        let response = alert.runModal()
        if response == .alertFirstButton {
            // User entered a task and confirmed
            print("Task: \(textField.stringValue)")
        }
    }

    private func startTimer() {
        timer?.invalidate()
        timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { [weak self] _ in
            Task { @MainActor in
                self?.tick()
            }
        }
    }

    private func tick() {
        guard case .running(let remaining) = sessionState else { return }

        let newRemaining = remaining - 1

        if newRemaining <= 0 {
            endSession(completed: true)
        } else {
            sessionState = .running(newRemaining)
        }
    }

    func togglePause() {
        if case .running(let remaining) = sessionState {
            sessionState = .paused(remaining)
            timer?.invalidate()
        } else if case .paused(let remaining) = sessionState {
            sessionState = .running(remaining)
            startTimer()
        }
    }

    func endSession(completed: Bool = false) {
        timer?.invalidate()
        timer = nil

        if completed {
            sessionState = .completed
            showCompletionAlert()
        } else {
            sessionState = .idle
        }

        sessionStartTime = nil
        sessionConfiguration = nil
    }

    private func showCompletionAlert() {
        let alert = NSAlert()
        alert.messageText = "Focus Session Complete!"
        alert.informativeText = "Great job. Take a break or start another session?"
        alert.addButton(withTitle: "Start Break")
        alert.addButton(withTitle: "Close")
        alert.alertStyle = .informational

        let response = alert.runModal()
        if response == .alertFirstButton {
            // Could implement break timer here
            sessionState = .idle
        }
    }

    func timeString(from seconds: TimeInterval) -> String {
        let minutes = Int(seconds) / 60
        let secs = Int(seconds) % 60
        return String(format: "%02d:%02d", minutes, secs)
    }
}
