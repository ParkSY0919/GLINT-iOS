//
//  DetailView.swift
//  GLINT-iOS
//
//  Created by 박신영 on 6/1/25.
//

import SwiftUI

import NukeUI

struct DetailView: View {
    let id: String
    let router: NavigationRouter<MainTabRoute>
    @State private var store = DetailViewStore()
    @State private var isLiked = false
    
    var body: some View {
        Group {
            if store.state.isLoading && !store.state.hasLoadedOnce {
                StateViewBuilder.loadingView()
            } else if let errorMessage = store.state.errorMessage, !store.state.hasLoadedOnce {
                StateViewBuilder.errorView(errorMessage: errorMessage) {
                    store.send(.retryButtonTapped)
                }
            } else {
                contentView
            }
        }
        .navigationTitle("청록새록")
        .navigationBarTitleDisplayMode(.inline)
        .navigationBarBackButtonHidden(true)
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading) {
                Button {
                    router.pop()
                } label: {
                    Image(systemName: "arrow.left")
                        .font(.system(size: 18, weight: .medium))
                        .foregroundColor(.gray75)
                }
            }
            
            ToolbarItem(placement: .navigationBarTrailing) {
                LikeButton(isLiked: $isLiked) {
//                    store.send(.likeButtonTapped)
                }
            }
        }
        .onAppear {
            store.send(.viewAppeared(id: id))
            setupNavigationAppearance()
        }
    }
    
    private var contentView: some View {
        ScrollView(showsIndicators: false) {
            VStack(spacing: 0) {
                filterSection
                priceSection
                metaDataSection
                filterPresetsSection
                payButtonSection
                authorSection
            }
        }
        .background(.gray100)
    }
    
    private func setupNavigationAppearance() {
        let appearance = UINavigationBarAppearance()
        appearance.configureWithOpaqueBackground()
        appearance.backgroundColor = UIColor(Color.gray100)
        if let pointFont = UIFont(name: "TTHakgyoansimMulgyeolB", size: 16) {
            appearance.titleTextAttributes = [
                .font: pointFont,
                .foregroundColor: UIColor(Color.gray0)
            ]
        }
        
        UINavigationBar.appearance().standardAppearance = appearance
        UINavigationBar.appearance().scrollEdgeAppearance = appearance
    }
}

// MARK: - Filter Section
private extension DetailView {
    var filterSection: some View {
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
    
    var beforeAfterImageView: some View {
        GeometryReader { geometry in
            let imageWidth = geometry.size.width - 40
            let imageHeight: CGFloat = 384
            
            ZStack {
                // 원본 이미지 (배경 - Before)
                LazyImage(url: URL(string: store.state.filterDetail?.originalImageURL ?? "")) { state in
                    lazyImageTransform(state) { image in
                        image
                            .aspectRatio(contentMode: .fill)
                            .frame(width: imageWidth, height: imageHeight)
                            .clipped()
                    }
                }
                .clipRectangle(12)
                
                // 필터 적용 이미지 (오버레이 - After)
                LazyImage(url: URL(string: store.state.filterDetail?.filteredImageURL ?? "")) { state in
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
                        .frame(width: imageWidth * store.state.sliderPosition, height: imageHeight)
                        .offset(x: -imageWidth * (1 - store.state.sliderPosition) / 2)
                        .animation(.easeInOut(duration: 0.1), value: store.state.sliderPosition)
                )
                
                // 구분선
                Rectangle()
                    .frame(width: 2, height: imageHeight)
                    .foregroundColor(.gray0)
                    .shadow(color: .black.opacity(0.3), radius: 2, x: 0, y: 0)
                    .offset(x: imageWidth * store.state.sliderPosition - imageWidth / 2)
                    .animation(.easeInOut(duration: 0.1), value: store.state.sliderPosition)
            }
            .padding(.horizontal, 20)
            .gesture(
                DragGesture()
                    .onChanged { value in
                        let newPosition = (value.location.x - 20) / imageWidth
                        store.send(.sliderPositionChanged(max(0, min(1, newPosition))))
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
                let handlePosition = trackWidth * store.state.sliderPosition
                
                ZStack(alignment: .leading) {
                    RoundedRectangle(cornerRadius: 2)
                        .frame(height: 4)
                        .foregroundColor(.gray.opacity(0.3))
                    
                    // 슬라이더 핸들
                    ZStack {

                        ImageLiterals.Detail.divideBtn
                            .font(.system(size: 8, weight: .medium))
                            .foregroundColor(.gray60)
                    }
                    .offset(x: handlePosition - 12) // 핸들 중심을 맞추기 위해 -12
                    .animation(.easeInOut(duration: 0.1), value: store.state.sliderPosition)
                }
                .gesture(
                    DragGesture()
                        .onChanged { value in
                            let newPosition = value.location.x / trackWidth
                            store.send(.sliderPositionChanged(max(0, min(1, newPosition))))
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

// MARK: - Price Section
private extension DetailView {
    var priceSection: some View {
        HStack(alignment: .top, spacing: 16) {
            VStack(alignment: .leading, spacing: 8) {
                Text("\(formatPrice(store.state.filterDetail?.price ?? 0)) Coin")
                    .font(.pointFont(.title, size: 32))
                    .foregroundColor(.gray0)
                
                HStack(spacing: 12) {
                    downloadCountBox
                    likeCountBox
                }
            }
            
            Spacer()
        }
        .padding(.horizontal, 20)
        .padding(.top, 24)
    }
    
    var downloadCountBox: some View {
        VStack(spacing: 4) {
            Text("다운로드")
                .font(.pretendardFont(.caption, size: 12))
                .foregroundColor(.gray60)
            
            Text("\(formatCount(store.state.filterDetail?.downloadCount ?? 0))+")
                .font(.pretendardFont(.body_bold, size: 14))
                .foregroundColor(.gray0)
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 8)
        .background(.gray90)
        .clipRectangle(8)
    }
    
    var likeCountBox: some View {
        VStack(spacing: 4) {
            Text("찜하기")
                .font(.pretendardFont(.caption, size: 12))
                .foregroundColor(.gray60)
            
            Text("\(formatCount(store.state.filterDetail?.likeCount ?? 0))")
                .font(.pretendardFont(.body_bold, size: 14))
                .foregroundColor(.gray0)
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 8)
        .background(.gray90)
        .clipRectangle(8)
    }
    
    func formatPrice(_ price: Int) -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        return formatter.string(from: NSNumber(value: price)) ?? "\(price)"
    }
    
    func formatCount(_ count: Int) -> String {
        if count >= 1000 {
            return "\(count / 1000)k"
        }
        return "\(count)"
    }
}

// MARK: - MetaData Section
private extension DetailView {
    var metaDataSection: some View {
        VStack(spacing: 0) {
            // 큰 컨텐츠 박스
            VStack(spacing: 0) {
                // 상단 타이틀 바 (내부)
                HStack {
                    Text(store.state.filterDetail?.deviceInfo ?? "Apple iPhone 15 Pro")
                        .font(.pretendardFont(.caption_medium, size: 14))
                        .foregroundColor(.gray0)
                    
                    Spacer()
                    
                    Text("EXIF")
                        .font(.pretendardFont(.body_bold, size: 14))
                        .foregroundColor(.gray60)
                }
                .padding(.horizontal, 16)
                .padding(.vertical, 12)
                .background(.gray100)
                .clipShape(
                    .rect(
                        topLeadingRadius: 12,
                        bottomLeadingRadius: 0,
                        bottomTrailingRadius: 0,
                        topTrailingRadius: 12
                    )
                )
                
                // 메타데이터 내용
                HStack(spacing: 12) {
                    // 지도 영역 (위치 정보가 있으면 지도, 없으면 empty 이미지)
                    Group {
                        if store.state.filterDetail?.locationInfo != nil {
                            // TODO: 실제 지도 구현
                            Rectangle()
                                .fill(.gray75)
                                .overlay {
                                    Image(systemName: "map")
                                        .foregroundColor(.gray45)
                                        .font(.system(size: 20))
                                }
                        } else {
                            Rectangle()
                                .fill(.gray90)
                                .overlay {
                                    Image(systemName: "photo")
                                        .foregroundColor(.gray60)
                                        .font(.system(size: 20))
                                }
                        }
                    }
                    .frame(width: 80, height: 60)
                    .clipRectangle(8)
                    
                    // 메타데이터 정보
                    VStack(alignment: .leading, spacing: 4) {
                        Text(store.state.filterDetail?.cameraInfo ?? "")
                            .font(.pretendardFont(.caption, size: 12))
                            .foregroundColor(.gray60)
                            .lineLimit(1)
                        
                        Text(store.state.filterDetail?.imageSize ?? "")
                            .font(.pretendardFont(.caption, size: 12))
                            .foregroundColor(.gray60)
                            .lineLimit(1)
                        
                        if let location = store.state.filterDetail?.locationInfo {
                            Text(location)
                                .font(.pretendardFont(.caption, size: 12))
                                .foregroundColor(.gray60)
                                .lineLimit(2)
                        }
                    }
                    
                    Spacer()
                }
                .padding(.horizontal, 16)
                .padding(.vertical, 16)
                .background(.gray90)
                .clipShape(
                    .rect(
                        topLeadingRadius: 0,
                        bottomLeadingRadius: 12,
                        bottomTrailingRadius: 12,
                        topTrailingRadius: 0
                    )
                )
            }
            .overlay(
                RoundedRectangle(cornerRadius: 12, style: .continuous)
                    .strokeBorder(.gray75, lineWidth: 1)
            )
        }
        .padding(.horizontal, 20)
        .padding(.top, 24)
    }
}

// MARK: - Filter Presets Section
private extension DetailView {
    var filterPresetsSection: some View {
        VStack(spacing: 0) {
            // 큰 컨텐츠 박스
            VStack(spacing: 0) {
                // 상단 타이틀 바 (내부)
                HStack {
                    Text("Filter Presets")
                        .font(.pretendardFont(.caption_medium, size: 14))
                        .foregroundColor(.gray0)
                    
                    Spacer()
                    
                    Text("LUT")
                        .font(.pretendardFont(.body_bold, size: 14))
                        .foregroundColor(.gray60)
                }
                .padding(.horizontal, 16)
                .padding(.vertical, 12)
                .background(.gray100)
                .clipShape(
                    .rect(
                        topLeadingRadius: 12,
                        bottomLeadingRadius: 0,
                        bottomTrailingRadius: 0,
                        topTrailingRadius: 12
                    )
                )
                
                // 필터 프리셋 내용
                ZStack {
                    // 배경 영역
                    Rectangle()
                        .fill(.gray90)
                        .clipShape(
                            .rect(
                                topLeadingRadius: 0,
                                bottomLeadingRadius: 12,
                                bottomTrailingRadius: 12,
                                topTrailingRadius: 0
                            )
                        )
                    
                    if store.state.isPurchased {
                        unlockedFilterPresets
                    } else {
                        ZStack {
                            // 블러 처리된 배경
                            unlockedFilterPresets
                                .blur(radius: 3)
                            
                            // 자물쇠와 텍스트 (블러 처리 안됨)
                            VStack(spacing: 8) {
                                Image(systemName: "lock.fill")
                                    .font(.system(size: 24))
                                    .foregroundColor(.gray0)
                                
                                Text("결제 후 필요한 유료 필터입니다")
                                    .font(.pretendardFont(.caption_medium, size: 14))
                                    .foregroundColor(.gray0)
                                    .multilineTextAlignment(.center)
                            }
                            .padding(.vertical, 40)
                        }
                    }
                }
                .frame(height: 140) // 2행을 위한 고정 높이
            }
            .overlay(
                RoundedRectangle(cornerRadius: 12, style: .continuous)
                    .strokeBorder(.gray75, lineWidth: 1)
            )
        }
        .padding(.horizontal, 20)
        .padding(.top, 24)
    }
    
    var unlockedFilterPresets: some View {
        LazyVGrid(
            columns: Array(repeating: GridItem(.flexible(), spacing: 20), count: 6),
            spacing: 16
        ) {
            ForEach(0..<12, id: \.self) { index in
                VStack(spacing: 4) {
                    // 더미 아이콘들
                    let icons = ["gear", "plus.app", "circle.lefthalf.filled", "circles.hexagongrid", "triangle", "circle.grid.3x3", "square", "circle.dotted", "circle", "moon.stars", "thermometer", "gear.badge"]
                    let values = ["-3.5", "1.5", "2.5", "0.1", "-4.0", "10.5", "-6.0", "7.5", "0.5", "0.5", "-1.0", "5.5"]
                    
                    Image(systemName: icons[index])
                        .font(.system(size: 20))
                        .foregroundColor(.gray0)
                        .frame(width: 24, height: 24)
                    
                    Text(values[index])
                        .font(.pretendardFont(.caption, size: 10))
                        .foregroundColor(.gray60)
                        .lineLimit(1)
                }
                .frame(maxWidth: .infinity)
            }
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 16)
    }
}

// MARK: - Pay Button Section
private extension DetailView {
    var payButtonSection: some View {
        Button {
            store.send(.purchaseButtonTapped)
        } label: {
            Text(store.state.isPurchased ? "구매완료" : "결제하기")
                .font(.pretendardFont(.body_bold, size: 16))
                .foregroundColor(.white)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 16)
                .background(store.state.isPurchased ? .gray75 : .brandBright)
                .clipRectangle(12)
        }
        .disabled(store.state.isPurchased)
        .padding(.horizontal, 20)
        .padding(.top, 24)
    }
}

// MARK: - Author Section
private extension DetailView {
    var authorSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            // 작가 프로필 섹션
            HStack(spacing: 12) {
                // 프로필 이미지
                LazyImage(url: URL(string: store.state.filterDetail?.author.profileImage ?? "")) { state in
                    lazyImageTransform(state) { image in
                        image.aspectRatio(contentMode: .fill)
                    }
                }
                .frame(width: 72, height: 72)
                .clipShape(Circle())
                
                // 작가 정보
                VStack(alignment: .leading, spacing: 4) {
                    Text(store.state.filterDetail?.author.name ?? "")
                        .font(.pointFont(.body, size: 20))
                        .foregroundColor(.gray30)
                    
                    Text(store.state.filterDetail?.author.nick ?? "")
                        .font(.pretendardFont(.body_medium, size: 16))
                        .foregroundColor(.gray75)
                }
                
                Spacer()
                
                // 메시지 보내기 버튼
                Button {
                    store.send(.sendMessageTapped)
                } label: {
                    Image(systemName: "paperplane.fill")
                        .font(.system(size: 20))
                        .foregroundColor(.gray0)
                }
                .frame(width: 44, height: 44)
                .background(.brandBright)
                .clipShape(Circle())
            }
            
            // 해시태그
            HStack {
                ForEach(store.state.filterDetail?.author.hashTags ?? [], id: \.self) { tag in
                    Text(tag)
                        .font(.pointFont(.caption, size: 10))
                        .foregroundColor(.gray60)
                        .padding(.horizontal, 10)
                        .padding(.vertical, 5)
                        .background(.quaternary)
                        .clipShape(Capsule())
                }
            }
            
            // 작가 소개
            VStack(alignment: .leading, spacing: 12) {
                Text(store.state.filterDetail?.author.introduction ?? "")
                    .font(.pointFont(.body, size: 14))
                    .foregroundColor(.gray60)
                
                Text(store.state.filterDetail?.author.description ?? "")
                    .font(.pretendardFont(.caption, size: 12))
                    .foregroundColor(.gray60)
            }
        }
        .padding(.horizontal, 20)
        .padding(.top, 24)
        .padding(.bottom, 32)
    }
}
