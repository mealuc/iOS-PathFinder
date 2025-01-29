//
//  ContentView.swift
//  Pathfinder
//
//  Created by EmreAluc on 13.01.2025.
//

import SwiftUI

class AppState : ObservableObject {
    @Published var isLoggedIn: Bool = false
    @Published var username: String = ""
}

struct ContentView: View {
    @StateObject var appState = AppState()
    
    var body: some View {
        
        Group {
            if !appState.isLoggedIn {
                LoginView()
            }
            else {
                Account()
            }
        }
        .environmentObject(appState)
    }
    
}

#Preview {
    ContentView()
}
