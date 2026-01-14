//
//  GeneralSettingsView.swift
//  Developer1
//

import SwiftUI

struct GeneralSettingsView: View {
    @Environment(AppState.self) private var appState
    @AppStorage("launchAtLogin") private var launchAtLogin = false

    var body: some View {
        Form {
            Section {
                Toggle("Launch at login", isOn: $launchAtLogin)
            }

            Section("Refresh") {
                @Bindable var state = appState
                Picker("Auto-refresh interval", selection: $state.refreshInterval) {
                    Text("5 minutes").tag(TimeInterval(300))
                    Text("15 minutes").tag(TimeInterval(900))
                    Text("30 minutes").tag(TimeInterval(1800))
                    Text("1 hour").tag(TimeInterval(3600))
                    Text("Manual only").tag(TimeInterval(0))
                }
            }

            Section {
                LabeledContent("Version") {
                    Text(Bundle.main.object(forInfoDictionaryKey: "CFBundleShortVersionString") as? String ?? "1.0")
                }
            }
        }
        .formStyle(.grouped)
        .padding()
    }
}

#Preview {
    GeneralSettingsView()
        .environment(AppState())
}
