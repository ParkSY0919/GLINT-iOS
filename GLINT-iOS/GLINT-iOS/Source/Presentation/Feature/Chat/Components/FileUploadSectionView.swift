//
//  FileUploadSectionView.swift
//  GLINT-iOS
//
//  Created by 박신영 on 7/8/25.
//

import SwiftUI

struct FileUploadSectionView: View {
    let isUploading: Bool
    let uploadProgress: Double
    
    var body: some View {
        Group {
            if isUploading {
                uploadProgressContent
                    .transition(.move(edge: .bottom).combined(with: .opacity))
            }
        }
    }
}

private extension FileUploadSectionView {
    var uploadProgressContent: some View {
        VStack(spacing: 8) {
            HStack {
                Image(systemName: "icloud.and.arrow.up")
                    .foregroundStyle(Color.glintPrimary)
                    .font(.system(size: 16, weight: .medium))
                
                Text("파일 업로드 중...")
                    .font(.system(size: 14, weight: .medium))
                    .foregroundStyle(Color.glintTextPrimary)
                
                Spacer()
                
                Text("\(Int(uploadProgress * 100))%")
                    .font(.system(size: 13, weight: .semibold))
                    .foregroundStyle(Color.glintPrimary)
                    .monospacedDigit()
            }
            
            ProgressView(value: uploadProgress)
                .progressViewStyle(LinearProgressViewStyle(tint: Color.glintPrimary))
                .scaleEffect(y: 0.8)
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 12)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color.glintCardBackground)
                .shadow(color: Color.black.opacity(0.05), radius: 4, x: 0, y: 2)
        )
        .padding(.horizontal, 16)
    }
} 
