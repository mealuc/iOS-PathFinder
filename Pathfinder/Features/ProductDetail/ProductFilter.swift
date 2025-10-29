import SwiftUI

struct ProductFilter: View {
    let commonWidth: CGFloat
    let productStocks: [ProductStock]
    let productArray: [String]
    
    @State private var expandedItem: String? = nil
    @Binding var isFilterOpen: Bool
    @Binding var selectedFilter: filterType
    
    var filteredArray: [String] {
        switch selectedFilter {
        case .distance:
            return productArray.sorted()
        case .rating:
            return productArray.reversed()
        case .amount:
            return productArray.sorted()
        case .price:
            return productArray
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
        if !productStocks.isEmpty{
            ScrollView(.vertical, showsIndicators: false) {
                
                ForEach(productStocks, id: \.id) { data in
                    let storeId = data.storeId
                    let storeName = data.storeName
                    
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
                        Text("Price: \(data.productPrice) ₺\n" + "Stock: \(data.stockQuantity)")
                            .frame(width: commonWidth, height: .infinity)
                            .multilineTextAlignment(.leading)
                            .padding()
                            .background(Color.black.opacity(0.5))
                            .cornerRadius(8)
                            .transition(.opacity.combined(with: .move(edge: .top)))
                            .multilineTextAlignment(.leading)
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
