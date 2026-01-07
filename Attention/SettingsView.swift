import SwiftUI

struct SettingsView: View {
    @AppStorage("defaultSessionDuration") private var defaultDuration = 25
    @AppStorage("defaultClearDesktop") private var defaultClearDesktop = true
    @AppStorage("defaultStartMusic") private var defaultStartMusic = false
    @AppStorage("defaultMusicSource") private var defaultMusicSource = 0
    @AppStorage("defaultShowStarterTask") private var defaultShowStarterTask = true

    var body: some View {
        TabView {
            GeneralSettingsView()
                .tabItem {
                    Label("General", systemImage: "gearshape")
                }

            SessionSettingsView()
                .tabItem {
                    Label("Sessions", systemImage: "timer")
                }
        }
        .frame(width: 450, height: 300)
    }
}

struct GeneralSettingsView: View {
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("General preferences will go here.")
                .foregroundColor(.secondary)
            Spacer()
        }
        .padding()
    }
}

struct SessionSettingsView: View {
    @AppStorage("defaultSessionDuration") private var defaultDuration = 25
    @AppStorage("defaultClearDesktop") private var defaultClearDesktop = true
    @AppStorage("defaultStartMusic") private var defaultStartMusic = false
    @AppStorage("defaultShowStarterTask") private var defaultShowStarterTask = true

    var body: some View {
        Form {
            Section("Default Session Settings") {
                HStack {
                    Text("Duration")
                    Spacer()
                    TextField("minutes", value: $defaultDuration, format: .number)
                        .frame(width: 60)
                        .textFieldStyle(.roundedBorder)
                    Text("minutes")
                        .foregroundColor(.secondary)
                }

                Toggle("Clear desktop on session start", isOn: $defaultClearDesktop)
                Toggle("Start music automatically", isOn: $defaultStartMusic)
                Toggle("Show starter task prompt", isOn: $defaultShowStarterTask)
            }
        }
        .padding()
    }
}

#Preview {
    SettingsView()
}
