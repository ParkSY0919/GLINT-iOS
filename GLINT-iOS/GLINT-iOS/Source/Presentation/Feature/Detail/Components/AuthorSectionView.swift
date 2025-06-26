//
//  AuthorSectionView.swift
//  GLINT-iOS
//
//  Created by AI Assistant on 1/19/25.
//

import SwiftUI

/// 작가 프로필 섹션
struct AuthorSectionView: View {
    let userInfo: ProfileEntity?
    let onTapMessageBtn: () -> Void
    
    var body: some View {
        content
            .padding(.horizontal, 20)
            .padding(.top, 24)
            .padding(.bottom, 32)
    }
}

private extension AuthorSectionView {
    var content: some View {
        VStack(alignment: .leading, spacing: 16) {
            // 작가 프로필
            GTProfileView(
                userInfo: userInfo,
                isEnableChat: true,
                onTapMessageBtn: onTapMessageBtn
            )
            .prefetchImageIfPresent(userInfo?.profileImageURL)
            
            // 해시태그
            if let hashTags = userInfo?.hashTags, !hashTags.isEmpty {
                GTHashTagsView(hashTags: hashTags)
            }
            
            // 작가 소개
            if hasProfileInfo {
                GTProfileInfoView(
                    introduction: userInfo?.introduction,
                    description: userInfo?.description
                )
            }
        }
    }
    
    private var hasProfileInfo: Bool {
        let hasIntro = userInfo?.introduction?.isEmpty == false
        let hasDesc = userInfo?.description?.isEmpty == false
        return hasIntro || hasDesc
    }
}

