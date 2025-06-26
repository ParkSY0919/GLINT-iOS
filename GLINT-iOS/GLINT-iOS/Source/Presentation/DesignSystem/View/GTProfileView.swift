//
//  GTProfileView.swift
//  GLINT-iOS
//
//  Created by 박신영 on 6/26/25.
//

import SwiftUI

struct GTProfileView: View {
    let userInfo: ProfileEntity?
    let isEnableChat: Bool
    let onTapMessageBtn: () -> Void
    
    var body: some View {
        HStack(spacing: 12) {
            // 프로필 이미지
            profileImage
            // 프로필 정보
            profileInfo
            Spacer()
            // 채팅 버튼
            if isEnableChat { messageButton }
        }
    }
}

private extension GTProfileView {
    @ViewBuilder
    var profileImage: some View {
        if let urlString = userInfo?.profileImageURL, !urlString.isEmpty {
            GTLazyImageView(urlString: urlString) { image in
                image
                    .aspectRatio(contentMode: .fill)
                    .frame(width: 72, height: 72)
                    .clipShape(Circle())
            }
        } else {
            ImageLiterals.TabBar.profile
                .resizable()  // 👈 추가 필요
                .aspectRatio(contentMode: .fill)
                .frame(width: 72, height: 72)
                .clipShape(Circle())
                .overlay(
                    Circle()
                        .stroke(Color.white, lineWidth: 1)
                )
        }
    }
    
    var profileInfo: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(userInfo?.name ?? "")
                .font(.pointFont(.body, size: 20))
                .foregroundColor(.gray30)
            
            Text(userInfo?.nick ?? "")
                .font(.pretendardFont(.body_medium, size: 16))
                .foregroundColor(.gray75)
        }
    }
    
    var messageButton: some View {
        Button {
            onTapMessageBtn()
        } label: {
            Image(systemName: "paperplane.fill")
                .font(.system(size: 20))
                .foregroundColor(.gray0)
        }
        .frame(width: 44, height: 44)
        .background(.brandBright)
        .clipShape(Circle())
    }
}
