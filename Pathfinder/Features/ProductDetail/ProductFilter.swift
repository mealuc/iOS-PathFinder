import SwiftUI
import MapKit

struct ProductFilter: View {
    let commonWidth: CGFloat
    let productStocks: [ProductStock]
    let storeStocks: [Store]
    
    @State private var expandedItem: String? = nil
    @Binding var isFilterOpen: Bool
    @Binding var selectedFilter: filterType
    @EnvironmentObject var cameraPosition: CameraPosition
    @EnvironmentObject var mapService: MapService
    @State private var distanceFilter: [String: Double] = [:]
    
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
                Text("Filter")
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
                    .foregroundStyle(expandedItem == storeId ? .yellow : .white)
                    
                    if expandedItem == storeId {
                        VStack() {
                            Text("""
                                Price: \(storeStockPrice) ₺
                                Stock: \(stockCount)
                                Rating: \(storeRating)
                                Distance: \(storeDistance, specifier: "%.0f") m
                                """)
                            .multilineTextAlignment(.leading)
                            .transition(.opacity.combined(with: .move(edge: .top)))
                            .multilineTextAlignment(.leading)
                            
                            Button(action: {
                                Task {
                                    if let region = await mapService.getDirections(to: CLLocationCoordinate2D(latitude: storeLatitude, longitude: storeLongitude)
                                    ) {
                                        withAnimation(.easeInOut(duration: 0.4)) {
                                            cameraPosition.cameraPosition = .region(region)
                                        }
                                    }
                                }
                            }) {
                                Image(systemName: "arrow.turn.down.right")
                                    .frame(width: 100, height: 30)
                                    .padding(5)
                                    .background(.green)
                                    .cornerRadius(8)
                            }
                            
                        }
                        .frame(width: commonWidth)
                        .padding()
                        .background(Color.black.opacity(0.5))
                        .cornerRadius(8)
                        .padding([.leading, .trailing, .bottom], 10)
                        .padding(.top, 1)
                    }
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
