import Foundation

struct CommitInfo: Identifiable, Codable, Sendable {
    let id: String  // commit hash
    let repositoryId: UUID
    let repositoryName: String
    let message: String
    let author: String
    let authorEmail: String
    let date: Date
    let filesChanged: Int
    let insertions: Int
    let deletions: Int

    var shortHash: String {
        String(id.prefix(7))
    }

    var firstLine: String {
        message.components(separatedBy: .newlines).first ?? message
    }

    init(
        id: String,
        repositoryId: UUID,
        repositoryName: String,
        message: String,
        author: String,
        authorEmail: String,
        date: Date,
        filesChanged: Int = 0,
        insertions: Int = 0,
        deletions: Int = 0
    ) {
        self.id = id
        self.repositoryId = repositoryId
        self.repositoryName = repositoryName
        self.message = message
        self.author = author
        self.authorEmail = authorEmail
        self.date = date
        self.filesChanged = filesChanged
        self.insertions = insertions
        self.deletions = deletions
    }
}
