import SwiftUI

struct ProductDetailView: View {
    let productName: String
    let productArray = ["Location 1", "Location 2", "Location 3", "Location 4", "Location 5"]
    let commonWidth: CGFloat = 350
    
    @State private var isFilterOpen: Bool = false
    @State private var selectedFilter: filterType = .distance

    
    var body: some View {
        ZStack {
            VStack {
                Text(productName)
                    .frame(width: commonWidth, height: 25)
                    .background(.blue)
                    .cornerRadius(8)
                
                Text("Map")
                    .frame(width: commonWidth, height: 300)
                    .background(.blue)
                    .cornerRadius(8)
                
                ProductFilter(
                    commonWidth: commonWidth,
                    productArray: productArray,
                    isFilterOpen: $isFilterOpen,
                    selectedFilter: $selectedFilter
                )
            }
            .foregroundStyle(.white)
            .blur(radius: isFilterOpen ? 3 : 0)
            .onTapGesture {
                withAnimation(.spring()){
                    isFilterOpen = false
                }
            }
            
            if isFilterOpen {
                FilterMenu(
                    isFilterOpen: $isFilterOpen,
                    selectedFilter: $selectedFilter,
                    commonWidth: commonWidth
                )
            }
        }
    }
}

#Preview {
    ProductDetailView(productName: "Test Ürün")
}

