//
//  Developer1App.swift
//  Developer1
//
//  Created by 김민성 on 1/13/26.
//

import SwiftUI

@main
struct Developer1App: App {
    @State private var appState = AppState()

    var body: some Scene {
        // Main Window
        WindowGroup {
            MainWindowView()
                .environment(appState)
        }
        .windowStyle(.titleBar)
        .windowToolbarStyle(.unified)
        .defaultSize(width: 900, height: 600)
        .commands {
            CommandGroup(replacing: .appSettings) {
                Button("Settings...") {
                    openSettings()
                }
                .keyboardShortcut(",", modifiers: .command)
            }
        }

        // Menu Bar
        MenuBarExtra {
            MenuBarView()
                .environment(appState)
        } label: {
            Label("Developer1", systemImage: "chevron.left.forwardslash.chevron.right")
        }
        .menuBarExtraStyle(.window)

        // Settings Window
        Settings {
            SettingsView()
                .environment(appState)
        }
    }

    private func openSettings() {
        NSApp.sendAction(Selector(("showSettingsWindow:")), to: nil, from: nil)
    }
}
