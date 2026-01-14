//
//  MainWindowView.swift
//  Developer1
//

import SwiftUI

enum SidebarItem: String, CaseIterable, Identifiable {
    case dashboard = "Dashboard"
    case commits = "Commits"
    case pullRequests = "Pull Requests"
    case repositories = "Repositories"

    var id: String { rawValue }

    var icon: String {
        switch self {
        case .dashboard: return "square.grid.2x2"
        case .commits: return "arrow.triangle.branch"
        case .pullRequests: return "arrow.triangle.pull"
        case .repositories: return "folder"
        }
    }
}

struct MainWindowView: View {
    @Environment(AppState.self) private var appState
    @State private var selectedItem: SidebarItem = .dashboard

    var body: some View {
        NavigationSplitView {
            List(SidebarItem.allCases, selection: $selectedItem) { item in
                Label(item.rawValue, systemImage: item.icon)
                    .tag(item)
            }
            .listStyle(.sidebar)
            .navigationSplitViewColumnWidth(min: 180, ideal: 200)
        } detail: {
            switch selectedItem {
            case .dashboard:
                DashboardView()
            case .commits:
                CommitsListView()
            case .pullRequests:
                PRListView()
            case .repositories:
                RepositoriesView()
            }
        }
        .toolbar {
            ToolbarItem(placement: .primaryAction) {
                Button {
                    Task { await appState.refresh() }
                } label: {
                    if appState.isRefreshing {
                        ProgressView()
                            .scaleEffect(0.7)
                    } else {
                        Image(systemName: "arrow.clockwise")
                    }
                }
                .disabled(appState.isRefreshing)
                .help("Refresh")
            }
        }
        .task {
            if appState.lastRefreshed == nil {
                await appState.refresh()
            }
        }
    }
}

#Preview {
    MainWindowView()
        .environment(AppState())
}
