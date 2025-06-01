//
//  PathfinderApp.swift
//  Pathfinder
//
//  Created by EmreAluc on 13.01.2025.
//

import SwiftUI
import Firebase
import FirebaseCore

class AppState : ObservableObject {
    @Published var isLoggedIn: Bool = false
}

@main
struct PathfinderApp: App {
    @StateObject var appState = AppState()
    @UIApplicationDelegateAdaptor(AppDelegate.self) var delegate

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(appState)
        }
    }
}
