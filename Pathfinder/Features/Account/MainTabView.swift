//
//  Account.swift
//  Pathfinder
//
//  Created by EmreAluc on 26.01.2025.
//

import SwiftUI

struct Account: View {
    var body: some View {
        TabView {
            
            SearchView()
                .tabItem {
                    Label("Search", systemImage: "magnifyingglass")
                }
            
            AccountView()
                .tabItem {
                    Label("Account", systemImage: "person.circle")
                }
        }
    }
}


#Preview {
    Account()
        .environmentObject(AppState())
}
