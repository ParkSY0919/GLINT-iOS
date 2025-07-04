//
//  FilterSliderView.swift
//  GLINT-iOS
//
//  Created by AI Assistant on 1/19/25.
//


import SwiftUI

struct FilterSliderView: View {
    let propertyType: FilterPropertyType
    let value: Float
    let isActive: Bool
    let onValueChanged: (Float) -> Void
    let onEditingEnded: (Float) -> Void
    
    @State private var sliderWidth: CGFloat = 0
    @State private var isDragging: Bool = false
    
    // 스타일 상수들
    private let handleSize: CGFloat = 16
    private let trackHeight: CGFloat = 4
    private let horizontalPadding: CGFloat = 20
    private let valueDisplayHeight: CGFloat = 24
    
    var body: some View {
        contentView
            .padding(.vertical, 8)
    }
}

private extension FilterSliderView {
    var contentView: some View {
        VStack(spacing: 16) {
            valueDisplaySection
            customSliderSection
        }
    }
    
    var valueDisplaySection: some View {
        GeometryReader { geometry in
            let position = getSliderPosition(in: geometry.size.width)
            
            valueLabel
                .position(x: position, y: 12)
        }
        .frame(height: valueDisplayHeight)
        .padding(.horizontal, horizontalPadding)
    }
    
    var valueLabel: some View {
        Text(formattedValue)
            .font(.pretendardFont(.caption_semi, size: 12))
            .foregroundColor(.brandDeep)
            .padding(.horizontal, 8)
            .padding(.vertical, 4)
            .background(.gray100)
            .clipShape(RoundedRectangle(cornerRadius: 4))
            .overlay(alignment: .bottom) {
                valueLabelTriangle
            }
    }
    
    var valueLabelTriangle: some View {
        Triangle()
            .fill(.gray100)
            .frame(width: 8, height: 4)
            .offset(y: 10)
    }
    
    var customSliderSection: some View {
        GeometryReader { geometry in
            sliderContent(geometry: geometry)
                .contentShape(Rectangle())
                .gesture(sliderDragGesture(geometry: geometry))
                .onAppear {
                    sliderWidth = geometry.size.width
                }
        }
        .frame(height: handleSize)
        .padding(.horizontal, horizontalPadding)
    }
    
    func sliderContent(geometry: GeometryProxy) -> some View {
        ZStack(alignment: .leading) {
            sliderTrackBackground
            sliderTrackFilled(geometry: geometry)
            sliderHandle(geometry: geometry)
        }
    }
    
    var sliderTrackBackground: some View {
        RoundedRectangle(cornerRadius: 2)
            .fill(.gray75)
            .frame(height: trackHeight)
    }
    
    func sliderTrackFilled(geometry: GeometryProxy) -> some View {
        let currentPosition = getSliderPosition(in: geometry.size.width)
        
        return RoundedRectangle(cornerRadius: 2)
            .fill(sliderGradient)
            .frame(width: currentPosition, height: trackHeight)
    }
    
    var sliderGradient: LinearGradient {
        LinearGradient(
            colors: [.sliderLeft, .sliderRight],
            startPoint: .leading,
            endPoint: .trailing
        )
    }
    
    func sliderHandle(geometry: GeometryProxy) -> some View {
        let currentPosition = getSliderPosition(in: geometry.size.width)
        
        return Circle()
            .fill(.brandDeep)
            .frame(width: handleSize, height: handleSize)
            .shadow(color: .black.opacity(0.2), radius: 2, x: 0, y: 1)
            .position(x: currentPosition, y: handleSize / 2)
    }
    
    func sliderDragGesture(geometry: GeometryProxy) -> some Gesture {
        DragGesture(minimumDistance: 0)
            .onChanged { gesture in
                handleDragChanged(gesture: gesture, geometry: geometry)
            }
            .onEnded { _ in
                handleDragEnded()
            }
    }
    
    func handleDragChanged(gesture: DragGesture.Value, geometry: GeometryProxy) {
        isDragging = true
        let newValue = calculateValue(from: gesture.location.x, width: geometry.size.width)
        onValueChanged(newValue)
    }
    
    func handleDragEnded() {
        _ = calculateValue(from: 0, width: sliderWidth) // 현재 값 계산
        onEditingEnded(value) // 최종 값 전달
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            isDragging = false
        }
    }
    
    // MARK: - Helper Methods
    
    func getSliderPosition(in width: CGFloat) -> CGFloat {
        let range = propertyType.range
        let normalizedValue = (value - range.lowerBound) / (range.upperBound - range.lowerBound)
        let usableWidth = width - handleSize
        return (CGFloat(normalizedValue) * usableWidth) + (handleSize / 2)
    }
    
    func getDefaultValuePosition(in width: CGFloat) -> CGFloat {
        let range = propertyType.range
        let defaultValue = propertyType.defaultValue
        let normalizedDefaultValue = (defaultValue - range.lowerBound) / (range.upperBound - range.lowerBound)
        let usableWidth = width - handleSize
        return (CGFloat(normalizedDefaultValue) * usableWidth) + (handleSize / 2)
    }
    
    var formattedValue: String {
        switch propertyType {
        case .temperature:
            return String(format: "%.0f", value)
        default:
            return String(format: "%.2f", value)
        }
    }
    
    func calculateValue(from xPosition: CGFloat, width: CGFloat) -> Float {
        let halfHandle = handleSize / 2
        let usableWidth = width - handleSize
        let clampedX = max(halfHandle, min(xPosition, width - halfHandle))
        let normalizedX = (clampedX - halfHandle) / usableWidth
        
        let range = propertyType.range
        let newValue = range.lowerBound + Float(normalizedX) * (range.upperBound - range.lowerBound)
        
        // Step에 맞춰 반올림
        let steppedValue = round(newValue / propertyType.step) * propertyType.step
        return max(range.lowerBound, min(range.upperBound, steppedValue))
    }
}
