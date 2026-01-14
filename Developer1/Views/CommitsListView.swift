//
//  CommitsListView.swift
//  Developer1
//

import SwiftUI

struct CommitsListView: View {
    @Environment(AppState.self) private var appState

    var body: some View {
        Group {
            if appState.todayCommits.isEmpty {
                ContentUnavailableView(
                    "No Commits Today",
                    systemImage: "arrow.triangle.branch",
                    description: Text("Your commits will appear here once you make some changes.")
                )
            } else {
                ScrollView {
                    LazyVStack(alignment: .leading, spacing: 16) {
                        ForEach(Array(appState.commitsByRepository.keys.sorted()), id: \.self) { repoName in
                            if let commits = appState.commitsByRepository[repoName] {
                                repositorySection(name: repoName, commits: commits)
                            }
                        }
                    }
                    .padding()
                }
            }
        }
        .navigationTitle("Commits")
    }

    private func repositorySection(name: String, commits: [CommitInfo]) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Image(systemName: "folder")
                    .foregroundStyle(.orange)
                Text(name)
                    .font(.headline)
                Text("(\(commits.count))")
                    .foregroundStyle(.secondary)
            }

            VStack(spacing: 8) {
                ForEach(commits) { commit in
                    CommitRowView(commit: commit)
                }
            }
        }
    }
}

#Preview {
    CommitsListView()
        .environment(AppState())
        .frame(width: 600, height: 400)
}
