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
        contentView
            .padding(.horizontal, 20)
            .padding(.top, 24)
            .padding(.bottom, 32)
    }
}

private extension AuthorSectionView {
    var contentView: some View {
        VStack(alignment: .leading, spacing: 16) {
            profileSection
            hashTagSection
            profileInfoSection
        }
    }
    
    var profileSection: some View {
        GTProfileView(
            userInfo: userInfo,
            isEnableChat: true,
            onTapMessageBtn: onTapMessageBtn
        )
        .prefetchImageIfPresent(userInfo?.profileImageURL)
    }
    
    @ViewBuilder
    var hashTagSection: some View {
        if let hashTags = userInfo?.hashTags, !hashTags.isEmpty {
            GTHashTagsView(hashTags: hashTags)
        }
    }
    
    @ViewBuilder
    var profileInfoSection: some View {
        if hasProfileInfo {
            GTProfileInfoView(
                introduction: userInfo?.introduction,
                description: userInfo?.description
            )
        }
    }
    
    var hasProfileInfo: Bool {
        let hasIntro = userInfo?.introduction?.isEmpty == false
        let hasDesc = userInfo?.description?.isEmpty == false
        return hasIntro || hasDesc
    }
}

