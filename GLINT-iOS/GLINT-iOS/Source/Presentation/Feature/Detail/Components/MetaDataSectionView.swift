//
//  MetaDataSectionView.swift
//  GLINT-iOS
//
//  Created by AI Assistant on 1/19/25.
//

import SwiftUI
import MapKit

struct MetaDataSectionView: View {
    let camera: String?
    let metaData: [String]
    let address: String?
    let latitude: Double?
    let longitude: Double?
    
    var body: some View {
        VStack(spacing: 0) {
            // 큰 컨텐츠 박스
            VStack(spacing: 0) {
                // 상단 타이틀 바 (내부)
                HStack {
                    Text(camera ?? "iPhone")
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
                        if let latitude = latitude,
                           let longitude = longitude {
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
                        if metaData.count >= 2 {
                            Text(metaData[0])
                                .font(.pretendardFont(.caption_semi, size: 13))
                                .foregroundColor(.gray75)
                                .lineLimit(1)
                            
                            Text(metaData[1])
                                .font(.pretendardFont(.caption_semi, size: 13))
                                .foregroundColor(.gray75)
                                .lineLimit(1)
                        }
                        
                        Text(address ?? "")
                            .font(.pretendardFont(.caption_semi, size: 13))
                            .foregroundColor(.gray75)
                            .lineLimit(2)
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