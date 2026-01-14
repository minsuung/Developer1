import Foundation

actor GitService {
    static let shared = GitService()

    private init() {}

    func fetchCommits(from repository: Repository, since: Date, author: String? = nil) async throws -> [CommitInfo] {
        // Get current user email if author not specified
        let authorEmail = try await getCurrentUserEmail(at: repository.path)

        let dateFormatter = ISO8601DateFormatter()
        let sinceString = dateFormatter.string(from: since)

        // Build git log command
        // Format: hash|subject|author name|author email|date (ISO)
        let format = "%H|%s|%an|%ae|%aI"
        var arguments = [
            "log",
            "--since=\(sinceString)",
            "--author=\(author ?? authorEmail)",
            "--pretty=format:\(format)"
        ]

        let output = try await runGitCommand(arguments, at: repository.path)

        if output.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            return []
        }

        return parseGitLogOutput(
            output,
            repositoryId: repository.id,
            repositoryName: repository.displayName
        )
    }

    func isValidRepository(at path: String) async -> Bool {
        do {
            let output = try await runGitCommand(["rev-parse", "--git-dir"], at: path)
            return !output.isEmpty
        } catch {
            return false
        }
    }

    func getCurrentUserEmail(at path: String) async throws -> String {
        let output = try await runGitCommand(["config", "user.email"], at: path)
        return output.trimmingCharacters(in: .whitespacesAndNewlines)
    }

    func getRemoteUrl(for repository: Repository) async throws -> String? {
        let output = try await runGitCommand(["remote", "get-url", "origin"], at: repository.path)
        let url = output.trimmingCharacters(in: .whitespacesAndNewlines)
        return url.isEmpty ? nil : url
    }

    // MARK: - Private Helpers

    private func runGitCommand(_ arguments: [String], at path: String) async throws -> String {
        try await withCheckedThrowingContinuation { continuation in
            let process = Process()
            let pipe = Pipe()

            process.executableURL = URL(fileURLWithPath: "/usr/bin/git")
            process.arguments = arguments
            process.currentDirectoryURL = URL(fileURLWithPath: path)
            process.standardOutput = pipe
            process.standardError = pipe

            do {
                try process.run()
                process.waitUntilExit()

                let data = pipe.fileHandleForReading.readDataToEndOfFile()
                let output = String(data: data, encoding: .utf8) ?? ""

                if process.terminationStatus == 0 {
                    continuation.resume(returning: output)
                } else {
                    continuation.resume(throwing: GitError.commandFailed(output))
                }
            } catch {
                continuation.resume(throwing: error)
            }
        }
    }

    private func parseGitLogOutput(
        _ output: String,
        repositoryId: UUID,
        repositoryName: String
    ) -> [CommitInfo] {
        let lines = output.components(separatedBy: .newlines)
        var commits: [CommitInfo] = []

        let dateFormatter = ISO8601DateFormatter()
        dateFormatter.formatOptions = [.withInternetDateTime]

        for line in lines {
            let trimmed = line.trimmingCharacters(in: .whitespaces)
            guard !trimmed.isEmpty else { continue }

            let parts = trimmed.components(separatedBy: "|")
            guard parts.count >= 5 else { continue }

            let hash = parts[0]
            let message = parts[1]
            let authorName = parts[2]
            let authorEmail = parts[3]
            let dateString = parts[4]

            guard let date = dateFormatter.date(from: dateString) else { continue }

            let commit = CommitInfo(
                id: hash,
                repositoryId: repositoryId,
                repositoryName: repositoryName,
                message: message,
                author: authorName,
                authorEmail: authorEmail,
                date: date
            )
            commits.append(commit)
        }

        return commits
    }
}

enum GitError: LocalizedError, Sendable {
    case commandFailed(String)
    case invalidRepository
    case notFound

    var errorDescription: String? {
        switch self {
        case .commandFailed(let message):
            return "Git command failed: \(message)"
        case .invalidRepository:
            return "Not a valid git repository"
        case .notFound:
            return "Git executable not found"
        }
    }
}
