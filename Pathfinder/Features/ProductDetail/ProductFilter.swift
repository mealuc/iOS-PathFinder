import SwiftUI
import MapKit

struct ProductFilter: View {
    let commonWidth: CGFloat
    let productStocks: [ProductStock]
    let storeStocks: [Store]
    
    @State private var expandedItem: String? = nil
    @Binding var isFilterOpen: Bool
    @Binding var selectedFilter: filterType
    
    let productName: String
    //Map
    @EnvironmentObject var cameraPosition: CameraPosition
    @EnvironmentObject var mapService: MapService
    @State private var distanceFilter: [String: Double] = [:]
    //Favorite
    @State private var favoriteKeys: Set<String> = []
    @EnvironmentObject var favoriteService: FavoriteService
    //History
    @EnvironmentObject var historyService: HistoryService
    
    var storeMap: [String: Store] {
        Dictionary(uniqueKeysWithValues: storeStocks.map { ($0.storeId, $0) })
    }
    
    var filteredArray: [ProductStock] {
        switch selectedFilter {
        case .distance:
            return productStocks.sorted {
                let d1 = distanceFilter[$0.storeId] ?? 0.0
                let d2 = distanceFilter[$1.storeId] ?? 0.0
                return d1 < d2
            }
        case .rating:
            return productStocks.sorted {
                let r1 = storeMap[$0.storeId]?.storeRating ?? 0.0
                let r2 = storeMap[$1.storeId]?.storeRating ?? 0.0
                return r1 > r2
            }
        case .amount:
            return productStocks.sorted { $0.stockQuantity > $1.stockQuantity }
        case .price:
            return productStocks.sorted { $0.productPrice < $1.productPrice }
        }
    }
    
    var body: some View {
        
        HStack {
            Text("Filtered: \(selectedFilter.rawValue)")
                .lineLimit(1)
                .padding(.horizontal)
                .frame(height: 50)
                .background(.blue)
                .cornerRadius(8)
            
            Spacer()
            
            Button(action: {
                withAnimation(.spring()){
                    isFilterOpen = !isFilterOpen
                }
            }){
                Image(systemName: "line.3.horizontal.decrease.circle")
                    .font(.system(size: 25))
                    .frame(width: 100, height: 50)
            }
            .lineLimit(1)
            .background(.blue)
            .cornerRadius(8)
        }
        .frame(width: commonWidth)
        .onChange(of: storeStocks){
            Task {
                await mapService.getUserLocation()
                if let _ = mapService.userLocation {
                    distanceFilter = await mapService.calculateDistances(for: storeStocks)
                } else {
                    print("User location not ready yet.")
                }
            }
        }
        
        if !productStocks.isEmpty{
            ScrollView(.vertical, showsIndicators: false) {
                
                ForEach(filteredArray, id: \.id) { data in
                    let storeId = data.storeId
                    let storeStockPrice = String(format: "%.2f", data.productPrice)
                    let stockCount = data.stockQuantity
                    let storeData = storeMap[storeId]
                    let storeRating = String(format: "%.1f", storeData?.storeRating ?? 0.0)
                    let storeDistance = distanceFilter[storeId] ?? 0.0
                    let storeName = storeData?.storeName ?? "Store"
                    let storeLatitude = storeData?.storeLatitude ?? 0.0
                    let storeLongitude = storeData?.storeLongitude ?? 0.0
                    let favoriteKey = "\(favoriteService.currentUserId ?? "")#\(storeId)#\(data.productId)"
                    
                    Button(action: {
                        withAnimation(.easeInOut){
                            expandedItem = (expandedItem == storeId) ? nil : storeId
                        }
                    }){
                        Text(storeName)
                            .frame(width: commonWidth, height: 50)
                    }
                    .background(.blue)
                    .cornerRadius(8)
                    .foregroundStyle(expandedItem == storeId ? .black : .white)
                    
                    if expandedItem == storeId {
                        ZStack(alignment: .topTrailing) {
                            VStack(alignment: .leading, spacing: 8) {
                                Text("""
                                    Price: \(storeStockPrice) ₺
                                    Stock: \(stockCount)
                                    Estimated Distance: \(storeDistance, specifier: "%.0f") m
                                    """)
                                .multilineTextAlignment(.leading)
                                .foregroundColor(.white)
                                
                                Spacer()
                                
                                HStack {
                                    Button(action: {
                                        Task {
                                            if let region = await mapService.getDirections(
                                                to: CLLocationCoordinate2D(latitude: storeLatitude, longitude: storeLongitude)
                                            ) {
                                                withAnimation(.easeInOut(duration: 0.4)) {
                                                    cameraPosition.cameraPosition = .region(region)
                                                }
                                            }
                                            
                                            historyService.addToHistory(
                                                productId: data.productId,
                                                storeId: storeId,
                                                productName: productName,
                                                storeName: storeName,
                                                stockPrice: data.productPrice
                                            )
                                        }
                                    }) {
                                        Image(systemName: "location.fill")
                                            .font(.system(size: 18))
                                            .foregroundColor(.white)
                                            .frame(height: 40)
                                            .frame(maxWidth: .infinity)
                                            .background(Color.green)
                                            .cornerRadius(8)
                                    }
                                    
                                    Button(action: {
                                        Task {
                                            if favoriteKeys.contains(favoriteKey) {
                                                do {
                                                    let removedKey = try await favoriteService.removeFavorite(storeId: storeId, productId: data.productId)
                                                    favoriteKeys.remove(removedKey)
                                                } catch {
                                                    print("Error when removing favorite", error)
                                                }
                                            } else {
                                                do {
                                                    let addedKey = try await favoriteService.addFavorite(
                                                        storeId: storeId,
                                                        productId: data.productId,
                                                        stockQuantity: stockCount,
                                                        productPrice: data.productPrice,
                                                        storeRating: storeData?.storeRating ?? 0.0,
                                                        storeName: storeName,
                                                        productName: productName
                                                    )
                                                    favoriteKeys.insert(addedKey)
                                                } catch {
                                                    print("error adding favorite", error)
                                                }
                                            }
                                        }
                                        
                                    }) {
                                        Image(systemName: favoriteKeys.contains(favoriteKey) ? "heart.fill" : "heart")
                                            .font(.system(size: 18))
                                            .foregroundColor(favoriteKeys.contains(favoriteKey) ? .red : .white)
                                            .frame(height: 40)
                                            .padding(.horizontal)
                                            .background(Color.white.opacity(0.1))
                                            .cornerRadius(6)
                                    }
                                }
                                .padding(.bottom, 6)
                            }
                            .padding()
                            .frame(width: commonWidth)
                            .background(Color.black.opacity(0.5))
                            .cornerRadius(8)
                            .padding(.horizontal, 10)
                            .padding(.bottom, 10)
                            
                            HStack(spacing: 4) {
                                Image(systemName: "star.fill")
                                    .font(.system(size: 15))
                                    .foregroundColor(.yellow)
                                Text("\(storeRating)")
                                    .font(.subheadline)
                                    .foregroundColor(.white)
                            }
                            .padding(.top, 16)
                            .padding(.trailing, 24)
                        }
                        .frame(width: commonWidth)
                        .cornerRadius(8)
                    }
                    
                }
            }
            .onAppear {
                Task {
                    favoriteKeys = Set(favoriteService.userFavorites.map {"\(favoriteService.currentUserId ?? "")#\($0.storeId)#\($0.productId)"})
                }
            }
            
        } else {
            Text("No products available")
                .frame(maxWidth: commonWidth, alignment: .init(horizontal: .center, vertical: .center))
                .padding(20)
                .cornerRadius(8)
                .foregroundColor(.red)
        }
    }
}


#Preview {
    ProductDetailView(productName: "Test Ürün", productId: "5CCB3AE8-4791-4B83-9498-82AE71BECACE")
        .environmentObject(FavoriteService())
        .environmentObject(HistoryService())
}
