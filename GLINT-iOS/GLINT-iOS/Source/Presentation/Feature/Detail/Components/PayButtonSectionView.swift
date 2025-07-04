//
//  PayButtonSectionView.swift
//  GLINT-iOS
//
//  Created by AI Assistant on 1/19/25.
//

import SwiftUI

struct PayButtonSectionView: View {
    let isPurchased: Bool
    let onPurchaseButtonTapped: () -> Void
    
    var body: some View {
        Button {
            onPurchaseButtonTapped()
        } label: {
            Text(isPurchased ? Strings.Detail.purchaseCompleted : Strings.Detail.payNow)
                .font(.pretendardFont(.body_bold, size: 16))
                .foregroundColor(.white)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 16)
                .background(isPurchased ? .gray75 : .brandBright)
                .clipRectangle(12)
        }
        .disabled(isPurchased)
        .padding(.horizontal, 20)
        .padding(.top, 24)
    }
} 