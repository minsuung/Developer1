//
//  PRListView.swift
//  Developer1
//

import SwiftUI

struct PRListView: View {
    @Environment(AppState.self) private var appState

    var body: some View {
        Group {
            if !appState.isGitHubEnabled {
                ContentUnavailableView(
                    "GitHub Not Enabled",
                    systemImage: "network.slash",
                    description: Text("Enable GitHub integration in Settings to see your pull requests.")
                )
            } else if appState.pullRequests.isEmpty {
                ContentUnavailableView(
                    "No Pull Requests",
                    systemImage: "arrow.triangle.pull",
                    description: Text("Your pull requests created today will appear here.")
                )
            } else {
                ScrollView {
                    LazyVStack(spacing: 12) {
                        ForEach(appState.pullRequests) { pr in
                            PRRowView(pullRequest: pr)
                        }
                    }
                    .padding()
                }
            }
        }
        .navigationTitle("Pull Requests")
    }
}

#Preview {
    PRListView()
        .environment(AppState())
        .frame(width: 600, height: 400)
}
