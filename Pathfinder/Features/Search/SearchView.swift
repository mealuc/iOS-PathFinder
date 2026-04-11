//
//  SearchView.swift
//  Pathfinder
//
//  Created by EmreAluc on 26.01.2025.
//

import SwiftUI

struct SearchView: View {
    @State private var searchText: String = ""
    @State private var selectedProductId: String? = nil
    @StateObject var storeService = StoreService()
    @StateObject var productService = ProductService()
    @State var filteredData: [Product] = []
    @EnvironmentObject var mapService: MapService
    
    var body: some View {
        VStack {
            Spacer()
            
            TextField("Search", text: $searchText)
                .padding(.all, 12)
                .background(Color.gray.opacity(0.2))
                .cornerRadius(12)
                .frame(width: 350, height: 50)
                .onChange(of: searchText) { _, newData in
                    Task { await checkProduct(with: newData) }
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
                        Button {
                            selectedProductId = data.productId
                        } label: {
                            Text(data.productName)
                                .frame(width: 350, height: 75)
                                .background(.blue)
                                .cornerRadius(10)
                                .foregroundStyle(.white)
                        }
                        .transition(.opacity.combined(with: .blurReplace))
                    }
                }
                if productService.products.isEmpty {
                    Text("No Products").padding().fixedSize().cornerRadius(10)
                }
                if productService.hasMoreProducts {
                    Button("Load More Products") { productService.fetchMoreProducts() }
                }
            }
            .animation(.linear(duration: 0.4), value: searchText)
            Spacer()
        }
        .navigationDestination(isPresented: Binding(
            get: { selectedProductId != nil },
            set: { if !$0 {
                mapService.storeStocks = []
                mapService.productStocks = []
                mapService.cachedStores = []
                mapService.cachedStocks = []
                mapService.maxFetchedDistance = 0
                mapService.distanceValue = 500
                mapService.route = nil
                selectedProductId = nil
            }}
        )) {
            if let productId = selectedProductId,
               let product = (productService.products + filteredData).first(where: { $0.productId == productId }) {
                ProductDetailView(productName: product.productName, productId: productId)
            }
        }
        .onAppear {
            storeService.fetchStores()
            productService.fetchProducts()
        }
    }
    
    func checkProduct(with newData: String) async {
        if !newData.isEmpty {
            filteredData = productService.products.filter { $0.productName.localizedCaseInsensitiveContains(newData) }
        }
    }
}

#Preview {
    SearchView()
}
