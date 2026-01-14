import Foundation

struct Repository: Identifiable, Codable, Hashable, Sendable {
    let id: UUID
    var path: String
    var name: String
    var isEnabled: Bool
    var lastFetched: Date?

    var displayName: String {
        name.isEmpty ? URL(fileURLWithPath: path).lastPathComponent : name
    }

    init(id: UUID = UUID(), path: String, name: String = "", isEnabled: Bool = true, lastFetched: Date? = nil) {
        self.id = id
        self.path = path
        self.name = name
        self.isEnabled = isEnabled
        self.lastFetched = lastFetched
    }
}
