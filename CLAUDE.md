# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

**Attention** is a native macOS focus session app built with SwiftUI. It helps users enter a productive flow state by orchestrating their environment:
- Clearing desktop clutter
- Opening a specific application
- Starting focus music
- Setting a timer
- Prompting for a starter task

## Building and Running

```bash
# Open the project in Xcode
open Attention.xcodeproj

# From Xcode, press Cmd+R to build and run
# Or use xcodebuild from command line
xcodebuild -project Attention.xcodeproj -scheme Attention build
```

## Architecture

The app follows a standard MVVM architecture with SwiftUI:

### Models (`Attention/Models/`)
- `FocusSession.swift` - Core domain models: `SessionState`, `MusicSource`, `FocusSessionConfiguration`, `InstalledApp`, `FocusSession`
- `SessionHistory.swift` - Actor for persisting and retrieving session history to `~/Documents/Attention/sessions.json`

### ViewModels (`Attention/ViewModels/`)
- `FocusSessionViewModel.swift` - Main view model that manages session state, timer, and coordinates services

### Services (`Attention/Services/`)
- `AppService.swift` - Discovers installed applications and launches apps via NSWorkspace
- `DesktopService.swift` - Clears/restores desktop by moving files to hidden folders
- `MusicService.swift` - Controls music playback via AppleScript (Apple Music, Spotify)

### Views (`Attention/Views/`)
- `ContentView.swift` - Main session control UI
- `SettingsView.swift` - Preferences window with tabs for General and Sessions

### Entry Point
- `AttentionApp.swift` - App entry point with `@main` attribute and `AppDelegate`

## Key Design Decisions

1. **Sandboxing**: The app uses App Sandbox with entitlements for Apple Events (needed for app control and AppleScript) and file access (needed for desktop operations)

2. **Async/Await pattern**: Service calls that may take time are marked async (e.g., `executeSessionStart`)

3. **Session persistence**: Completed sessions are saved to JSON in Documents/Attention/ for history/statistics

4. **State management**: `@Published` properties in the view model drive UI updates via SwiftUI's reactive system

## Development Notes

- macOS 14.0+ is the minimum deployment target
- SwiftUI Canvas previews are enabled for rapid UI iteration
- The timer is implemented with `Timer.scheduledTimer` rather than `Timer.publish` for more direct control
- AppleScript is used for media key playback control (`key code 52` = play/pause)
