//
//  AuthorSectionView.swift
//  GLINT-iOS
//
//  Created by AI Assistant on 1/19/25.
//

import SwiftUI
import NukeUI

struct AuthorSectionView: View {
    let userInfo: UserInfoModel?
    let onSendMessageTapped: () -> Void
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            // 작가 프로필 섹션
            HStack(spacing: 12) {
                // 프로필 이미지
                if userInfo?.profileImage != "" {
                    LazyImage(url: URL(string: userInfo?.profileImage ?? "")) { state in
                        lazyImageTransform(state) { image in
                            image.aspectRatio(contentMode: .fill)
                        }
                    }
                    .frame(width: 72, height: 72)
                    .clipShape(Circle())
                } else {
                    ImageLiterals.TabBar.profile
                        .frame(width: 72, height: 72)
                        .clipShape(Circle())
                        .overlay(
                            Circle()
                                .stroke(Color.white, lineWidth: 1)
                        )
                }
                
                // 작가 정보
                VStack(alignment: .leading, spacing: 4) {
                    Text(userInfo?.name ?? "")
                        .font(.pointFont(.body, size: 20))
                        .foregroundColor(.gray30)
                    
                    Text(userInfo?.nick ?? "")
                        .font(.pretendardFont(.body_medium, size: 16))
                        .foregroundColor(.gray75)
                }
                
                Spacer()
                
                // 메시지 보내기 버튼
                Button {
                    onSendMessageTapped()
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
                ForEach(userInfo?.hashTags ?? [], id: \.self) { tag in
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
                Text(userInfo?.introduction ?? "")
                    .font(.pointFont(.body, size: 14))
                    .foregroundColor(.gray60)
                
                Text(userInfo?.description ?? "")
                    .font(.pretendardFont(.caption, size: 12))
                    .foregroundColor(.gray60)
            }
        }
        .padding(.horizontal, 20)
        .padding(.top, 24)
        .padding(.bottom, 32)
    }
}
