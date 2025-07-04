//
//  FilterSectionView.swift
//  GLINT-iOS
//
//  Created by AI Assistant on 1/19/25.
//

import SwiftUI
import NukeUI

struct FilterSectionView: View {
    @Binding var sliderPosition: Double
    let originalImageURL: String?
    let filteredImageURL: String?
    let onSliderChanged: (Double) -> Void
    
    var body: some View {
        VStack(spacing: 0) {
            beforeAfterImageView
            beforeAfterControlBar
            Divider()
                .frame(height: 1)
                .background(.gray90)
                .padding(.horizontal, 20)
                .padding(.top, 16)
        }
        .frame(height: 448)
    }
}

private extension FilterSectionView {
    var beforeAfterImageView: some View {
        GeometryReader { geometry in
            let imageWidth = geometry.size.width - 40
            let imageHeight: CGFloat = 384
            
            ZStack {
                // 원본 이미지 (배경 - Before)
                LazyImage(url: URL(string: originalImageURL ?? "")) { state in
                    lazyImageTransform(state) { image in
                        image
                            .aspectRatio(contentMode: .fill)
                            .frame(width: imageWidth, height: imageHeight)
                            .clipped()
                    }
                }
                .clipRectangle(12)
                
                // 필터 적용 이미지 (오버레이 - After)
                LazyImage(url: URL(string: filteredImageURL ?? "")) { state in
                    lazyImageTransform(state) { image in
                        image
                            .aspectRatio(contentMode: .fill)
                            .frame(width: imageWidth, height: imageHeight)
                            .clipped()
                    }
                }
                .clipRectangle(12)
                .mask(
                    Rectangle()
                        .frame(width: imageWidth * sliderPosition, height: imageHeight)
                        .offset(x: -imageWidth * (1 - sliderPosition) / 2)
                        .animation(.easeInOut(duration: 0.1), value: sliderPosition)
                )
                
                // 구분선
                Rectangle()
                    .frame(width: 2, height: imageHeight)
                    .foregroundColor(.gray0)
                    .shadow(color: .black.opacity(0.3), radius: 2, x: 0, y: 0)
                    .offset(x: imageWidth * sliderPosition - imageWidth / 2)
                    .animation(.easeInOut(duration: 0.1), value: sliderPosition)
            }
            .padding(.horizontal, 20)
            .gesture(
                DragGesture()
                    .onChanged { value in
                        let newPosition = (value.location.x - 20) / imageWidth
                        onSliderChanged(max(0, min(1, newPosition)))
                    }
            )
        }
        .frame(height: 384)
    }
    
    var beforeAfterControlBar: some View {
        HStack(spacing: 4) {
            Text("Before")
                .font(.pretendardFont(.caption_semi, size: 10))
                .foregroundColor(.gray60)
                .padding(.horizontal, 10)
                .padding(.vertical, 3)
                .background(.gray75)
                .clipShape(Capsule())
            
            GeometryReader { geometry in
                let trackWidth = geometry.size.width
                let handlePosition = trackWidth * sliderPosition
                
                ZStack(alignment: .leading) {
                    RoundedRectangle(cornerRadius: 2)
                        .frame(height: 4)
                        .foregroundColor(.gray.opacity(0.3))
                    
                    // 슬라이더 핸들
                    ZStack {
                        Images.Detail.divideBtn
                            .font(.system(size: 8, weight: .medium))
                            .foregroundColor(.gray60)
                    }
                    .offset(x: handlePosition - 12) // 핸들 중심을 맞추기 위해 -12
                    .animation(.easeInOut(duration: 0.1), value: sliderPosition)
                }
                .gesture(
                    DragGesture()
                        .onChanged { value in
                            let newPosition = value.location.x / trackWidth
                            onSliderChanged(max(0, min(1, newPosition)))
                        }
                )
            }
            .frame(height: 24)
            
            Text("After")
                .font(.pretendardFont(.caption_semi, size: 10))
                .foregroundColor(.gray60)
                .padding(.horizontal, 10)
                .padding(.vertical, 3)
                .background(.gray75)
                .clipShape(Capsule())
        }
        .padding(.horizontal, 20)
        .padding(.top, 12)
    }
} 
