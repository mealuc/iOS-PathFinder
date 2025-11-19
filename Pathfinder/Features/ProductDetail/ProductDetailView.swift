import SwiftUI

struct ProductDetailView: View {
    let productName: String
    let productId: String
    let commonWidth: CGFloat = 350
    
    @State private var storeStocks: [Store] = []
    @State private var productStocks: [ProductStock] = []
    @State private var isLoading: Bool = true
    @State private var isFilterOpen: Bool = false
    @State private var selectedFilter: filterType = .distance
    @State private var errorMessage: String?
    @StateObject private var cameraPosition = CameraPosition()
    @StateObject private var mapService = MapService()
    @EnvironmentObject var favoriteService: FavoriteService

    private let stockFetcher = GetProductStock()
    private let storeFetcher = GetStockedStores()
    
    var body: some View {
        ZStack {
            VStack {
                Text(productName)
                    .frame(width: commonWidth, height: 45)
                    .background(.blue)
                    .cornerRadius(8)
                
                MapView(
                    storeStocks: storeStocks
                )
                .frame(width: commonWidth, height: 300)
                .background(.blue)
                .cornerRadius(8)
                
                ProductFilter(
                    commonWidth: commonWidth,
                    productStocks: productStocks,
                    storeStocks: storeStocks,
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
        .environmentObject(cameraPosition)
        .environmentObject(mapService)
    }
    
    func loadStocks() async {
        do{
            productStocks = try await stockFetcher.fetchStocks(for: productId)
            storeStocks = try await storeFetcher.fetchStores(for: productStocks)
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

