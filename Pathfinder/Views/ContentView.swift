//
//  ContentView.swift
//  Pathfinder
//
//  Created by EmreAluc on 13.01.2025.
//

import SwiftUI



struct ContentView: View {
    @EnvironmentObject var appState: AppState
    
    var body: some View {
        
        Group {
            if appState.isLoggedIn {
                Account()
            }
            else {
                LoginView()
            }
        }
    }
    
}

#Preview {
    ContentView()
}
