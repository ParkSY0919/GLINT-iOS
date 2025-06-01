//
//  LikeButton.swift
//  GLINT-iOS
//
//  Created by AI Assistant on 1/19/25.
//

import SwiftUI

struct LikeButton: View {
    @Binding var isLiked: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            Image(systemName: isLiked ? "heart.fill" : "heart")
                .font(.system(size: 20, weight: .medium))
                .foregroundColor(isLiked ? .red : .gray75)
        }
        .frame(width: 44, height: 44)
        .contentShape(Rectangle())
    }
}

struct LikeButton_Previews: PreviewProvider {
    static var previews: some View {
        HStack(spacing: 20) {
            LikeButton(isLiked: .constant(false)) {
                print("Like button tapped")
            }
            
            LikeButton(isLiked: .constant(true)) {
                print("Like button tapped")
            }
        }
        .padding()
    }
} 