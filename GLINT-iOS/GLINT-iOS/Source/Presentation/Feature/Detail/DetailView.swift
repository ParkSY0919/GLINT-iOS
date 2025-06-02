//
//  DetailView.swift
//  GLINT-iOS
//
//  Created by 박신영 on 6/1/25.
//

import SwiftUI
import MapKit

import NukeUI

struct DetailView: View {
    let id: String
    let router: NavigationRouter<MainTabRoute>
    @State private var store = DetailViewStore(filterDetailUseCase: .liveValue)
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
        .navigationTitle(store.state.filterData?.title ?? "")
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
                LazyImage(url: URL(string: store.state.filterData?.original ?? "")) { state in
                    lazyImageTransform(state) { image in
                        image
                            .aspectRatio(contentMode: .fill)
                            .frame(width: imageWidth, height: imageHeight)
                            .clipped()
                    }
                }
                .clipRectangle(12)
                
                // 필터 적용 이미지 (오버레이 - After)
                LazyImage(url: URL(string: store.state.filterData?.filtered ?? "")) { state in
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
                let price = store.state.filterData?.price ?? 0
                Text("\(price.formatted()) Coin")
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
            
            Text("\(formatCount(store.state.filterData?.buyerCount ?? 0))+")
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
            
            Text("\(formatCount(store.state.filterData?.likeCount ?? 0))")
                .font(.pretendardFont(.body_bold, size: 14))
                .foregroundColor(.gray0)
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 8)
        .background(.gray90)
        .clipRectangle(8)
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
                    Text(store.state.photoMetaData?.camera ?? "iPhone")
                        .font(.pretendardFont(.caption_semi, size: 12))
                        .foregroundColor(.brandDeep)
                    
                    Spacer()
                    
                    Text("EXIF")
                        .font(.pretendardFont(.caption_semi, size: 12))
                        .foregroundColor(.brandDeep)
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
                
                //MARK: 메타데이터
                HStack(spacing: 12) {
                    Group {
                        // 지도 파트
                        if let latitude = store.state.photoMetaData?.latitude,
                           let longitude = store.state.photoMetaData?.longitude {
                            StaticMiniMapView(latitude: latitude, longitude: longitude)
                        } else {
                            Rectangle()
                                .fill(.brandBlack)
                                .overlay {
                                    ImageLiterals.Detail.noMap
                                }
                        }
                    }
                    .frame(width: 76, height: 76)
                    .clipRectangle(8)
                    
                    // 정보
                    VStack(alignment: .leading, spacing: 8) {
                        if let metaData = store.state.photoMetaData {
                            Text(metaData.metaData[0])
                                .font(.pretendardFont(.caption_semi, size: 13))
                                .foregroundColor(.gray75)
                                .lineLimit(1)
                            
                            Text(metaData.metaData[1])
                                .font(.pretendardFont(.caption_semi, size: 13))
                                .foregroundColor(.gray75)
                                .lineLimit(1)
                            
                            Text(store.state.address ?? "")
                                .font(.pretendardFont(.caption_semi, size: 13))
                                .foregroundColor(.gray75)
                                .lineLimit(2)
                        }
                    }
                    
                    Spacer()
                }
                .padding(.horizontal, 16)
                .padding(.vertical, 16)
                .background(.brandBlack)
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
                    .strokeBorder(.brandBlack, lineWidth: 1)
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
                        .font(.pretendardFont(.caption_semi, size: 12))
                        .foregroundColor(.brandDeep)
                    
                    Spacer()
                    
                    Text("LUT")
                        .font(.pretendardFont(.caption_semi, size: 12))
                        .foregroundColor(.brandDeep)
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
                        .fill(.brandBlack)
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
                            unlockedFilterPresets
                                .blur(radius: 3)
                            
                            // 자물쇠와 텍스트
                            VStack(spacing: 12) {
                                Image(systemName: "lock.fill")
                                    .font(.system(size: 32))
                                    .foregroundColor(.gray0)
                                
                                Text("결제 후 필요한 유료 필터입니다")
                                    .font(.pretendardFont(.body_bold, size: 16))
                                    .foregroundColor(.gray45)
                                    .multilineTextAlignment(.center)
                            }
                            .padding(.vertical, 40)
                        }
                    }
                }
                .frame(height: 140)
            }
            .overlay(
                RoundedRectangle(cornerRadius: 12, style: .continuous)
                    .strokeBorder(.brandBlack, lineWidth: 1)
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
                    let icons = ImageLiterals.Detail.filterValues
                    if let data = store.state.filterPresetsData?.toStringArray() {
                        icons[index]
                            .font(.system(size: 20))
                            .foregroundColor(.gray0)
                            .frame(width: 28, height: 28)
                        
                        Text(data[index])
                            .font(.pretendardFont(.body_bold, size: 14))
                            .foregroundColor(.gray75)
                            .lineLimit(1)
                    }
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
                LazyImage(url: URL(string: store.state.userInfoData?.profileImage ?? "")) { state in
                    lazyImageTransform(state) { image in
                        image.aspectRatio(contentMode: .fill)
                    }
                }
                .frame(width: 72, height: 72)
                .clipShape(Circle())
                
                // 작가 정보
                VStack(alignment: .leading, spacing: 4) {
                    Text(store.state.userInfoData?.name ?? "")
                        .font(.pointFont(.body, size: 20))
                        .foregroundColor(.gray30)
                    
                    Text(store.state.userInfoData?.nick ?? "")
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
                ForEach(store.state.userInfoData?.hashTags ?? [], id: \.self) { tag in
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
                Text(store.state.userInfoData?.introduction ?? "")
                    .font(.pointFont(.body, size: 14))
                    .foregroundColor(.gray60)
                
                Text(store.state.userInfoData?.description ?? "")
                    .font(.pretendardFont(.caption, size: 12))
                    .foregroundColor(.gray60)
            }
        }
        .padding(.horizontal, 20)
        .padding(.top, 24)
        .padding(.bottom, 32)
    }
}


struct StaticMiniMapView: View {
    let latitude: Double
    let longitude: Double
    
    @State private var mapImage: UIImage?
    @State private var isLoading = true
    
    var body: some View {
        Group {
            if let mapImage = mapImage {
                Image(uiImage: mapImage)
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .frame(width: 120, height: 120)
                    .clipShape(RoundedRectangle(cornerRadius: 8))
            } else if isLoading {
                RoundedRectangle(cornerRadius: 8)
                    .fill(.gray.opacity(0.3))
                    .frame(width: 120, height: 120)
                    .overlay {
                        ProgressView()
                    }
            } else {
                RoundedRectangle(cornerRadius: 8)
                    .fill(.gray.opacity(0.3))
                    .frame(width: 120, height: 120)
                    .overlay {
                        Text("지도 로드 실패")
                            .font(.caption2)
                            .foregroundColor(.gray)
                    }
            }
        }
        .onAppear {
            generateMapSnapshot()
        }
    }
    
    private func generateMapSnapshot() {
        let coordinate = CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
        
        let options = MKMapSnapshotter.Options()
        options.region = MKCoordinateRegion(
            center: coordinate,
            latitudinalMeters: 1000,
            longitudinalMeters: 1000
        )
        options.size = CGSize(width: 240, height: 240) // 2x for retina
        options.mapType = .standard
        
        let snapshotter = MKMapSnapshotter(options: options)
        snapshotter.start { snapshot, error in
            DispatchQueue.main.async {
                isLoading = false
                if let snapshot = snapshot {
                    // 핀 오버레이 추가
                    let image = UIGraphicsImageRenderer(size: snapshot.image.size).image { _ in
                        snapshot.image.draw(at: .zero)
                        
                        // 핀 위치 계산
                        let pinPoint = snapshot.point(for: coordinate)
                        
                        // 핀 그리기
                        let pinSize: CGFloat = 20
                        let pinRect = CGRect(
                            x: pinPoint.x - pinSize/2,
                            y: pinPoint.y - pinSize,
                            width: pinSize,
                            height: pinSize
                        )
                        
                        UIColor.red.setFill()
                        UIBezierPath(ovalIn: pinRect).fill()
                        
                        UIColor.white.setFill()
                        let innerRect = pinRect.insetBy(dx: 6, dy: 6)
                        UIBezierPath(ovalIn: innerRect).fill()
                    }
                    
                    mapImage = image
                } else {
                    print("Map snapshot error: \(error?.localizedDescription ?? "Unknown error")")
                }
            }
        }
    }
}
