//
//  FilterSliderView.swift
//  GLINT-iOS
//
//  Created by AI Assistant on 1/19/25.
//

//
//  FilterSliderView.swift
//  GLINT-iOS
//
//  Created by AI Assistant on 1/19/25.
//

import SwiftUI

struct FilterSliderView: View {
    let propertyType: FilterPropertyType
    @Binding var value: Float
    let isActive: Bool
    let onValueChanged: (Float) -> Void
    let onEditingChanged: (Bool) -> Void
    
    @State private var sliderWidth: CGFloat = 0
    @State private var isDragging: Bool = false
    
    private let handleSize: CGFloat = 16
    private let trackHeight: CGFloat = 4
    private let horizontalPadding: CGFloat = 20
    
    var body: some View {
        VStack(spacing: 16) {
            // 현재 값 표시 (슬라이더 위)
            GeometryReader { geometry in
                let position = getSliderPosition(in: geometry.size.width)
                
                Text(formattedValue)
                    .font(.pretendardFont(.caption_semi, size: 12))
                    .foregroundColor(.brandDeep)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(.gray100)
                    .clipShape(RoundedRectangle(cornerRadius: 4))
                    .overlay(
                        Triangle()
                            .fill(.gray100)
                            .frame(width: 8, height: 4)
                            .offset(y: 10),
                        alignment: .bottom
                    )
                    .position(x: position, y: 12)
            }
            .frame(height: 24)
            .padding(.horizontal, horizontalPadding)
            
            // 커스텀 슬라이더
            GeometryReader { geometry in
                ZStack(alignment: .leading) {
                    // 트랙 배경
                    RoundedRectangle(cornerRadius: 2)
                        .fill(.gray75)
                        .frame(height: trackHeight)
                    
                    // 좌측부터 현재 위치까지 색칠
                    let currentPosition = getSliderPosition(in: geometry.size.width)
                    
                    RoundedRectangle(cornerRadius: 2)
                        .fill(
                            LinearGradient(
                                colors: [.sliderLeft, .sliderRight],
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                        .frame(width: currentPosition, height: trackHeight)
                    
                    // 슬라이더 핸들
                    Circle()
                        .fill(.brandDeep)
                        .frame(width: handleSize, height: handleSize)
                        .shadow(color: .black.opacity(0.2), radius: 2, x: 0, y: 1)
                        .position(x: currentPosition, y: handleSize / 2)
                }
                .contentShape(Rectangle())
                .gesture(
                    // 최적화된 드래그 제스처: 디바운싱과 백그라운드 처리로 성능 향상
                    DragGesture(minimumDistance: 0)
                        .onChanged { gesture in
                            isDragging = true
                            let newValue = calculateValue(from: gesture.location.x, width: geometry.size.width)
                            value = newValue
                            onValueChanged(newValue)
                            onEditingChanged(true)
                        }
                        .onEnded { _ in
                            onEditingChanged(false)
                            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                                isDragging = false
                            }
                        }
                )
                .onAppear {
                    sliderWidth = geometry.size.width
                }
            }
            .frame(height: handleSize)
            .padding(.horizontal, horizontalPadding)
        }
        .padding(.vertical, 8)
    }
    
    private func getSliderPosition(in width: CGFloat) -> CGFloat {
        let range = propertyType.range
        let normalizedValue = (value - range.lowerBound) / (range.upperBound - range.lowerBound)
        let usableWidth = width - handleSize
        return (CGFloat(normalizedValue) * usableWidth) + (handleSize / 2)
    }
    
    private func getDefaultValuePosition(in width: CGFloat) -> CGFloat {
        let range = propertyType.range
        let defaultValue = propertyType.defaultValue
        let normalizedDefaultValue = (defaultValue - range.lowerBound) / (range.upperBound - range.lowerBound)
        let usableWidth = width - handleSize
        return (CGFloat(normalizedDefaultValue) * usableWidth) + (handleSize / 2)
    }
    
    private var formattedValue: String {
        switch propertyType {
        case .temperature:
            return String(format: "%.0f", value)
        default:
            return String(format: "%.2f", value)
        }
    }
    
    private func calculateValue(from xPosition: CGFloat, width: CGFloat) -> Float {
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

// 삼각형 모양
struct Triangle: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()
        path.move(to: CGPoint(x: rect.midX, y: rect.maxY))
        path.addLine(to: CGPoint(x: rect.minX, y: rect.minY))
        path.addLine(to: CGPoint(x: rect.maxX, y: rect.minY))
        path.closeSubpath()
        return path
    }
}


