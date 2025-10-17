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
    @StateObject var addStoreService = AddStores()
    
    let productArray = ["Product 1", "Product 2", "Product 3", "Product 4", "Product 5", "Product 6", "Product 7", "Product 8"]
    var body: some View {
        VStack {
            
            Button("Add Dummy Store"){
                addStoreService.addStore()
            }
            
            Spacer()
            
            TextField("Search", text: $searchText)
                .padding(.all, 12)
                .background(Color.gray.opacity(0.2))
                .cornerRadius(12)
                .frame(width: 350, height: 50)
            
            Text("\(searchText)")
            
            AutoScrollingView(items: storeService.stores, itemWidth: 100) { storeData in
                Text(storeData.storeName)
                    .frame(width: 100, height: 75)
                    .background(Color.blue)
                    .foregroundColor(.white)
                    .cornerRadius(10)
                    .onTapGesture {
                        print("\(storeData.storeName) tıklandı, linke gidiliyor!")
                    }
            }
            .frame(height: 75)
            
            NavigationStack {
                VStack {
                    ScrollView(.vertical, showsIndicators: false) {
                        ForEach(productArray, id: \.self) { data in
                            NavigationLink ( destination: ProductDetailView(productName: data)) {
                                Text(data)
                                    .frame(width: 350, height: 75)
                                    .background(.blue)
                                    .cornerRadius(10)
                                    .foregroundStyle(.white)
                            }
                        }
                    }
                }
                .onAppear {
                    
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
