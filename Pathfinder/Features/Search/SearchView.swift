//
//  SearchView.swift
//  Pathfinder
//
//  Created by EmreAluc on 26.01.2025.
//

import SwiftUI

struct SearchView: View {
    @State private var searchText: String = ""
    var body: some View {
        VStack {
            TextField("Search", text: $searchText)
                .padding(.all, 12)
                .background(Color.gray.opacity(0.2))
                .cornerRadius(12)
                .frame(width: 350, height: 50)
            
            Text("\(searchText)")
            
            Spacer()
            
            Text("Hello, This is a search!")
            
            Spacer()
        }
    }
}

#Preview {
    SearchView()
}
