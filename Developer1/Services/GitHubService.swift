import Foundation

actor GitHubService {
    static let shared = GitHubService()

    private let baseURL = "https://api.github.com"

    private init() {}

    func fetchUserPRs(since: Date) async throws -> [PullRequest] {
        guard let token = try await getToken(), !token.isEmpty else {
            throw GitHubError.noToken
        }

        // Format date for GitHub search query (YYYY-MM-DD)
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        let sinceString = dateFormatter.string(from: since)

        // Use GitHub Search API to find user's PRs
        let query = "is:pr author:@me created:>=\(sinceString)"
        guard let encodedQuery = query.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) else {
            throw GitHubError.invalidResponse
        }

        guard let url = URL(string: "\(baseURL)/search/issues?q=\(encodedQuery)&per_page=100") else {
            throw GitHubError.invalidResponse
        }

        var request = URLRequest(url: url)
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        request.setValue("application/vnd.github+json", forHTTPHeaderField: "Accept")
        request.setValue("2022-11-28", forHTTPHeaderField: "X-GitHub-Api-Version")

        let (data, response) = try await URLSession.shared.data(for: request)

        guard let httpResponse = response as? HTTPURLResponse else {
            throw GitHubError.invalidResponse
        }

        switch httpResponse.statusCode {
        case 200:
            break
        case 401:
            throw GitHubError.unauthorized
        case 403:
            throw GitHubError.rateLimited
        default:
            throw GitHubError.httpError(httpResponse.statusCode)
        }

        let decoder = JSONDecoder()
        let searchResult = try decoder.decode(GitHubSearchResponse.self, from: data)
        return searchResult.items.map { $0.toPullRequest() }
    }

    func validateToken() async throws -> GitHubUser {
        guard let token = try await getToken(), !token.isEmpty else {
            throw GitHubError.noToken
        }

        guard let url = URL(string: "\(baseURL)/user") else {
            throw GitHubError.invalidResponse
        }

        var request = URLRequest(url: url)
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        request.setValue("application/vnd.github+json", forHTTPHeaderField: "Accept")

        let (data, response) = try await URLSession.shared.data(for: request)

        guard let httpResponse = response as? HTTPURLResponse else {
            throw GitHubError.invalidResponse
        }

        guard httpResponse.statusCode == 200 else {
            if httpResponse.statusCode == 401 {
                throw GitHubError.unauthorized
            }
            throw GitHubError.httpError(httpResponse.statusCode)
        }

        return try JSONDecoder().decode(GitHubUser.self, from: data)
    }

    private nonisolated func getToken() async throws -> String? {
        try KeychainService.shared.getGitHubToken()
    }
}

enum GitHubError: LocalizedError, Sendable {
    case noToken
    case invalidResponse
    case httpError(Int)
    case unauthorized
    case rateLimited

    var errorDescription: String? {
        switch self {
        case .noToken:
            return "GitHub token not configured"
        case .invalidResponse:
            return "Invalid response from GitHub"
        case .httpError(let code):
            return "GitHub API error: HTTP \(code)"
        case .unauthorized:
            return "GitHub token is invalid or expired"
        case .rateLimited:
            return "GitHub API rate limit exceeded"
        }
    }
}
