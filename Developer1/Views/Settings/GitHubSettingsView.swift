//
//  GitHubSettingsView.swift
//  Developer1
//

import SwiftUI

struct GitHubSettingsView: View {
    @Environment(AppState.self) private var appState
    @State private var token = ""
    @State private var isValidating = false
    @State private var validationResult: ValidationResult?

    enum ValidationResult {
        case success(String)  // username
        case failure(String)  // error message
    }

    var body: some View {
        Form {
            Section {
                @Bindable var state = appState
                Toggle("Enable GitHub Integration", isOn: $state.isGitHubEnabled)

                Text("Fetch your pull requests from GitHub")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }

            if appState.isGitHubEnabled {
                Section("Personal Access Token") {
                    SecureField("GitHub Token", text: $token)
                        .textFieldStyle(.roundedBorder)

                    Text("Create a token at github.com/settings/tokens with 'repo' scope")
                        .font(.caption)
                        .foregroundStyle(.secondary)

                    HStack {
                        Button("Save Token") {
                            saveToken()
                        }
                        .disabled(token.isEmpty)

                        Button("Validate") {
                            validateToken()
                        }
                        .disabled(token.isEmpty || isValidating)

                        if isValidating {
                            ProgressView()
                                .scaleEffect(0.7)
                        }
                    }

                    if let result = validationResult {
                        switch result {
                        case .success(let username):
                            Label("Connected as @\(username)", systemImage: "checkmark.circle.fill")
                                .foregroundStyle(.green)
                        case .failure(let error):
                            Label(error, systemImage: "xmark.circle.fill")
                                .foregroundStyle(.red)
                        }
                    }
                }
            }
        }
        .formStyle(.grouped)
        .padding()
        .onAppear {
            loadToken()
        }
    }

    private func loadToken() {
        token = (try? KeychainService.shared.getGitHubToken()) ?? ""
        if !token.isEmpty {
            // Auto-validate on appear
            validateToken()
        }
    }

    private func saveToken() {
        try? KeychainService.shared.setGitHubToken(token.isEmpty ? nil : token)
        validationResult = nil
    }

    private func validateToken() {
        isValidating = true
        Task {
            do {
                // Save first so the service can read it
                try? KeychainService.shared.setGitHubToken(token)
                let user = try await GitHubService.shared.validateToken()
                await MainActor.run {
                    validationResult = .success(user.login)
                    isValidating = false
                }
            } catch {
                await MainActor.run {
                    validationResult = .failure(error.localizedDescription)
                    isValidating = false
                }
            }
        }
    }
}

#Preview {
    GitHubSettingsView()
        .environment(AppState())
}
