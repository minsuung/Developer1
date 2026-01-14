//
//  SettingsView.swift
//  Developer1
//

import SwiftUI

struct SettingsView: View {
    var body: some View {
        TabView {
            GeneralSettingsView()
                .tabItem {
                    Label("General", systemImage: "gear")
                }

            RepositoriesSettingsView()
                .tabItem {
                    Label("Repositories", systemImage: "folder")
                }

            GitHubSettingsView()
                .tabItem {
                    Label("GitHub", systemImage: "network")
                }

            GeminiSettingsView()
                .tabItem {
                    Label("AI Summary", systemImage: "sparkles")
                }
        }
        .frame(width: 500, height: 350)
    }
}

#Preview {
    SettingsView()
        .environment(AppState())
}
