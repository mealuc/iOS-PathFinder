//
//  DistanceSliderView.swift
//  Pathfinder
//
//  Created by EmreAluc on 6.01.2026.
//

import SwiftUI

struct DistanceSliderView: View {
    @Binding var distanceValue: Double

    
    var onAction: (Double) -> Void
    @State private var pendingFilteredDistance: DispatchWorkItem?
    @State private var isDragging = false
    @State private var valueX: Double = 0
    @State private var isAnimating: Bool = false
    @State private var loadingProgress: CGFloat = 0
    
    let range: ClosedRange<Double> = 500...10_000
    let step: Double = 500
    
    var body: some View {
        GeometryReader{ geometry in
            
            let width = geometry.size.width
            let percentage = (distanceValue - range.lowerBound) / (range.upperBound - range.lowerBound)
            let currentOffset = width * CGFloat(percentage)
            
            ZStack(alignment: .leading){
                
                RoundedRectangle(cornerRadius: 8)
                    .fill(Color.gray.opacity(0.3))
                    .frame(height: 6)
                
                RoundedRectangle(cornerRadius: 8)
                    .fill(Color.blue)
                    .frame(width: currentOffset, height: 6)
                
                CircularLoader(loadingProgress: $loadingProgress, isAnimating: $isAnimating)
                    .offset(x: currentOffset - 12)
                    .gesture(dragGesture(width: width))
                    /*
                    .overlay(alignment: .bottom){
                        if (isDragging){
                            toolTipView(offset: currentOffset)
                        }
                    }*/
            }
            .frame(maxHeight: .infinity)
        }
    }
    /*
    private func toolTipView(offset: CGFloat) -> some View {
        ZStack {
            RoundedRectangle(cornerRadius: 10)
                .fill(Color.black)
                .frame(width: 80, height: 40)
            
            Text("\(Int(distanceValue))m" )
                .foregroundColor(Color.white)
                .font(.caption)
                .fontWeight(.bold)
        }
        .offset(x: offset - 12, y: 45)
        .transition(.opacity)
    }
    */
    private func dragGesture(width: CGFloat) -> some Gesture{
        DragGesture()
            .onChanged { value in
                
                pendingFilteredDistance?.cancel()
                isDragging = true
                isAnimating = false
                loadingProgress = 0
                let currentX = value.location.x
                let limitedX = max(0, min(currentX, width))
                let ratioDistance = (limitedX / width)
                distanceValue = rounded((ratioDistance * (range.upperBound - range.lowerBound)) + range.lowerBound)
            }
            .onEnded{ _ in
                
                isDragging = false
                isAnimating = true
                withAnimation(.linear(duration: 1.0)) {
                    loadingProgress = 1.0
                }
                pendingFilteredDistance?.cancel()
                
                let request = DispatchWorkItem {
                    onAction(distanceValue)
                    isAnimating = false
                    loadingProgress = 0
                }
                pendingFilteredDistance = request
                DispatchQueue.main.asyncAfter(deadline: .now() + 1, execute: request)
            }
    }
    
    private func rounded (_ value: Double) -> Double {
        let stepped = (round(value / step)) * step
        return min(max(stepped, range.lowerBound), range.upperBound)
    }
}

#Preview {
    struct PreviewWrapper: View {
        @State var val: Double = 500
        var body: some View {
            DistanceSliderView(distanceValue: $val){ value in
                print("preview datası: \(value)")
            }
        }
    }
    return PreviewWrapper()
}

