import Foundation

/// Manages persistence and retrieval of past focus sessions
actor SessionHistory {
    private let saveURL: URL

    init() {
        let documentsPath = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0]
        let appFolder = URL(fileURLWithPath: documentsPath).appendingPathComponent("Attention")
        saveURL = appFolder.appendingPathComponent("sessions.json")

        // Create directory if it doesn't exist
        try? FileManager.default.createDirectory(at: appFolder, withIntermediateDirectories: true)
    }

    /// Saves a completed session
    func saveSession(_ session: FocusSession) async throws {
        var sessions = try await loadAllSessions()
        sessions.append(session)
        try saveSessions(sessions)
    }

    /// Loads all saved sessions
    func loadAllSessions() async throws -> [FocusSession] {
        guard let data = try? Data(contentsOf: saveURL) else {
            return []
        }
        return try JSONDecoder().decode([FocusSession].self, from: data)
    }

    /// Returns sessions from the current day
    func getTodaySessions() async throws -> [FocusSession] {
        let sessions = try await loadAllSessions()
        let today = Calendar.current.startOfDay(for: Date())
        return sessions.filter { $0.startTime >= today }
    }

    /// Returns sessions from the current week
    func getWeekSessions() async throws -> [FocusSession] {
        let sessions = try await loadAllSessions()
        let weekAgo = Calendar.current.date(byAdding: .day, value: -7, to: Date()) ?? Date()
        return sessions.filter { $0.startTime >= weekAgo }
    }

    /// Calculates total focus time for a given set of sessions
    func totalFocusTime(for sessions: [FocusSession]) -> TimeInterval {
        sessions.compactMap { $0.actualDuration }.reduce(0, +)
    }

    private func saveSessions(_ sessions: [FocusSession]) throws {
        let data = try JSONEncoder().encode(sessions)
        try data.write(to: saveURL)
    }
}
