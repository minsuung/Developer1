import Foundation

struct PullRequest: Identifiable, Codable, Sendable {
    let id: Int
    let number: Int
    let title: String
    let state: PRState
    let repositoryFullName: String  // "owner/repo"
    let htmlUrl: String
    let createdAt: Date
    let updatedAt: Date
    let isDraft: Bool
    let additions: Int
    let deletions: Int

    enum PRState: String, Codable, Sendable {
        case open
        case closed
        case merged
    }

    var stateIcon: String {
        switch state {
        case .open: return "arrow.triangle.pull"
        case .closed: return "xmark.circle"
        case .merged: return "arrow.triangle.merge"
        }
    }

    var stateColor: String {
        switch state {
        case .open: return "green"
        case .closed: return "red"
        case .merged: return "purple"
        }
    }
}

// MARK: - GitHub API Response Models

struct GitHubSearchResponse: Codable, Sendable {
    let totalCount: Int
    let items: [GitHubIssueItem]

    enum CodingKeys: String, CodingKey {
        case totalCount = "total_count"
        case items
    }
}

struct GitHubIssueItem: Codable, Sendable {
    let id: Int
    let number: Int
    let title: String
    let state: String
    let htmlUrl: String
    let createdAt: String
    let updatedAt: String
    let draft: Bool?
    let pullRequest: GitHubPullRequestInfo?
    let repositoryUrl: String

    enum CodingKeys: String, CodingKey {
        case id, number, title, state, draft
        case htmlUrl = "html_url"
        case createdAt = "created_at"
        case updatedAt = "updated_at"
        case pullRequest = "pull_request"
        case repositoryUrl = "repository_url"
    }

    func toPullRequest() -> PullRequest {
        let dateFormatter = ISO8601DateFormatter()
        dateFormatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]

        let created = dateFormatter.date(from: createdAt) ?? Date()
        let updated = dateFormatter.date(from: updatedAt) ?? Date()

        // Extract repo name from repository_url
        // Format: https://api.github.com/repos/owner/repo
        let repoName = repositoryUrl
            .replacingOccurrences(of: "https://api.github.com/repos/", with: "")

        let prState: PullRequest.PRState
        if state == "closed" {
            // Check if merged by looking at pull_request.merged_at if available
            prState = .closed
        } else {
            prState = .open
        }

        return PullRequest(
            id: id,
            number: number,
            title: title,
            state: prState,
            repositoryFullName: repoName,
            htmlUrl: htmlUrl,
            createdAt: created,
            updatedAt: updated,
            isDraft: draft ?? false,
            additions: 0,
            deletions: 0
        )
    }
}

struct GitHubPullRequestInfo: Codable, Sendable {
    let url: String
    let mergedAt: String?

    enum CodingKeys: String, CodingKey {
        case url
        case mergedAt = "merged_at"
    }
}

struct GitHubUser: Codable, Sendable {
    let login: String
    let id: Int
    let avatarUrl: String

    enum CodingKeys: String, CodingKey {
        case login, id
        case avatarUrl = "avatar_url"
    }
}
