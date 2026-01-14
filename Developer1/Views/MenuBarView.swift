//
//  MenuBarView.swift
//  Developer1
//

import SwiftUI

struct MenuBarView: View {
    @Environment(AppState.self) private var appState

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            // Header
            HStack {
                Text("Today's Work")
                    .font(.headline)
                Spacer()
                if appState.isRefreshing {
                    ProgressView()
                        .scaleEffect(0.7)
                }
            }

            Divider()

            // Stats
            HStack(spacing: 20) {
                StatBadge(
                    icon: "arrow.triangle.branch",
                    value: "\(appState.commitCountToday)",
                    label: "Commits"
                )
                StatBadge(
                    icon: "arrow.triangle.pull",
                    value: "\(appState.prCountToday)",
                    label: "PRs"
                )
            }
            .frame(maxWidth: .infinity)

            // Summary Preview
            if let summary = appState.workSummary {
                Text(summary.summary)
                    .font(.caption)
                    .foregroundStyle(.secondary)
                    .lineLimit(3)
            } else if appState.todayCommits.isEmpty && appState.pullRequests.isEmpty {
                Text("No work recorded today")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }

            // Last refreshed
            if let lastRefreshed = appState.lastRefreshed {
                Text("Updated \(lastRefreshed, style: .relative) ago")
                    .font(.caption2)
                    .foregroundStyle(.tertiary)
            }

            Divider()

            // Actions
            Button {
                Task { await appState.refresh() }
            } label: {
                Label("Refresh", systemImage: "arrow.clockwise")
            }
            .keyboardShortcut("r", modifiers: .command)
            .disabled(appState.isRefreshing)

            Button {
                openMainWindow()
            } label: {
                Label("Open Dashboard", systemImage: "macwindow")
            }
            .keyboardShortcut("o", modifiers: .command)

            Divider()

            Button {
                openSettings()
            } label: {
                Label("Settings...", systemImage: "gear")
            }
            .keyboardShortcut(",", modifiers: .command)

            Button {
                NSApplication.shared.terminate(nil)
            } label: {
                Label("Quit Developer1", systemImage: "power")
            }
            .keyboardShortcut("q", modifiers: .command)
        }
        .padding()
        .frame(width: 280)
        .task {
            if appState.lastRefreshed == nil {
                await appState.refresh()
            }
        }
    }

    private func openMainWindow() {
        NSApplication.shared.activate(ignoringOtherApps: true)
        if let window = NSApplication.shared.windows.first(where: {
            $0.title.contains("Developer1") || $0.identifier?.rawValue.contains("main") == true
        }) {
            window.makeKeyAndOrderFront(nil)
        }
    }

    private func openSettings() {
        NSApp.sendAction(Selector(("showSettingsWindow:")), to: nil, from: nil)
    }
}

#Preview {
    MenuBarView()
        .environment(AppState())
}
