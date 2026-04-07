import SwiftUI

struct CircularLoader: View {
    
    @Binding var loadingProgress: CGFloat
    @Binding var isAnimating: Bool
    
    var body: some View {
        Circle()
            .stroke(Color.black.opacity(0.3))
            .fill(Color.white)
            .frame(width: 24, height: 24)
            .shadow(radius: 6)
            .overlay {
                if isAnimating {
                    Circle()
                        .trim(from: 0, to: loadingProgress)
                        .stroke(Color.blue, lineWidth: 3)
                        .frame(width: 28, height: 28)
                        .rotationEffect(Angle(degrees: -90))
                }
            }
    }
}
