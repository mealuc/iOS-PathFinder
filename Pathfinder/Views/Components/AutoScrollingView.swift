import SwiftUI

struct AutoScrollingView<Data, Content>: View where Data: Identifiable, Content: View {
    
    let items: [Data]
    let itemWidth: CGFloat
    @ViewBuilder let content: (Data) -> Content
    let scrollSpeed: CGFloat = 0.5
    let spacing: CGFloat = 8
    let scrollDuration: TimeInterval = 1.0 / 120.0
    
    @State private var scrollOffset: CGFloat = 0
    @State private var isScrolling: Bool = true
    @State private var timer: Timer?
    @State private var lastInteraction = Date()
    @State private var scrollProxy: ScrollViewProxy?
    
    @State private var totalOffset: CGFloat = 0
    @State private var itemsCopy: [Data] = []
    
    var scrollViewWidth: CGFloat {
        return CGFloat(items.count) * (itemWidth + spacing)
    }
    
    var body: some View {
        GeometryReader { geo in
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: spacing) {
                    ForEach(itemsCopy) { item in
                        content(item)
                            .frame(width: itemWidth)
                            .id(item.id)
                    }
                }
                .offset(x: totalOffset)
            }
            .onAppear {
                itemsCopy = items
                startAutoScroll()
            }
            .onChange(of: items.count) { _, _ in
                itemsCopy = items
            }
            .onDisappear {
                stopAutoScroll()
            }
            .simultaneousGesture(
                DragGesture(minimumDistance: 0)
                    .onChanged { _ in
                        handleUserInteraction()
                    }
            )
        }
    }

    func startAutoScroll() {
        stopAutoScroll()
        
        let newTimer = Timer.scheduledTimer(withTimeInterval: scrollDuration, repeats: true) { _ in
            guard isScrolling else {
                checkInteractionTimeout()
                return
            }
            
            DispatchQueue.main.async {
                withAnimation(.linear(duration: scrollDuration)) {
                    performScroll()
                }
            }
        }
        
        RunLoop.main.add(newTimer, forMode: .common)
        self.timer = newTimer
    }
    
    func stopAutoScroll() {
        timer?.invalidate()
        timer = nil
    }
    
    func handleUserInteraction() {
        isScrolling = false
        lastInteraction = Date()
    }
    
    func performScroll() {
        totalOffset -= scrollSpeed
        let thresholdItemWidth = -(itemWidth + spacing)
        if totalOffset <= thresholdItemWidth {
            totalOffset += itemWidth + spacing
            moveFirstItemToEnd()
        }
    
    }
    
    func checkInteractionTimeout() {
        let fiveSecondsAgo = Date().addingTimeInterval(-5.0)
        
        if lastInteraction < fiveSecondsAgo {
            isScrolling = true
        }
        
    }
    
    func moveFirstItemToEnd() {
        guard !itemsCopy.isEmpty else { return }
        var newItems = itemsCopy
        let first = newItems.removeFirst()
        newItems.append(first)
        itemsCopy = newItems
    }
}
