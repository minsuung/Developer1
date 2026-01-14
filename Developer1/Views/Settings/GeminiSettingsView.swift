//
//  GeminiSettingsView.swift
//  Developer1
//

import SwiftUI

struct GeminiSettingsView: View {
    @Environment(AppState.self) private var appState
    @State private var apiKey = ""
    @State private var isSaved = false

    var body: some View {
        Form {
            Section {
                @Bindable var state = appState
                Toggle("Enable AI Summary", isOn: $state.isGeminiEnabled)

                Text("Use Google Gemini to generate daily work summaries")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }

            if appState.isGeminiEnabled {
                Section("Gemini API Key") {
                    SecureField("API Key", text: $apiKey)
                        .textFieldStyle(.roundedBorder)

                    Link("Get your API key from Google AI Studio",
                         destination: URL(string: "https://makersuite.google.com/app/apikey")!)
                        .font(.caption)

                    HStack {
                        Button("Save API Key") {
                            saveApiKey()
                        }
                        .disabled(apiKey.isEmpty)

                        if isSaved {
                            Label("Saved", systemImage: "checkmark.circle.fill")
                                .foregroundStyle(.green)
                                .font(.caption)
                        }
                    }
                }

                Section("About") {
                    Text("Gemini will analyze your commits and PRs to generate a natural language summary of your daily work. This is useful for standups or status reports.")
                        .font(.caption)
                        .foregroundStyle(.secondary)

                    Text("Uses Gemini 1.5 Flash (free tier)")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
            }
        }
        .formStyle(.grouped)
        .padding()
        .onAppear {
            loadApiKey()
        }
    }

    private func loadApiKey() {
        apiKey = (try? KeychainService.shared.getGeminiApiKey()) ?? ""
    }

    private func saveApiKey() {
        try? KeychainService.shared.setGeminiApiKey(apiKey.isEmpty ? nil : apiKey)
        isSaved = true

        // Reset saved indicator after 2 seconds
        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
            isSaved = false
        }
    }
}

#Preview {
    GeminiSettingsView()
        .environment(AppState())
}
