import Foundation
import Cocoa

/// Handles interactions with installed applications
struct AppService {
    /// Returns a list of installed applications that can be launched
    func getInstalledApplications() -> [InstalledApp] {
        var apps: [InstalledApp] = []

        let applicationDirectories = [
            "/Applications",
            "/System/Applications",
            "\(NSHomeDirectory())/Applications"
        ]

        for directory in applicationDirectories {
            guard let appURLs = try? FileManager.default.contentsOfDirectory(
                at: URL(fileURLWithPath: directory),
                includingPropertiesForKeys: nil,
                options: [.skipsHiddenFiles]
            ) else { continue }

            for appURL in appURLs where appURL.pathExtension == "app" {
                if let bundle = Bundle(url: appURL),
                   let bundleName = bundle.object(forInfoDictionaryKey: "CFBundleName") as? String ??
                                   bundle.object(forInfoDictionaryKey: "CFBundleDisplayName") as? String,
                   let bundleIdentifier = bundle.bundleIdentifier {

                    let app = InstalledApp(
                        name: bundleName,
                        bundleIdentifier: bundleIdentifier,
                        path: appURL
                    )
                    apps.append(app)
                }
            }
        }

        // Sort alphabetically and remove duplicates
        apps = apps.sorted { $0.name < $1.name }
        return apps.reduce(into: [InstalledApp]()) { result, app in
            if !result.contains(where: { $0.bundleIdentifier == app.bundleIdentifier }) {
                result.append(app)
            }
        }
    }

    /// Opens an application with the given bundle identifier
    func openApplication(bundleIdentifier: String) {
        let workspace = NSWorkspace.shared
        if let appURL = workspace.urlForApplication(withBundleIdentifier: bundleIdentifier) {
            workspace.open(
                appURL,
                configuration: NSWorkspace.OpenConfiguration(),
                completionHandler: nil
            )
        }
    }

    /// Brings the specified application to the foreground
    func activateApplication(bundleIdentifier: String) {
        let workspace = NSWorkspace.shared
        if let app = NSRunningApplication.runningApplications(withBundleIdentifier: bundleIdentifier).first {
            app.activate(options: [.activateIgnoringOtherApps])
        } else {
            openApplication(bundleIdentifier: bundleIdentifier)
        }
    }
}
