import SwiftUI

struct ContentView: View {
    @StateObject private var viewModel = FocusSessionViewModel()

    var body: some View {
        VStack(spacing: 24) {
            Text("Attention")
                .font(.system(size: 32, weight: .bold))

            VStack(spacing: 16) {
                Text(viewModel.sessionState.statusText)
                    .font(.system(size: 18))

                if case .running(let remaining) = viewModel.sessionState {
                    Text(viewModel.timeString(from: remaining))
                        .font(.system(size: 48, weight: .light, design: .monospaced))
                        .contentTransition(.numericText())
                }
            }

            VStack(spacing: 12) {
                Button(action: {
                    if viewModel.sessionState.isRunning {
                        viewModel.endSession()
                    } else {
                        viewModel.startSession()
                    }
                }) {
                    HStack {
                        Image(systemName: viewModel.sessionState.isRunning ? "stop.fill" : "play.fill")
                        Text(viewModel.sessionState.isRunning ? "End Session" : "Start Focus Session")
                    }
                    .frame(minWidth: 160)
                }
                .buttonStyle(.borderedProminent)
                .controlSize(.large)
                .disabled(viewModel.sessionState.isPaused)

                if viewModel.sessionState.isRunning {
                    Button(action: {
                        viewModel.togglePause()
                    }) {
                        HStack {
                            Image(systemName: viewModel.sessionState.isPaused ? "play.fill" : "pause.fill")
                            Text(viewModel.sessionState.isPaused ? "Resume" : "Pause")
                        }
                        .frame(minWidth: 120)
                    }
                    .buttonStyle(.bordered)
                }
            }

            Divider()

            VStack(alignment: .leading, spacing: 12) {
                Text("Session Configuration")
                    .font(.headline)

                HStack {
                    Text("Duration:")
                    TextField("", value: $viewModel.sessionDuration, format: .number)
                        .frame(width: 60)
                        .textFieldStyle(.roundedBorder)
                    Text("minutes")
                        .foregroundColor(.secondary)
                }

                HStack {
                    Text("App to open:")
                    Picker("", selection: $viewModel.selectedAppBundleIdentifier) {
                        Text("None").tag("")
                        ForEach(viewModel.installedApps, id: \.bundleIdentifier) { app in
                            Text(app.name).tag(app.bundleIdentifier)
                        }
                    }
                    .frame(width: 200)
                }

                Toggle("Clear desktop", isOn: $viewModel.clearDesktop)

                Toggle("Start music", isOn: $viewModel.startMusic)

                if viewModel.startMusic {
                    Picker("Music Source", selection: $viewModel.musicSource) {
                        Text("Apple Music").tag(MusicSource.appleMusic)
                        Text("Spotify").tag(MusicSource.spotify)
                        Text("Other").tag(MusicSource.other)
                    }
                    .pickerStyle(.segmented)
                }

                Toggle("Show starter task prompt", isOn: $viewModel.showStarterTask)
            }
            .padding()
            .background(Color(NSColor.controlBackgroundColor))
            .cornerRadius(8)
        }
        .padding(32)
        .frame(minWidth: 400, minHeight: 500)
        .onAppear {
            viewModel.loadInstalledApps()
        }
    }
}

#Preview {
    ContentView()
}
