import Foundation

actor GeminiService {
    static let shared = GeminiService()

    private let baseURL = "https://generativelanguage.googleapis.com/v1beta"

    private init() {}

    func summarizeWork(commits: [CommitInfo], pullRequests: [PullRequest]) async throws -> WorkSummary {
        guard let apiKey = try await getApiKey(), !apiKey.isEmpty else {
            throw GeminiError.noApiKey
        }

        let prompt = buildPrompt(commits: commits, pullRequests: pullRequests)

        guard let url = URL(string: "\(baseURL)/models/gemini-1.5-flash:generateContent?key=\(apiKey)") else {
            throw GeminiError.requestFailed
        }

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")

        let requestBody = GeminiRequest(
            contents: [
                GeminiContent(parts: [GeminiPart(text: prompt)])
            ]
        )

        request.httpBody = try JSONEncoder().encode(requestBody)

        let (data, response) = try await URLSession.shared.data(for: request)

        guard let httpResponse = response as? HTTPURLResponse else {
            throw GeminiError.requestFailed
        }

        guard httpResponse.statusCode == 200 else {
            if let errorResponse = try? JSONDecoder().decode(GeminiErrorResponse.self, from: data) {
                throw GeminiError.apiError(errorResponse.error.message)
            }
            throw GeminiError.httpError(httpResponse.statusCode)
        }

        let geminiResponse = try JSONDecoder().decode(GeminiResponse.self, from: data)

        guard let text = geminiResponse.candidates?.first?.content.parts.first?.text else {
            throw GeminiError.noContent
        }

        return WorkSummary(
            commitCount: commits.count,
            prCount: pullRequests.count,
            summary: text,
            highlights: extractHighlights(from: text)
        )
    }

    private nonisolated func getApiKey() async throws -> String? {
        try KeychainService.shared.getGeminiApiKey()
    }

    private func buildPrompt(commits: [CommitInfo], pullRequests: [PullRequest]) -> String {
        var prompt = """
        오늘의 개발 업무 내용을 간결하고 전문적으로 요약해주세요.

        ## 커밋 (\(commits.count)개):
        """

        if commits.isEmpty {
            prompt += "\n(커밋 없음)"
        } else {
            for commit in commits.prefix(20) {  // Limit to 20 commits
                prompt += "\n- \(commit.repositoryName): \(commit.firstLine)"
            }
            if commits.count > 20 {
                prompt += "\n... 외 \(commits.count - 20)개"
            }
        }

        prompt += "\n\n## Pull Requests (\(pullRequests.count)개):"

        if pullRequests.isEmpty {
            prompt += "\n(PR 없음)"
        } else {
            for pr in pullRequests {
                prompt += "\n- \(pr.repositoryFullName): \(pr.title) (\(pr.state.rawValue))"
            }
        }

        prompt += """

        다음 형식으로 작성해주세요:
        1. 2-3문장으로 주요 업무 내용 요약
        2. 주요 작업 항목을 불릿 포인트로 3-5개 나열

        스탠드업 미팅이나 업무 보고에 적합한 톤으로 작성해주세요.
        한국어로 답변해주세요.
        """

        return prompt
    }

    private func extractHighlights(from text: String) -> [String] {
        text.components(separatedBy: .newlines)
            .filter { line in
                let trimmed = line.trimmingCharacters(in: .whitespaces)
                return trimmed.hasPrefix("-") || trimmed.hasPrefix("*") || trimmed.hasPrefix("•")
            }
            .map { line in
                line.trimmingCharacters(in: CharacterSet(charactersIn: "-*• ").union(.whitespaces))
            }
            .filter { !$0.isEmpty }
    }
}

// MARK: - Gemini API Models

struct GeminiRequest: Codable, Sendable {
    let contents: [GeminiContent]
}

struct GeminiContent: Codable, Sendable {
    let parts: [GeminiPart]
}

struct GeminiPart: Codable, Sendable {
    let text: String
}

struct GeminiResponse: Codable, Sendable {
    let candidates: [GeminiCandidate]?
}

struct GeminiCandidate: Codable, Sendable {
    let content: GeminiContent
}

struct GeminiErrorResponse: Codable, Sendable {
    let error: GeminiErrorDetail
}

struct GeminiErrorDetail: Codable, Sendable {
    let code: Int
    let message: String
    let status: String
}

enum GeminiError: LocalizedError, Sendable {
    case noApiKey
    case requestFailed
    case noContent
    case httpError(Int)
    case apiError(String)

    var errorDescription: String? {
        switch self {
        case .noApiKey:
            return "Gemini API key not configured"
        case .requestFailed:
            return "Failed to connect to Gemini API"
        case .noContent:
            return "No content in Gemini response"
        case .httpError(let code):
            return "Gemini API error: HTTP \(code)"
        case .apiError(let message):
            return "Gemini API: \(message)"
        }
    }
}
