//
//  GTMetaDataView.swift
//  GLINT-iOS
//
//  Created by AI Assistant on 1/19/25.
//

import SwiftUI
import MapKit

struct GTMetaDataView: View {
    let camera: String?
    let photoMetadataString: String
    let megapixelInfo: String
    let address: String?
    let latitude: Float?
    let longitude: Float?
    
    var body: some View {
        VStack(spacing: 0) {
            // 큰 컨텐츠 박스
            VStack(spacing: 0) {
                // 상단 타이틀 바 (내부)
                HStack {
                    Text(camera ?? "정보 없음")
                        .font(.pretendardFont(.caption_semi, size: 12))
                        .foregroundColor(.brandDeep)
                    
                    Spacer()
                    
                    Text("EXIF")
                        .font(.pretendardFont(.caption_semi, size: 12))
                        .foregroundColor(.brandDeep)
                }
                .padding(.horizontal, 12)
                .padding(.vertical, 7)
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
                    
                    // MARK: 메타데이터 콘텐츠
                    HStack(spacing: 12) {
                        Group {
                            // 지도 파트
                            if let latitude = latitude,
                               let longitude = longitude,
                               latitude != 0.0,
                               longitude != 0.0 {
                                StaticMiniMapView(latitude: latitude, longitude: longitude)
                            } else {
                                Rectangle()
                                    .fill(.brandBlack)
                                    .overlay {
                                        Images.Detail.noMap
                                    }
                            }
                        }
                        .frame(width: 76, height: 76)
                        .clipRectangle(8)
                        
                        // 정보
                        VStack(alignment: .leading, spacing: 8) {
                            Text(photoMetadataString)
                                .font(.pretendardFont(.caption_semi, size: 13))
                                .foregroundColor(.gray75)
                                .lineLimit(1)
                            
                            Text(megapixelInfo)
                                .font(.pretendardFont(.caption_semi, size: 13))
                                .foregroundColor(.gray75)
                                .lineLimit(1)
                            
                            Text(address ?? "")
                                .font(.pretendardFont(.caption_semi, size: 13))
                                .foregroundColor(.gray75)
                                .lineLimit(2)
                        }
                        
                        Spacer()
                    }
                    .padding(.horizontal, 8)
                    .padding(.vertical, 8)
                }
                .frame(height: 110)
            }
            .overlay(
                RoundedRectangle(cornerRadius: 12, style: .continuous)
                    .strokeBorder(.brandDeep, lineWidth: 2)
            )
        }
        .padding(.horizontal, 20)
    }
}

struct StaticMiniMapView: View {
    let latitude: Float
    let longitude: Float
    
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
        .overlay(
            RoundedRectangle(cornerRadius: 8, style: .continuous)
                .strokeBorder(.brandDeep, lineWidth: 2)
        )
    }
    
    private func generateMapSnapshot() {
        let coordinate = CLLocationCoordinate2D(latitude: Double(latitude), longitude: Double(longitude))
        
        let options = MKMapSnapshotter.Options()
        options.region = MKCoordinateRegion(
            center: coordinate,
            latitudinalMeters: 1000,
            longitudinalMeters: 1000
        )
        options.size = CGSize(width: 240, height: 240)
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
