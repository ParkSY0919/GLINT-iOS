//
//  ConnectionStatusSectionView.swift
//  GLINT-iOS
//
//  Created by 박신영 on 7/8/25.
//

import SwiftUI

struct ConnectionStatusSectionView: View {
    let isConnected: Bool
    let onRetryTapped: () -> Void
    
    var body: some View {
        Group {
            if !isConnected {
                connectionStatusContent
                    .transition(.move(edge: .top).combined(with: .opacity))
            }
        }
    }
}

private extension ConnectionStatusSectionView {
    var connectionStatusContent: some View {
        HStack(spacing: 12) {
            Image(systemName: "wifi.slash")
                .foregroundStyle(.white)
                .font(.system(size: 16, weight: .medium))
            
            VStack(alignment: .leading, spacing: 2) {
                Text("연결이 끊어졌습니다")
                    .font(.system(size: 14, weight: .medium))
                    .foregroundStyle(.white)
                
                Text("재연결을 시도하는 중...")
                    .font(.system(size: 12, weight: .regular))
                    .foregroundStyle(.white.opacity(0.8))
            }
            
            Spacer()
            
            Button("재시도") {
                onRetryTapped()
            }
            .font(.system(size: 13, weight: .semibold))
            .foregroundStyle(.white)
            .padding(.horizontal, 12)
            .padding(.vertical, 6)
            .background(.white.opacity(0.2))
            .clipShape(Capsule())
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 12)
        .background(
            LinearGradient(
                colors: [Color.glintError, Color.glintError.opacity(0.8)],
                startPoint: .leading,
                endPoint: .trailing
            )
        )
        .overlay(alignment: .bottom) {
            Rectangle()
                .frame(height: 1)
                .foregroundStyle(.white.opacity(0.3))
        }
    }
} 