import Foundation

enum SessionState: Equatable {
    case idle
    case running(TimeInterval)  // remaining seconds
    case paused(TimeInterval)   // remaining seconds
    case completed

    var isRunning: Bool {
        if case .running = self { return true }
        return false
    }

    var isPaused: Bool {
        if case .paused = self { return true }
        return false
    }

    var statusText: String {
        switch self {
        case .idle: return "Ready to focus"
        case .running: return "Focus session in progress"
        case .paused: return "Session paused"
        case .completed: return "Session complete!"
        }
    }
}

enum MusicSource: Int, CaseIterable {
    case appleMusic = 0
    case spotify = 1
    case other = 2
}

struct FocusSessionConfiguration: Codable {
    var duration: TimeInterval  // in seconds
    var clearDesktop: Bool
    var appToOpen: String?  // bundle identifier
    var startMusic: Bool
    var musicSource: MusicSource
    var showStarterTask: Bool
    var starterTaskPrompt: String

    static let `default` = FocusSessionConfiguration(
        duration: 25 * 60,  // 25 minutes (Pomodoro)
        clearDesktop: true,
        appToOpen: nil,
        startMusic: false,
        musicSource: .appleMusic,
        showStarterTask: true,
        starterTaskPrompt: "What's the first small task you'll do?"
    )
}

struct InstalledApp: Identifiable, Equatable {
    let id = UUID()
    let name: String
    let bundleIdentifier: String
    let path: URL
}

struct FocusSession: Identifiable, Codable {
    let id = UUID()
    let startTime: Date
    var endTime: Date?
    var plannedDuration: TimeInterval
    var actualDuration: TimeInterval? {
        guard let end = endTime else { return nil }
        return end.timeIntervalSince(startTime)
    }
    var completed: Bool {
        endTime != nil
    }
}
