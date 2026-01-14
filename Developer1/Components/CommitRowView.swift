//
//  CommitRowView.swift
//  Developer1
//

import SwiftUI

struct CommitRowView: View {
    let commit: CommitInfo

    var body: some View {
        HStack(alignment: .top, spacing: 12) {
            Image(systemName: "arrow.triangle.branch")
                .foregroundStyle(.blue)
                .frame(width: 20)

            VStack(alignment: .leading, spacing: 4) {
                Text(commit.firstLine)
                    .font(.body)
                    .lineLimit(1)

                HStack(spacing: 8) {
                    Text(commit.repositoryName)
                        .font(.caption)
                        .padding(.horizontal, 6)
                        .padding(.vertical, 2)
                        .background(Color.blue.opacity(0.1))
                        .cornerRadius(4)

                    Text(commit.shortHash)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                        .monospaced()

                    Text(commit.date, style: .time)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
            }

            Spacer()
        }
        .padding(.vertical, 8)
        .padding(.horizontal, 12)
        .background(Color.secondary.opacity(0.05))
        .cornerRadius(8)
    }
}

#Preview {
    CommitRowView(commit: CommitInfo(
        id: "abc1234567890",
        repositoryId: UUID(),
        repositoryName: "MyProject",
        message: "Fix bug in authentication flow",
        author: "John Doe",
        authorEmail: "john@example.com",
        date: Date()
    ))
    .padding()
}
