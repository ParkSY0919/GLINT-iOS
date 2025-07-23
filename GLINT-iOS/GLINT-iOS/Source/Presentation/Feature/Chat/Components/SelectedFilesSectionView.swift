//
//  SelectedFilesSectionView.swift
//  GLINT-iOS
//
//  Created by 박신영 on 7/8/25.
//

import SwiftUI

struct SelectedFilesSectionView: View {
    let selectedFiles: [URL]
    let onRemoveFile: (Int) -> Void
    
    var body: some View {
        Group {
            if !selectedFiles.isEmpty {
                selectedFilesContent
                    .transition(.move(edge: .bottom).combined(with: .opacity))
            }
        }
    }
}

private extension SelectedFilesSectionView {
    var selectedFilesContent: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 12) {
                ForEach(Array(selectedFiles.enumerated()), id: \.offset) { index, fileURL in
                    VStack(spacing: 8) {
                        ZStack {
                            RoundedRectangle(cornerRadius: 12)
                                .fill(Color.glintSecondary)
                                .frame(width: 60, height: 60)
                            
                            Image(systemName: "doc.fill")
                                .font(.system(size: 24, weight: .medium))
                                .foregroundStyle(Color.glintPrimary)
                        }
                        
                        Text(fileURL.lastPathComponent)
                            .font(.system(size: 11, weight: .medium))
                            .foregroundStyle(Color.glintTextSecondary)
                            .lineLimit(2)
                            .multilineTextAlignment(.center)
                            .frame(width: 80)
                        
                        Button {
                            onRemoveFile(index)
                        } label: {
                            Image(systemName: "xmark.circle.fill")
                                .font(.system(size: 16, weight: .medium))
                                .foregroundStyle(Color.glintError)
                        }
                    }
                    .padding(8)
                    .background(
                        RoundedRectangle(cornerRadius: 16)
                            .fill(Color.glintCardBackground)
                            .shadow(color: Color.black.opacity(0.05), radius: 2, x: 0, y: 1)
                    )
                }
            }
            .padding(.horizontal, 20)
        }
        .padding(.vertical, 12)
        .background(Color.glintBackground)
    }
} 
