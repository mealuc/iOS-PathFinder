import SwiftUI

enum filterType: String, CaseIterable {
    case distance = "Distance"
    case rating = "Rating"
    case amount = "Amount"
    case price = "Price"
}

struct ProductDetailView: View {
    let productName: String
    let productArray = ["Location 1", "Location 2", "Location 3", "Location 4", "Location 5"]
    let commonWidth: CGFloat = 350
    
    @State private var expandedItem: String? = nil
    @State private var isFilterOpen: Bool = false
    @State private var selectedFilter: filterType = .distance
    
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
                    ForEach(productArray, id: \.self) { data in
                        Button(action: {
                            withAnimation(.easeInOut){
                                expandedItem = (expandedItem == data) ? nil : data
                            }
                        }){
                            Text(data)
                                .frame(width: commonWidth, height: 50)
                        }
                        .background(.blue)
                        .cornerRadius(8)
                        .foregroundStyle(expandedItem == data ? .yellow : .white)
                        if expandedItem == data {
                            Text("\(data) Detail")
                                .frame(width: commonWidth, height: .infinity)
                                .padding()
                                .background(Color.red.opacity(0.2))
                                .cornerRadius(8)
                                .transition(.opacity.combined(with: .move(edge: .top)))
                        }
                    }
                }
            }
            .foregroundStyle(.white)
            .blur(radius: isFilterOpen ? 3 : 0)
            .onTapGesture {
                withAnimation(.spring()){
                    isFilterOpen = false
                }
            }
            
            if isFilterOpen {
                VStack(spacing: 10){
                    ForEach (filterType.allCases, id: \.self){ type in
                        Button(type.rawValue){
                            withAnimation(.spring()){
                                selectedFilter = type
                                isFilterOpen = false
                            }
                        }
                    }
                }
                .padding(.vertical, 10)
                .frame(width: commonWidth / 2, height: .infinity)
                .background(Color.blue)
                .cornerRadius(8)
                .shadow(radius: 10)
                .foregroundColor(.white)
                .padding(.leading, 190)
                .padding(.top, 40)
                .zIndex(1)
                .padding(.trailing)
                .transition(.opacity.combined(with: .move(edge: .trailing)))
            }
        }
    }
}

#Preview {
    ProductDetailView(productName: "Test Ürün")
}
