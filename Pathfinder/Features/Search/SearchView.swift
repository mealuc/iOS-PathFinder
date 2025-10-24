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
    @StateObject var productService = ProductService()
    @State var addStoreService = AddStores()
    @State var addProductService = AddProduct()
    @State var addProductStockService = AddProductStock()
    
    var body: some View {
        VStack {
            NavigationStack {
                Button("Add Dummy Store"){
                    addStoreService.addStore()
                }
                
                Button("Add Dummy Product"){
                    addProductService.addProduct()
                }
                
                Button("Add Dummy Stock"){
                    addProductStockService.prepareForAddingStock()
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
                
                VStack {
                    ScrollView(.vertical, showsIndicators: false) {
                        ForEach(productService.products) { data in
                            NavigationLink ( destination: ProductDetailView(productName: data.productName, productId: data.productId)) {
                                Text(data.productName)
                                    .frame(width: 350, height: 75)
                                    .background(.blue)
                                    .cornerRadius(10)
                                    .foregroundStyle(.white)
                            }
                        }
                    }
                }
            }
            Spacer()
        }
        .onAppear {
            storeService.fetchStores()
            productService.fetchProducts()
        }
    }
}

#Preview {
    SearchView()
}
