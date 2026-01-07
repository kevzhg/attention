import Foundation
import Cocoa

/// Handles desktop operations like clearing icons
struct DesktopService {
    /// Returns the path to the user's desktop
    private var desktopPath: String {
        return NSSearchPathForDirectoriesInDomains(.desktopDirectory, .userDomainMask, true).first ?? ""
    }

    /// Moves all desktop items to a hidden folder
    func clearDesktop() {
        let desktopURL = URL(fileURLWithPath: desktopPath)
        let hiddenFolderName = ".Desktop_Cleared_\(ISO8601DateFormatter().string(from: Date()))"
        let hiddenFolderURL = desktopURL.appendingPathComponent(hiddenFolderName)

        do {
            try FileManager.default.createDirectory(at: hiddenFolderURL, withIntermediateDirectories: true)

            let contents = try FileManager.default.contentsOfDirectory(
                at: desktopURL,
                includingPropertiesForKeys: nil,
                options: [.skipsHiddenFiles]
            )

            for item in contents {
                // Skip the hidden folder we just created
                if item.lastPathComponent.hasPrefix(".") { continue }

                let destination = hiddenFolderURL.appendingPathComponent(item.lastPathComponent)
                try FileManager.default.moveItem(at: item, to: destination)
            }
        } catch {
            print("Failed to clear desktop: \(error)")
        }
    }

    /// Restores desktop items from a previously cleared session
    func restoreDesktop(from folderName: String) {
        let desktopURL = URL(fileURLWithPath: desktopPath)
        let hiddenFolderURL = desktopURL.appendingPathComponent(folderName)

        do {
            let contents = try FileManager.default.contentsOfDirectory(
                at: hiddenFolderURL,
                includingPropertiesForKeys: nil
            )

            for item in contents {
                let destination = desktopURL.appendingPathComponent(item.lastPathComponent)
                try FileManager.default.moveItem(at: item, to: destination)
            }

            // Remove the now-empty hidden folder
            try FileManager.default.removeItem(at: hiddenFolderURL)
        } catch {
            print("Failed to restore desktop: \(error)")
        }
    }

    /// Returns a list of all desktop items
    func getDesktopItems() -> [URL] {
        let desktopURL = URL(fileURLWithPath: desktopPath)
        do {
            return try FileManager.default.contentsOfDirectory(
                at: desktopURL,
                includingPropertiesForKeys: nil,
                options: [.skipsHiddenFiles]
            )
        } catch {
            return []
        }
    }
}
