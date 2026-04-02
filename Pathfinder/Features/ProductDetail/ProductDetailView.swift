import SwiftUI
import CoreLocation

struct ProductDetailView: View {
    let productName: String
    let productId: String
    let commonWidth: CGFloat = 350
    
    @State private var storeStocks: [Store] = []
    @State private var productStocks: [ProductStock] = []
    @State private var allProductStocks: [ProductStock] = []
    @State private var isLoading: Bool = true
    @State private var isFilterOpen: Bool = false
    @State private var selectedFilter: filterType = .distance
    @State private var errorMessage: String?
    @State var distanceValue: Double = 500
    @StateObject private var cameraPosition = CameraPosition()
    @StateObject private var mapService = MapService()
    @StateObject private var historyService = HistoryService()
    @EnvironmentObject var favoriteService: FavoriteService

    private let stockStoreFetcher = StoreStockService()
    
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
                
                DistanceSliderView(distanceValue: $distanceValue){ filteredDistance in
                    Task {
                        guard let userLocation = mapService.userLocation else {
                            print("User location has not been found yet")
                            return
                        }
                        do {
                            try await fetchStockAndStores(near: userLocation, radiusMeters: filteredDistance)
                        } catch {
                            print("Slider filter error!: \(error.localizedDescription)")
                        }
                    }
                }
                    .frame(width: commonWidth, height: 45)
                    .zIndex(1)
                
                ProductFilter(
                    commonWidth: commonWidth,
                    productStocks: productStocks,
                    storeStocks: storeStocks,
                    isFilterOpen: $isFilterOpen,
                    selectedFilter: $selectedFilter,
                    productName: productName
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
        .environmentObject(historyService)
    }
    
    func loadStocks() async {
        do{
            await mapService.getUserLocation()
            guard let userLocation = mapService.userLocation else { return }
            try await fetchStockAndStores(near: userLocation, radiusMeters: 500)
            isLoading = false
        } catch {
            errorMessage = error.localizedDescription
            isLoading = false
            print("Error on loading stocks: ", errorMessage as Any)
        }
    }
    
    func fetchStockAndStores(near userLocation: CLLocationCoordinate2D, radiusMeters: Double) async throws {
        let fetchedStores = try await stockStoreFetcher.fetchStores(near: userLocation, radiusMeters: radiusMeters)
        
        let userCoords = CLLocation(latitude: userLocation.latitude, longitude: userLocation.longitude)
        let trimmedStores = fetchedStores.filter {
            let storeCoords = CLLocation(latitude: $0.storeLatitude, longitude: $0.storeLongitude)
            return storeCoords.distance(from: userCoords) <= radiusMeters
        }
        
        let storeIds = trimmedStores.map { $0.storeId }
        let fetchedStocks = try await stockStoreFetcher.fetchStocks(for: productId, in: storeIds)
        let stockedStoreIds = Set(fetchedStocks.map{ $0.storeId })
        
        storeStocks = fetchedStores.filter { stockedStoreIds.contains($0.storeId) }
        productStocks = fetchedStocks
        allProductStocks = fetchedStocks
    }
}

#Preview {
    ProductDetailView(productName: "Test Ürün", productId: "5CCB3AE8-4791-4B83-9498-82AE71BECACE")
        .environmentObject(FavoriteService())
        .environmentObject(HistoryService())
}

