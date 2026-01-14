//
//  DashboardView.swift
//  Developer1
//

import SwiftUI

struct DashboardView: View {
    @Environment(AppState.self) private var appState

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 24) {
                // Header
                headerSection

                // Stats Cards
                statsSection

                // AI Summary
                if appState.isGeminiEnabled {
                    summarySection
                }

                // Recent Commits
                recentCommitsSection

                // Error Message
                if let error = appState.errorMessage {
                    errorSection(error)
                }
            }
            .padding()
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
    }

    private var headerSection: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text("Today's Work")
                .font(.largeTitle)
                .fontWeight(.bold)

            if let lastRefreshed = appState.lastRefreshed {
                Text("Last updated \(lastRefreshed, style: .relative) ago")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
        }
    }

    private var statsSection: some View {
        HStack(spacing: 16) {
            StatCard(
                title: "Commits",
                value: "\(appState.commitCountToday)",
                icon: "arrow.triangle.branch",
                color: .blue
            )

            StatCard(
                title: "Pull Requests",
                value: "\(appState.prCountToday)",
                icon: "arrow.triangle.pull",
                color: .green
            )

            StatCard(
                title: "Repositories",
                value: "\(appState.repositories.filter { $0.isEnabled }.count)",
                icon: "folder",
                color: .orange
            )
        }
    }

    @ViewBuilder
    private var summarySection: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Image(systemName: "sparkles")
                Text("AI Summary")
                    .font(.headline)
            }

            if let summary = appState.workSummary {
                Text(summary.summary)
                    .padding()
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .background(Color.accentColor.opacity(0.1))
                    .cornerRadius(8)
            } else if appState.todayCommits.isEmpty && appState.pullRequests.isEmpty {
                Text("No work to summarize yet")
                    .foregroundStyle(.secondary)
                    .padding()
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .background(Color.secondary.opacity(0.1))
                    .cornerRadius(8)
            } else {
                Text("Enable Gemini in settings to get AI summaries")
                    .foregroundStyle(.secondary)
                    .padding()
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .background(Color.secondary.opacity(0.1))
                    .cornerRadius(8)
            }
        }
    }

    private var recentCommitsSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Recent Commits")
                .font(.headline)

            if appState.todayCommits.isEmpty {
                Text("No commits today")
                    .foregroundStyle(.secondary)
                    .padding()
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .background(Color.secondary.opacity(0.1))
                    .cornerRadius(8)
            } else {
                VStack(spacing: 8) {
                    ForEach(appState.todayCommits.prefix(5)) { commit in
                        CommitRowView(commit: commit)
                    }
                }
            }
        }
    }

    private func errorSection(_ error: String) -> some View {
        HStack {
            Image(systemName: "exclamationmark.triangle")
            Text(error)
        }
        .foregroundStyle(.red)
        .padding()
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color.red.opacity(0.1))
        .cornerRadius(8)
    }
}

struct StatCard: View {
    let title: String
    let value: String
    let icon: String
    let color: Color

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Image(systemName: icon)
                    .foregroundStyle(color)
                Text(title)
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }

            Text(value)
                .font(.title)
                .fontWeight(.bold)
        }
        .padding()
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(color.opacity(0.1))
        .cornerRadius(12)
    }
}

#Preview {
    DashboardView()
        .environment(AppState())
        .frame(width: 700, height: 500)
}
