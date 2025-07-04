//
//  GTNavigationModifier.swift
//  GLINT-iOS
//
//  Created by 박신영 on 6/1/25.
//

import SwiftUI

struct GTNavigationSetupModifier: ViewModifier {
    let title: String
    let isLiked: Bool?
    let onBackButtonTapped: (() -> Void)?
    let onLikeButtonTapped: (() -> Void)?
    let onRightButtonTapped: (() -> Void)?
    
    func body(content: Content) -> some View {
        content
            .navigationTitle(title)
            .navigationBarTitleDisplayMode(.inline)
            .navigationBarBackButtonHidden(true)
            .toolbar {
                if let backAction = onBackButtonTapped {
                    ToolbarItem(placement: .navigationBarLeading) {
                        Button(action: backAction) {
                            Image(systemName: "arrow.left")
                                .frame(width: 32, height: 32)
                                .font(.system(size: 16, weight: .medium))
                                .foregroundColor(.gray75)
                        }
                    }
                }
                
                if let likeAction = onLikeButtonTapped,
                   let likedState = isLiked {
                    ToolbarItem(placement: .topBarTrailing) {
                        GTLikeButton(
                            likedState: likedState,
                            action: likeAction
                        )
                    }
                }
                
                if let uploadAction = onRightButtonTapped {
                    ToolbarItem(placement: .topBarTrailing) {
                        Button(action: uploadAction) {
                            Images.Make.upload
                                .frame(width: 32, height: 32)
                                .font(.system(size: 16, weight: .medium))
                                .foregroundColor(.gray75)
                        }
                    }
                }
            }
    }
}

extension View {
    func navigationSetup(
        title: String,
        isLiked: Bool? = false,
        onBackButtonTapped: (() -> Void)? = nil,
        onLikeButtonTapped: (() -> Void)? = nil,
        onRightButtonTapped: (() -> Void)? = nil
    ) -> some View {
        self.modifier(
            GTNavigationSetupModifier(
                title: title,
                isLiked: isLiked,
                onBackButtonTapped: onBackButtonTapped,
                onLikeButtonTapped: onLikeButtonTapped,
                onRightButtonTapped: onRightButtonTapped
            )
        )
    }
}
