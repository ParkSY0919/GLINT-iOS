//
//  ChatImageDetailView.swift
//  GLINT-iOS
//
//  Created by 박신영 on 7/8/25.
//

import SwiftUI

struct ChatImageDetailView: View {
    let imageUrls: [String]
    let initialIndex: Int
    @Environment(\.dismiss) private var dismiss
    
    @State private var currentIndex: Int
    @State private var scale: CGFloat = 1.0
    @State private var lastScale: CGFloat = 1.0
    @State private var offset: CGSize = .zero
    @State private var lastOffset: CGSize = .zero
    
    init(imageUrls: [String], initialIndex: Int) {
        self.imageUrls = imageUrls
        self.initialIndex = initialIndex
        self._currentIndex = State(initialValue: initialIndex)
    }
    
    var body: some View {
        ZStack {
            Color.black
                .ignoresSafeArea()
            
            VStack {
                // 상단 헤더
                headerView
                
                Spacer()
                
                // 이미지 뷰
                TabView(selection: $currentIndex) {
                    ForEach(imageUrls.indices, id: \.self) { index in
                        zoomableImageView(url: imageUrls[index])
                            .tag(index)
                    }
                }
                .tabViewStyle(PageTabViewStyle(indexDisplayMode: .never))
                .animation(.easeInOut, value: currentIndex)
                
                Spacer()
                
                // 하단 인디케이터
                if imageUrls.count > 1 {
                    footerView
                }
            }
        }
        .onTapGesture(count: 2) {
            // 더블 탭으로 줌 토글
            withAnimation(.easeInOut(duration: 0.3)) {
                if scale == 1.0 {
                    scale = 2.0
                } else {
                    scale = 1.0
                    offset = .zero
                }
            }
        }
        .gesture(
            // 확대/축소 제스처
            MagnificationGesture()
                .onChanged { value in
                    let delta = value / lastScale
                    lastScale = value
                    scale = scale * delta
                }
                .onEnded { value in
                    lastScale = 1.0
                    if scale < 1.0 {
                        withAnimation(.easeInOut(duration: 0.3)) {
                            scale = 1.0
                            offset = .zero
                        }
                    } else if scale > 5.0 {
                        withAnimation(.easeInOut(duration: 0.3)) {
                            scale = 5.0
                        }
                    }
                }
        )
        .simultaneousGesture(
            // 드래그 제스처 (확대된 상태에서만)
            DragGesture()
                .onChanged { value in
                    if scale > 1.0 {
                        offset = CGSize(
                            width: lastOffset.width + value.translation.width,
                            height: lastOffset.height + value.translation.height
                        )
                    }
                }
                .onEnded { value in
                    lastOffset = offset
                }
        )
    }
}

private extension ChatImageDetailView {
    var headerView: some View {
        HStack {
            // 뒤로가기 버튼
            Button {
                print("ChatImageDetailView 뒤로가기 눌림")
                dismiss()
            } label: {
                Image(systemName: "xmark")
                    .font(.system(size: 18, weight: .semibold))
                    .foregroundStyle(.white)
                    .frame(width: 44, height: 44)
                    .background(
                        Circle()
                            .fill(.black.opacity(0.5))
                    )
            }
            
            Spacer()
            
            // 이미지 카운터
            if imageUrls.count > 1 {
                Text("\(currentIndex + 1) / \(imageUrls.count)")
                    .font(.system(size: 16, weight: .medium))
                    .foregroundStyle(.white)
                    .padding(.horizontal, 12)
                    .padding(.vertical, 6)
                    .background(
                        Capsule()
                            .fill(.black.opacity(0.5))
                    )
            }
        }
        .padding(.horizontal, 20)
        .padding(.top, 20)
    }
    
    var footerView: some View {
        HStack {
            Spacer()
            
            // 페이지 인디케이터
            HStack(spacing: 8) {
                ForEach(imageUrls.indices, id: \.self) { index in
                    Circle()
                        .fill(index == currentIndex ? .white : .white.opacity(0.3))
                        .frame(width: 8, height: 8)
                        .animation(.easeInOut(duration: 0.2), value: currentIndex)
                }
            }
            
            Spacer()
        }
        .padding(.bottom, 40)
    }
    
    func zoomableImageView(url: String) -> some View {
        GTLazyImageView(
            urlString: url.imageURL,
            priority: .high
        ) { image in
            image
                .resizable()
                .aspectRatio(contentMode: .fit)
                .scaleEffect(scale)
                .offset(offset)
                .clipped()
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
} 
