//
//  AccountView.swift
//  Pathfinder
//
//  Created by EmreAluc on 26.01.2025.
//

import SwiftUI

struct AccountView: View {
    @EnvironmentObject var appState : AppState

    var body: some View {
        Text("Hello, \(appState.username.isEmpty ? "User" : appState.username)")
    }
}

#Preview {
    AccountView()
                .environmentObject(AppState())
}
