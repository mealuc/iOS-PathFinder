//
//  Account.swift
//  Pathfinder
//
//  Created by EmreAluc on 26.01.2025.
//

import SwiftUI

struct MainTabView: View {
    @StateObject private var mapService = MapService()
    
    var body: some View {
        TabView {
            NavigationStack {
                SearchView()
            }
            .tabItem {
                Label("Search", systemImage: "magnifyingglass")
            }
            
            AccountView()
                .tabItem {
                    Label("Account", systemImage: "person.circle")
                }
        }
        .environmentObject(mapService)
    }
}


#Preview {
    MainTabView()
        .environmentObject(AppState())
}
