//
//  RepositoriesSettingsView.swift
//  Developer1
//

import SwiftUI
import UniformTypeIdentifiers

struct RepositoriesSettingsView: View {
    @Environment(AppState.self) private var appState
    @State private var isAddingRepository = false

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            // List
            List {
                if appState.repositories.isEmpty {
                    Text("No repositories added")
                        .foregroundStyle(.secondary)
                } else {
                    ForEach(appState.repositories) { repo in
                        HStack {
                            Image(systemName: "folder")
                                .foregroundStyle(.orange)

                            VStack(alignment: .leading) {
                                Text(repo.displayName)
                                Text(repo.path)
                                    .font(.caption)
                                    .foregroundStyle(.secondary)
                                    .lineLimit(1)
                            }

                            Spacer()

                            Toggle("", isOn: Binding(
                                get: { repo.isEnabled },
                                set: { _ in appState.toggleRepository(repo) }
                            ))
                            .toggleStyle(.switch)
                        }
                    }
                    .onDelete { indexSet in
                        for index in indexSet {
                            appState.removeRepository(appState.repositories[index])
                        }
                    }
                }
            }
            .listStyle(.inset)

            Divider()

            // Buttons
            HStack {
                Button {
                    isAddingRepository = true
                } label: {
                    Image(systemName: "plus")
                }

                Button {
                    // Remove selected or last item
                    if let last = appState.repositories.last {
                        appState.removeRepository(last)
                    }
                } label: {
                    Image(systemName: "minus")
                }
                .disabled(appState.repositories.isEmpty)

                Spacer()
            }
            .padding(8)
        }
        .fileImporter(
            isPresented: $isAddingRepository,
            allowedContentTypes: [.folder],
            allowsMultipleSelection: false
        ) { result in
            if case .success(let urls) = result,
               let url = urls.first {
                Task {
                    _ = await appState.addRepository(at: url.path)
                }
            }
        }
    }
}

#Preview {
    RepositoriesSettingsView()
        .environment(AppState())
        .frame(width: 450, height: 300)
}
