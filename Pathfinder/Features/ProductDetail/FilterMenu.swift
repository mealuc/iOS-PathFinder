import SwiftUI

enum filterType: String, CaseIterable {
    case distance = "Distance"
    case rating = "Rating"
    case amount = "Amount"
    case price = "Price"
}

struct FilterMenu: View {
    
    @Binding var isFilterOpen: Bool
    @Binding var selectedFilter: filterType
    var commonWidth: CGFloat
    
    var body: some View {
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
