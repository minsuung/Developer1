//
//  PRRowView.swift
//  Developer1
//

import SwiftUI

struct PRRowView: View {
    let pullRequest: PullRequest

    var body: some View {
        HStack(alignment: .top, spacing: 12) {
            Image(systemName: pullRequest.stateIcon)
                .foregroundStyle(stateColor)
                .frame(width: 20)

            VStack(alignment: .leading, spacing: 4) {
                Text(pullRequest.title)
                    .font(.body)
                    .lineLimit(2)

                HStack(spacing: 8) {
                    Text(pullRequest.repositoryFullName)
                        .font(.caption)
                        .padding(.horizontal, 6)
                        .padding(.vertical, 2)
                        .background(Color.green.opacity(0.1))
                        .cornerRadius(4)

                    Text("#\(pullRequest.number)")
                        .font(.caption)
                        .foregroundStyle(.secondary)

                    Text(pullRequest.state.rawValue.capitalized)
                        .font(.caption)
                        .foregroundStyle(stateColor)

                    if pullRequest.isDraft {
                        Text("Draft")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                }
            }

            Spacer()

            Button {
                if let url = URL(string: pullRequest.htmlUrl) {
                    NSWorkspace.shared.open(url)
                }
            } label: {
                Image(systemName: "arrow.up.right.square")
            }
            .buttonStyle(.borderless)
            .help("Open in browser")
        }
        .padding(.vertical, 8)
        .padding(.horizontal, 12)
        .background(Color.secondary.opacity(0.05))
        .cornerRadius(8)
    }

    private var stateColor: Color {
        switch pullRequest.state {
        case .open: return .green
        case .closed: return .red
        case .merged: return .purple
        }
    }
}

#Preview {
    PRRowView(pullRequest: PullRequest(
        id: 1,
        number: 123,
        title: "Add new feature for user authentication",
        state: .open,
        repositoryFullName: "owner/repo",
        htmlUrl: "https://github.com/owner/repo/pull/123",
        createdAt: Date(),
        updatedAt: Date(),
        isDraft: false,
        additions: 100,
        deletions: 50
    ))
    .padding()
}
