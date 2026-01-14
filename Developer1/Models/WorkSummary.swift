import Foundation

struct WorkSummary: Codable, Sendable {
    let date: Date
    let commitCount: Int
    let prCount: Int
    let summary: String
    let highlights: [String]
    let generatedAt: Date

    init(
        date: Date = Date(),
        commitCount: Int,
        prCount: Int,
        summary: String,
        highlights: [String] = [],
        generatedAt: Date = Date()
    ) {
        self.date = date
        self.commitCount = commitCount
        self.prCount = prCount
        self.summary = summary
        self.highlights = highlights
        self.generatedAt = generatedAt
    }
}
