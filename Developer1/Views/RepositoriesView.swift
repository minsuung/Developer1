//
//  RepositoriesView.swift
//  Developer1
//

import SwiftUI
import UniformTypeIdentifiers

struct RepositoriesView: View {
    @Environment(AppState.self) private var appState
    @State private var isAddingRepository = false

    var body: some View {
        Group {
            if appState.repositories.isEmpty {
                ContentUnavailableView {
                    Label("No Repositories", systemImage: "folder")
                } description: {
                    Text("Add a Git repository to start tracking your commits.")
                } actions: {
                    Button("Add Repository") {
                        isAddingRepository = true
                    }
                    .buttonStyle(.borderedProminent)
                }
            } else {
                List {
                    ForEach(appState.repositories) { repo in
                        RepositoryRow(repository: repo)
                    }
                    .onDelete { indexSet in
                        for index in indexSet {
                            appState.removeRepository(appState.repositories[index])
                        }
                    }
                }
            }
        }
        .navigationTitle("Repositories")
        .toolbar {
            ToolbarItem {
                Button {
                    isAddingRepository = true
                } label: {
                    Image(systemName: "plus")
                }
            }
        }
        .fileImporter(
            isPresented: $isAddingRepository,
            allowedContentTypes: [.folder],
            allowsMultipleSelection: false
        ) { result in
            if case .success(let urls) = result,
               let url = urls.first {
                Task {
                    let success = await appState.addRepository(at: url.path)
                    if !success {
                        // Could show an alert here
                        print("Not a valid Git repository: \(url.path)")
                    }
                }
            }
        }
    }
}

struct RepositoryRow: View {
    @Environment(AppState.self) private var appState
    let repository: Repository

    var body: some View {
        HStack {
            Image(systemName: "folder")
                .foregroundStyle(.orange)

            VStack(alignment: .leading, spacing: 2) {
                Text(repository.displayName)
                    .font(.body)

                Text(repository.path)
                    .font(.caption)
                    .foregroundStyle(.secondary)
                    .lineLimit(1)
            }

            Spacer()

            Toggle("", isOn: Binding(
                get: { repository.isEnabled },
                set: { _ in appState.toggleRepository(repository) }
            ))
            .toggleStyle(.switch)
        }
        .padding(.vertical, 4)
    }
}

#Preview {
    RepositoriesView()
        .environment(AppState())
        .frame(width: 600, height: 400)
}
