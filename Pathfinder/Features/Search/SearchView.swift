//
//  SearchView.swift
//  Pathfinder
//
//  Created by EmreAluc on 26.01.2025.
//

import SwiftUI

struct SearchView: View {
    @State private var searchText: String = ""
    @StateObject var storeService = StoreService()
    
    let productArray = ["Product 1", "Product 2", "Product 3", "Product 4", "Product 5", "Product 6", "Product 7", "Product 8"]
    let storeArray = ["Store 1", "Store 2", "Store 3", "Store 4"]
    var body: some View {
        VStack {
            TextField("Search", text: $searchText)
                .padding(.all, 12)
                .background(Color.gray.opacity(0.2))
                .cornerRadius(12)
                .frame(width: 350, height: 50)
            
            Text("\(searchText)")
            
            Spacer()
            
            ScrollView(.horizontal){
                HStack{
                    ForEach(storeService.stores) { data in
                        Text(data.storeName)
                            .frame(width: 150, height: 75)
                            .background(.blue)
                            .cornerRadius(10)
                    }
                }
            }
            // use List function for listing vertically. Also it has itself scrolling mechanism.
            ScrollView(.vertical) {
                ForEach(productArray, id: \.self) {data in
                    Text(data)
                        .frame(width: 350, height: 75)
                        .background(.blue)
                        .cornerRadius(10)
                }
            }
            Spacer()
        }
        .onAppear {
            storeService.fetchStores()
        }
    }
}

#Preview {
    SearchView()
}
