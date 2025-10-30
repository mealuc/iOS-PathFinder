import SwiftUI

struct ProductDetailView: View {
    let productName: String
    let productId: String
    let productArray = ["Location 1", "Location 2", "Location 3", "Location 4", "Location 5"]
    let commonWidth: CGFloat = 350
    
    @State private var storeStocks: [Store] = []
    @State private var productStocks: [ProductStock] = []
    @State private var isLoading: Bool = true
    @State private var isFilterOpen: Bool = false
    @State private var selectedFilter: filterType = .distance
    @State private var errorMessage: String?
    
    private let stockFetcher = GetProductStock()
    private let storeFetcher = GetStockedStores()
    
    var body: some View {
        ZStack {
            VStack {
                Text(productName)
                    .frame(width: commonWidth, height: 25)
                    .background(.blue)
                    .cornerRadius(8)
                
                MapView(
                    storeStocks: storeStocks
                )
                .frame(width: commonWidth, height: 400)
                .background(.blue)
                .cornerRadius(8)
                
                ProductFilter(
                    commonWidth: commonWidth,
                    productStocks: productStocks,
                    storeStocks: storeStocks,
                    productArray: productArray,
                    isFilterOpen: $isFilterOpen,
                    selectedFilter: $selectedFilter
                )
            }
            .onAppear() {
                Task {
                    await loadStocks()
                }
            }
            .foregroundStyle(.white)
            
            if isFilterOpen {
                FilterMenuModal(
                    isFilterOpen: $isFilterOpen,
                    selectedFilter: $selectedFilter,
                    commonWidth: commonWidth
                )
            }
        }
    }
    
    func loadStocks() async {
        do{
            let stockResult = try await stockFetcher.fetchStocks(for: productId)
            let storeResult = try await storeFetcher.fetchStores(for: stockResult)
            productStocks = stockResult
            storeStocks = storeResult
            isLoading = false
        } catch {
            errorMessage = error.localizedDescription
            isLoading = false
            print("Error on loading stocks: ", errorMessage as Any)
        }
    }
}

#Preview {
    ProductDetailView(productName: "Test Ürün", productId: "5CCB3AE8-4791-4B83-9498-82AE71BECACE")
}

