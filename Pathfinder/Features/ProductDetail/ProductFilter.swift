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
        
        ScrollView(.vertical, showsIndicators: false) {
            ForEach(productStocks, id: \.id) { data in
                let storeId = data.storeId
                
                Button(action: {
                    withAnimation(.easeInOut){
                        expandedItem = (expandedItem == storeId) ? nil : storeId
                    }
                }){
                    Text(storeId)
                        .frame(width: commonWidth, height: 50)
                }
                .background(.blue)
                .cornerRadius(8)
                .foregroundStyle(expandedItem == storeId ? .yellow : .white)
                
                if expandedItem == storeId {
                    Text("\(storeId) Detail")
                        .frame(width: commonWidth, height: .infinity)
                        .padding()
                        .background(Color.red.opacity(0.2))
                        .cornerRadius(8)
                        .transition(.opacity.combined(with: .move(edge: .top)))
                }
            }
        }
    }
}
