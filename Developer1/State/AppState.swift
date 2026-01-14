import SwiftUI
import Observation

@Observable
final class AppState {
    // MARK: - Data
    var repositories: [Repository] = []
    var todayCommits: [CommitInfo] = []
    var pullRequests: [PullRequest] = []
    var workSummary: WorkSummary?

    // MARK: - UI State
    var isLoading = false
    var isRefreshing = false
    var lastRefreshed: Date?
    var errorMessage: String?

    // MARK: - Settings (persisted)
    var isGitHubEnabled: Bool {
        get { UserDefaults.standard.bool(forKey: "isGitHubEnabled") }
        set { UserDefaults.standard.set(newValue, forKey: "isGitHubEnabled") }
    }

    var isGeminiEnabled: Bool {
        get { UserDefaults.standard.bool(forKey: "isGeminiEnabled") }
        set { UserDefaults.standard.set(newValue, forKey: "isGeminiEnabled") }
    }

    var refreshInterval: TimeInterval {
        get {
            let value = UserDefaults.standard.double(forKey: "refreshInterval")
            return value == 0 ? 1800 : value  // Default: 30 minutes
        }
        set { UserDefaults.standard.set(newValue, forKey: "refreshInterval") }
    }

    // MARK: - Computed Properties
    var commitCountToday: Int { todayCommits.count }
    var prCountToday: Int { pullRequests.count }

    var summaryText: String {
        workSummary?.summary ?? "No summary available"
    }

    var menuBarTitle: String {
        if isLoading { return "..." }
        return "\(commitCountToday)c \(prCountToday)pr"
    }

    var commitsByRepository: [String: [CommitInfo]] {
        Dictionary(grouping: todayCommits, by: { $0.repositoryName })
    }

    // MARK: - Initialization
    init() {
        loadRepositories()
    }

    // MARK: - Actions

    @MainActor
    func refresh() async {
        guard !isRefreshing else { return }

        isRefreshing = true
        errorMessage = nil

        defer {
            isRefreshing = false
            lastRefreshed = Date()
        }

        let startOfToday = Calendar.current.startOfDay(for: Date())

        // Fetch commits from all repositories
        await fetchAllCommits(since: startOfToday)

        // Fetch PRs if GitHub is enabled
        if isGitHubEnabled {
            await fetchPullRequests(since: startOfToday)
        }

        // Generate summary if Gemini is enabled
        if isGeminiEnabled && (!todayCommits.isEmpty || !pullRequests.isEmpty) {
            await generateSummary()
        }
    }

    @MainActor
    private func fetchAllCommits(since: Date) async {
        var allCommits: [CommitInfo] = []

        for repository in repositories where repository.isEnabled {
            do {
                let commits = try await GitService.shared.fetchCommits(
                    from: repository,
                    since: since
                )
                allCommits.append(contentsOf: commits)
            } catch {
                print("Error fetching commits from \(repository.displayName): \(error)")
            }
        }

        todayCommits = allCommits.sorted { $0.date > $1.date }
    }

    @MainActor
    private func fetchPullRequests(since: Date) async {
        do {
            pullRequests = try await GitHubService.shared.fetchUserPRs(since: since)
        } catch {
            errorMessage = "GitHub: \(error.localizedDescription)"
        }
    }

    @MainActor
    private func generateSummary() async {
        do {
            workSummary = try await GeminiService.shared.summarizeWork(
                commits: todayCommits,
                pullRequests: pullRequests
            )
        } catch {
            errorMessage = "Gemini: \(error.localizedDescription)"
        }
    }

    // MARK: - Repository Management

    func addRepository(at path: String) async -> Bool {
        guard await GitService.shared.isValidRepository(at: path) else {
            return false
        }

        let repository = Repository(path: path)
        repositories.append(repository)
        saveRepositories()
        return true
    }

    func removeRepository(_ repository: Repository) {
        repositories.removeAll { $0.id == repository.id }
        saveRepositories()
    }

    func toggleRepository(_ repository: Repository) {
        if let index = repositories.firstIndex(where: { $0.id == repository.id }) {
            repositories[index].isEnabled.toggle()
            saveRepositories()
        }
    }

    private func loadRepositories() {
        if let data = UserDefaults.standard.data(forKey: "repositories"),
           let decoded = try? JSONDecoder().decode([Repository].self, from: data) {
            repositories = decoded
        }
    }

    private func saveRepositories() {
        if let encoded = try? JSONEncoder().encode(repositories) {
            UserDefaults.standard.set(encoded, forKey: "repositories")
        }
    }
}
