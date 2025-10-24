import SwiftUI

struct ProductDetailView: View {
    let productName: String
    let productId: String
    let productArray = ["Location 1", "Location 2", "Location 3", "Location 4", "Location 5"]
    let commonWidth: CGFloat = 350
    
    @State private var productStocks: [ProductStock] = []
    @State private var isLoading: Bool = true
    @State private var isFilterOpen: Bool = false
    @State private var selectedFilter: filterType = .distance
    @State private var errorMessage: String?
    
    private let stockFetcher = GetProductStock()
    
    var body: some View {
        ZStack {
            VStack {
                Text(productName)
                    .frame(width: commonWidth, height: 25)
                    .background(.blue)
                    .cornerRadius(8)
                
                MapView()
                    .frame(width: commonWidth, height: 400)
                    .background(.blue)
                    .cornerRadius(8)
                
                ProductFilter(
                    commonWidth: commonWidth,
                    productStocks: productStocks,
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
            let result = try await stockFetcher.fetchStocks(for: productId)
            productStocks = result
            isLoading = false
        } catch {
            errorMessage = error.localizedDescription
            isLoading = false
        }
    }
}

#Preview {
    ProductDetailView(productName: "Test Ürün", productId: "ABC1")
}

