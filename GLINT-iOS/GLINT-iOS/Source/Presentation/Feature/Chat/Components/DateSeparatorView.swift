//
//  DateSeparatorView.swift
//  GLINT-iOS
//
//  Created by 박신영 on 7/8/25.
//

import SwiftUI

// MARK: - Modern Date Separator
struct DateSeparatorView: View {
    let date: String
    
    var body: some View {
        HStack {
            Rectangle()
                .frame(height: 1)
                .foregroundStyle(Color.glintTextSecondary.opacity(0.3))
            
            Text(date)
                .font(.pretendardFont(.caption_semi, size: 10))
                .foregroundStyle(Color.glintTextSecondary)
                .padding(.horizontal, 12)
                .padding(.vertical, 6)
                .background(
                    Capsule()
                        .fill(.ultraThinMaterial)
                        .overlay(
                            Capsule()
                                .stroke(Color.glintTextSecondary.opacity(0.2), lineWidth: 1)
                        )
                )
            
            Rectangle()
                .frame(height: 1)
                .foregroundStyle(Color.glintTextSecondary.opacity(0.3))
        }
        .padding(.horizontal, 20)
    }
} 
