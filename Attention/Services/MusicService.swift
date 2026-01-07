import Foundation
import Cocoa

/// Represents music sources that can be controlled
enum MusicApp: String {
    case music = "com.apple.Music"
    case spotify = "com.spotify.client"
}

/// Handles starting and controlling music playback
struct MusicService {
    /// Starts playing music from the specified source
    func startMusic(source: MusicSource) {
        let bundleId: String

        switch source {
        case .appleMusic:
            bundleId = MusicApp.music.rawValue
        case .spotify:
            bundleId = MusicApp.spotify.rawValue
        case .other:
            // For "other", we'll need to let the user configure this
            // For now, just open Apple Music as a fallback
            bundleId = MusicApp.music.rawValue
        }

        playMusic(bundleIdentifier: bundleId)
    }

    private func playMusic(bundleIdentifier: String) {
        let workspace = NSWorkspace.shared

        // First, try to launch the app
        guard let appURL = workspace.urlForApplication(withBundleIdentifier: bundleIdentifier) else {
            print("Could not find app with bundle identifier: \(bundleIdentifier)")
            return
        }

        workspace.open(appURL) { runningApp, error in
            if let error = error {
                print("Failed to open music app: \(error)")
                return
            }

            // Wait a moment for the app to launch, then send play command
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                self.sendPlayCommand()
            }
        }
    }

    /// Sends a "play" command via AppleScript or media key
    private func sendPlayCommand() {
        // Using NSAppleScript to send "play" command
        // This works with Apple Music and other media players that support AppleScript
        let script = """
        tell application "System Events"
            key code 52 using {command down}
        end tell
        """

        var error: NSDictionary?
        if let scriptObject = NSAppleScript(source: script) {
            scriptObject.executeAndReturnError(&error)
            if let error = error {
                print("AppleScript error: \(error)")
            }
        }

        // Alternative: Try direct Apple Music play command
        let musicScript = """
        tell application "Music"
            play
        end tell
        """

        if let musicScriptObject = NSAppleScript(source: musicScript) {
            musicScriptObject.executeAndReturnError(&error)
        }
    }

    /// Pauses the current music playback
    func pauseMusic() {
        let script = """
        tell application "System Events"
            key code 52 using {command down}
        end tell
        """

        var error: NSDictionary?
        if let scriptObject = NSAppleScript(source: script) {
            scriptObject.executeAndReturnError(&error)
        }
    }

    /// Checks if a music app is currently running
    func isMusicAppRunning(source: MusicSource) -> Bool {
        let bundleId: String

        switch source {
        case .appleMusic:
            bundleId = MusicApp.music.rawValue
        case .spotify:
            bundleId = MusicApp.spotify.rawValue
        case .other:
            return false
        }

        return NSRunningApplication.runningApplications(withBundleIdentifier: bundleId).first != nil
    }
}
