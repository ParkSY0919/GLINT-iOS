//
//  CommunityItemView.swift
//  GLINT-iOS
//
//  Created by 박신영 on 5/26/25.
//

import SwiftUI
import Nuke
import NukeUI

struct CommunityItemView: View {
    let item: FilterEntity
    let onTapped: () -> Void
    
    // 고정된 셀 크기 정의
    static let cellWidth: CGFloat = (UIScreen.main.bounds.width - 60) / 2
    static let cellHeight: CGFloat = 320 // 고정된 셀 높이
    
    // 더미 데이터 배열들
    private let dummyTitles = [
        "Creative Filter Effect",
        "Vintage Film Look",
        "Modern Portrait Style",
        "Nature Color Boost",
        "Dreamy Sunset Glow",
        "Urban Street Vibe",
        "Classic B&W Filter"
    ]
    
    private let dummyUsernames = [
        "creative_artist",
        "photo_lover", 
        "filter_master",
        "visual_creator",
        "art_enthusiast",
        "photo_wizard",
        "creative_user"
    ]
    
    private let dummyTimeStamps = [
        "30분 전", "1시간 전", "2시간 전", "3시간 전", 
        "5시간 전", "1일 전", "2일 전", "3일 전"
    ]
    
    var body: some View {
        Button(action: onTapped) {
            VStack(alignment: .leading, spacing: 12) {
                imageSection
                contentSection
                Spacer(minLength: 0) // 남은 공간을 채워서 일정한 높이 유지
            }
            .padding(12)
            .frame(width: Self.cellWidth, height: Self.cellHeight) // 고정된 셀 크기
            .background(
                ZStack {
                    RoundedRectangle(cornerRadius: 20)
                        .fill(.ultraThinMaterial)
                        .background(
                            RoundedRectangle(cornerRadius: 20)
                                .fill(Color.pinterestDarkCard.opacity(0.6))
                        )
                    
                    RoundedRectangle(cornerRadius: 20)
                        .stroke(Color.glassStroke.opacity(0.3), lineWidth: 1)
                }
            )
            .shadow(color: .black.opacity(0.1), radius: 8, x: 0, y: 4)
        }
        .buttonStyle(PlainButtonStyle())
    }
}

private extension CommunityItemView {
    var imageSection: some View {
        // item.id를 기반으로 일관된 이미지 생성
        let imageUrl = "https://picsum.photos/400/300?random=\(item.id.hashValue)"
        
        // 고정된 이미지 크기 계산 (셀 높이에 맞춰 조정)
        let imageHeight: CGFloat = 180
        
        return ZStack {
            // 고정 배경 (항상 동일한 크기 유지)
            RoundedRectangle(cornerRadius: 16)
                .fill(
                    LinearGradient(
                        colors: [.pinterestDarkCard.opacity(0.3), .pinterestDarkSurface.opacity(0.5)],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .frame(height: imageHeight)
            
            // 이미지 오버레이 - 고정된 프레임으로 레이아웃 안정성 보장
            AsyncImage(url: URL(string: imageUrl)) { phase in
                switch phase {
                case .success(let image):
                    image
                        .resizable()
                        .scaledToFill()
                        .frame(width: Self.cellWidth - 24, height: imageHeight) // 고정된 width와 height
                        .clipped()
                case .failure(_):
                    VStack(spacing: 8) {
                        Image(systemName: "photo")
                            .font(.system(size: 24, weight: .light))
                            .foregroundColor(.pinterestTextTertiary)
                        
                        Text("로딩 실패")
                            .font(.pretendardFont(.caption, size: 10))
                            .foregroundColor(.pinterestTextTertiary)
                    }
                    .frame(width: Self.cellWidth - 24, height: imageHeight) // 실패 상태에도 동일한 크기
                case .empty:
                    VStack(spacing: 8) {
                        Image(systemName: "photo")
                            .font(.system(size: 24, weight: .light))
                            .foregroundColor(.pinterestTextTertiary)
                        
                        ProgressView()
                            .progressViewStyle(CircularProgressViewStyle(tint: .pinterestRed))
                            .scaleEffect(0.8)
                    }
                    .frame(width: Self.cellWidth - 24, height: imageHeight) // 로딩 상태에도 동일한 크기
                @unknown default:
                    EmptyView()
                        .frame(width: Self.cellWidth - 24, height: imageHeight) // 기본 상태에도 동일한 크기
                }
            }
        }
        .frame(width: Self.cellWidth - 24, height: imageHeight) // 전체 이미지 섹션 고정 크기
        .clipShape(RoundedRectangle(cornerRadius: 16))
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .stroke(Color.glassStroke.opacity(0.2), lineWidth: 1)
        )
    }
    
    var contentSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(getConsistentTitle())
                .font(.pretendardFont(.body_bold, size: 16))
                .foregroundColor(.pinterestTextPrimary)
                .lineLimit(2)
                .multilineTextAlignment(.leading)
            
            metaInfoSection
        }
    }
    
    var metaInfoSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            // 작성자 정보
            HStack(spacing: 8) {
                Circle()
                    .fill(
                        LinearGradient(
                            colors: [.pinterestRed.opacity(0.7), .gradientMid.opacity(0.7)],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .frame(width: 20, height: 20)
                    .overlay(
                        Image(systemName: "person.fill")
                            .font(.system(size: 10, weight: .medium))
                            .foregroundColor(.white)
                    )
                
                Text("@\(getConsistentUsername())")
                    .font(.pretendardFont(.body_medium, size: 12))
                    .foregroundColor(.pinterestTextSecondary)
                    .lineLimit(1)
                
                Spacer()
            }
            
            // 좋아요 및 댓글 정보
            HStack(spacing: 12) {
                // 좋아요
                HStack(spacing: 4) {
                    Image(systemName: "heart.fill")
                        .font(.system(size: 12, weight: .medium))
                        .foregroundColor(.pinterestRed)
                    Text("\(getConsistentLikeCount())")
                        .font(.pretendardFont(.caption_medium, size: 12))
                        .foregroundColor(.pinterestTextSecondary)
                }
                
                // 댓글
                HStack(spacing: 4) {
                    Image(systemName: "bubble.left.fill")
                        .font(.system(size: 12, weight: .medium))
                        .foregroundColor(.pinterestRed)
                    Text("\(getConsistentCommentCount())")
                        .font(.pretendardFont(.caption_medium, size: 12))
                        .foregroundColor(.pinterestTextSecondary)
                }
                
                Spacer()
                
                Text(getConsistentTimeStamp())
                    .font(.pretendardFont(.caption, size: 10))
                    .foregroundColor(.pinterestTextTertiary)
            }
        }
    }
    
    // 일관된 더미 데이터를 생성하는 헬퍼 메서드들
    private func getConsistentTitle() -> String {
        let index = abs(item.id.hashValue) % dummyTitles.count
        return dummyTitles[index]
    }
    
    private func getConsistentUsername() -> String {
        let index = abs(item.id.hashValue) % dummyUsernames.count
        return dummyUsernames[index]
    }
    
    private func getConsistentTimeStamp() -> String {
        let index = abs(item.id.hashValue) % dummyTimeStamps.count
        return dummyTimeStamps[index]
    }
    
    private func getConsistentLikeCount() -> Int {
        let seed = abs(item.id.hashValue)
        return (seed % 85) + 15 // 15-99 범위 (두자리 수)
    }
    
    private func getConsistentCommentCount() -> Int {
        let seed = abs(item.id.hashValue)
        return (seed % 7) + 1 // 1-7 범위 (한자리 수)
    }
}
