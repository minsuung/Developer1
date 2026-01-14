import Foundation
import Security

final class KeychainService: @unchecked Sendable {
    static let shared = KeychainService()

    private let serviceName = "kim.minseong.Developer1"
    private let githubTokenKey = "github_token"
    private let geminiApiKeyKey = "gemini_api_key"

    private init() {}

    // MARK: - GitHub Token

    func getGitHubToken() throws -> String? {
        try getPassword(for: githubTokenKey)
    }

    func setGitHubToken(_ token: String?) throws {
        if let token = token, !token.isEmpty {
            try setPassword(token, for: githubTokenKey)
        } else {
            try deletePassword(for: githubTokenKey)
        }
    }

    // MARK: - Gemini API Key

    func getGeminiApiKey() throws -> String? {
        try getPassword(for: geminiApiKeyKey)
    }

    func setGeminiApiKey(_ key: String?) throws {
        if let key = key, !key.isEmpty {
            try setPassword(key, for: geminiApiKeyKey)
        } else {
            try deletePassword(for: geminiApiKeyKey)
        }
    }

    // MARK: - Private Keychain Operations

    private func getPassword(for key: String) throws -> String? {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: serviceName,
            kSecAttrAccount as String: key,
            kSecReturnData as String: true,
            kSecMatchLimit as String: kSecMatchLimitOne
        ]

        var result: AnyObject?
        let status = SecItemCopyMatching(query as CFDictionary, &result)

        if status == errSecItemNotFound {
            return nil
        }

        guard status == errSecSuccess,
              let data = result as? Data,
              let password = String(data: data, encoding: .utf8) else {
            throw KeychainError.unableToRead
        }

        return password
    }

    private func setPassword(_ password: String, for key: String) throws {
        guard let data = password.data(using: .utf8) else {
            throw KeychainError.unableToWrite
        }

        // Try to update first
        let updateQuery: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: serviceName,
            kSecAttrAccount as String: key
        ]

        let attributes: [String: Any] = [
            kSecValueData as String: data
        ]

        var status = SecItemUpdate(updateQuery as CFDictionary, attributes as CFDictionary)

        if status == errSecItemNotFound {
            // Item doesn't exist, create it
            var newItem = updateQuery
            newItem[kSecValueData as String] = data
            status = SecItemAdd(newItem as CFDictionary, nil)
        }

        guard status == errSecSuccess else {
            throw KeychainError.unableToWrite
        }
    }

    private func deletePassword(for key: String) throws {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: serviceName,
            kSecAttrAccount as String: key
        ]

        let status = SecItemDelete(query as CFDictionary)
        guard status == errSecSuccess || status == errSecItemNotFound else {
            throw KeychainError.unableToDelete
        }
    }
}

enum KeychainError: LocalizedError {
    case unableToRead
    case unableToWrite
    case unableToDelete

    var errorDescription: String? {
        switch self {
        case .unableToRead: return "Unable to read from Keychain"
        case .unableToWrite: return "Unable to write to Keychain"
        case .unableToDelete: return "Unable to delete from Keychain"
        }
    }
}
