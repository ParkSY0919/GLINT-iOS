//
//  PhotoSectionView.swift
//  GLINT-iOS
//
//  Created by AI Assistant on 1/19/25.
//

import SwiftUI

struct PhotoSectionView: View {
    let originalImage: UIImage
    let filteredImage: UIImage
    let showingOriginal: Bool
    let canUndo: Bool
    let canRedo: Bool
    let onToggleImage: () -> Void
    let onUndo: () -> Void
    let onRedo: () -> Void
    
    init(originalImage: UIImage, filteredImage: UIImage, showingOriginal: Bool, canUndo: Bool, canRedo: Bool, onToggleImage: @escaping () -> Void, onUndo: @escaping () -> Void, onRedo: @escaping () -> Void) {
        self.originalImage = originalImage
        self.filteredImage = filteredImage
        self.showingOriginal = showingOriginal
        self.canUndo = canUndo
        self.canRedo = canRedo
        self.onToggleImage = onToggleImage
        self.onUndo = onUndo
        self.onRedo = onRedo
        
        GTLogger.i("originalImage: \(originalImage.jpegData(compressionQuality: 0.6)!)")
        GTLogger.i("filteredImage: \(String(describing: filteredImage.jpegData(compressionQuality: 0.6)))")
    }
    
    var body: some View {
        let screenWidth = UIScreen.main.bounds.width
        let maxHeight: CGFloat = 554
        let imageAspectRatio = originalImage.size.width / originalImage.size.height
        let calculatedHeight = screenWidth / imageAspectRatio
        let finalHeight = min(calculatedHeight, maxHeight)
        
        ZStack {
            // 배경
            Rectangle()
                .fill(.brandBlack)
                .frame(width: screenWidth, height: maxHeight)
            
            // 이미지들 (비율에 맞게 중앙 정렬)
            VStack {
                Spacer()
                
                Group {
                    if showingOriginal {
                        Image(uiImage: originalImage)
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                    } else {
                        Image(uiImage: filteredImage)
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                    }
                }
                .frame(width: screenWidth, height: finalHeight)
                .clipped()
                
                Spacer()
            }
            
            // 좌측 하단 버튼들 (undo, redo)
            VStack {
                Spacer()
                HStack {
                    HStack(spacing: 8) {
                        // Undo 버튼
                        Button {
                            onUndo()
                        } label: {
                            Image(systemName: "arrow.uturn.backward")
                                .font(.system(size: 24, weight: .medium))
                                .foregroundColor(canUndo ? .gray0 : .gray60)
                                .frame(width: 40, height: 32)
                                .background(.brandBlack.opacity(0.5))
                                .clipShape(RoundedRectangle(cornerRadius: 8))
                        }
                        .disabled(!canUndo)
                        
                        // Redo 버튼
                        Button {
                            onRedo()
                        } label: {
                            Image(systemName: "arrow.uturn.forward")
                                .font(.system(size: 24, weight: .medium))
                                .foregroundColor(canRedo ? .gray0 : .gray60)
                                .frame(width: 40, height: 32)
                                .background(.brandBlack.opacity(0.5))
                                .clipShape(RoundedRectangle(cornerRadius: 8))
                        }
                        .disabled(!canRedo)
                    }
                    
                    Spacer()
                    
                    // 우측 하단 토글 버튼
                    Button {
                        onToggleImage()
                    } label: {
                        Image(systemName: showingOriginal ? "eye.slash" : "eye")
                            .font(.system(size: 24, weight: .medium))
                            .foregroundColor(.gray0)
                            .frame(width: 40, height: 32)
                            .background(.brandBlack.opacity(0.5))
                            .clipShape(RoundedRectangle(cornerRadius: 8))
                    }
                }
                .padding(.horizontal, 20)
                .padding(.bottom, 20)
            }
        }
        .frame(width: screenWidth, height: maxHeight)
    }
    
    private func calculateImageHeight() -> CGFloat {
        return 554  // 고정 높이
    }
} 
