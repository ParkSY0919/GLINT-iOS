//
//  GTLikeButton.swift
//  GLINT-iOS
//
//  Created by AI Assistant on 1/19/25.
//

import SwiftUI

struct GTLikeButton: View {
    let likedState: Bool
    let action: () -> Void
    
    var body: some View {
        let image = likedState ? ImageLiterals.Detail.likeFill : ImageLiterals.Detail.like
        
        Button {
            let impactFeedback = UIImpactFeedbackGenerator(style: .light)
            impactFeedback.impactOccurred()
            
            action()
        } label: {
            image
                .font(.system(size: 20, weight: .medium))
                .foregroundColor(likedState ? .brandBright : .gray75)
                .scaleEffect(likedState ? 1.1 : 1.0)
        }
        .frame(width: 44, height: 44)
        .contentShape(Rectangle())
        .animation(.spring(response: 0.3, dampingFraction: 0.6), value: likedState)
    }
}
