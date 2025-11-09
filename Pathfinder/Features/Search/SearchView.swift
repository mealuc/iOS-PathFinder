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
    @State var filteredData: [Product] = []
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
                    .onChange(of: searchText) { _, newData in
                        Task {
                            await checkProduct(with: newData)
                        }
                    }
                
                AutoScrollingView(items: storeService.stores, itemWidth: 100) { storeData in
                    Text(storeData.storeName)
                        .padding()
                        .fixedSize()
                        .background(Color.blue)
                        .foregroundColor(.white)
                        .cornerRadius(10)
                }
                .frame(height: 75)
                
                VStack {
                    ScrollView(.vertical, showsIndicators: false) {
                        ForEach(searchText.isEmpty ? productService.products : filteredData, id: \.productId) { data in
                            NavigationLink ( destination: ProductDetailView(productName: data.productName, productId: data.productId)) {
                                Text(data.productName)
                                    .frame(width: 350, height: 75)
                                    .background(.blue)
                                    .cornerRadius(10)
                                    .foregroundStyle(.white)
                            }
                            .transition(.opacity.combined(with: .blurReplace))
                        }
                    }
                }
                .animation(.linear(duration: 0.4), value: searchText)
            }
            Spacer()
        }
        .onAppear {
            storeService.fetchStores()
            productService.fetchProducts()
        }
    }
    
    func checkProduct (with newData: String) async {
        if !newData.isEmpty {
            filteredData = productService.products.filter { $0.productName.localizedCaseInsensitiveContains(newData) }
        }
    }
}

#Preview {
    SearchView()
}
