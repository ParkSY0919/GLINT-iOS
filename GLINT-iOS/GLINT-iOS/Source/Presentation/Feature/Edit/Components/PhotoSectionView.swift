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
    
    // 레이아웃 상수
    private let maxHeight: CGFloat = 554
    private let buttonSize: CGFloat = 40
    private let buttonHeight: CGFloat = 32
    private let buttonSpacing: CGFloat = 8
    private let horizontalPadding: CGFloat = 20
    private let bottomPadding: CGFloat = 20
    
    init(
        originalImage: UIImage,
        filteredImage: UIImage,
        showingOriginal: Bool,
        canUndo: Bool,
        canRedo: Bool,
        onToggleImage: @escaping () -> Void,
        onUndo: @escaping () -> Void,
        onRedo: @escaping () -> Void
    ) {
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
        contentView
            .frame(width: screenWidth, height: maxHeight)
    }
}

private extension PhotoSectionView {
    var contentView: some View {
        ZStack {
            backgroundView
            imageDisplaySection
            controlButtonsOverlay
        }
    }
    
    var backgroundView: some View {
        Rectangle()
            .fill(.brandBlack)
            .frame(width: screenWidth, height: maxHeight)
    }
    
    var imageDisplaySection: some View {
        VStack {
            Spacer()
            currentImageView
                .frame(width: screenWidth, height: imageHeight)
                .clipped()
            Spacer()
        }
    }
    
    var currentImageView: some View {
        Group {
            if showingOriginal {
                originalImageView
            } else {
                filteredImageView
            }
        }
    }
    
    var originalImageView: some View {
        Image(uiImage: originalImage)
            .resizable()
            .aspectRatio(contentMode: .fit)
    }
    
    var filteredImageView: some View {
        Image(uiImage: filteredImage)
            .resizable()
            .aspectRatio(contentMode: .fit)
    }
    
    var controlButtonsOverlay: some View {
        VStack {
            Spacer()
            controlButtonsSection
        }
    }
    
    var controlButtonsSection: some View {
        HStack {
            undoRedoButtonsGroup
            Spacer()
            toggleImageButton
        }
        .padding(.horizontal, horizontalPadding)
        .padding(.bottom, bottomPadding)
    }
    
    var undoRedoButtonsGroup: some View {
        HStack(spacing: buttonSpacing) {
            undoButton
            redoButton
        }
    }
    
    var undoButton: some View {
        Button {
            onUndo()
        } label: {
            undoButtonContent
        }
        .disabled(!canUndo)
    }
    
    var undoButtonContent: some View {
        Image(systemName: "arrow.uturn.backward")
            .font(.system(size: 24, weight: .medium))
            .foregroundColor(canUndo ? .gray0 : .gray60)
            .frame(width: buttonSize, height: buttonHeight)
            .background(.brandBlack.opacity(0.5))
            .clipShape(RoundedRectangle(cornerRadius: 8))
    }
    
    var redoButton: some View {
        Button {
            onRedo()
        } label: {
            redoButtonContent
        }
        .disabled(!canRedo)
    }
    
    var redoButtonContent: some View {
        Image(systemName: "arrow.uturn.forward")
            .font(.system(size: 24, weight: .medium))
            .foregroundColor(canRedo ? .gray0 : .gray60)
            .frame(width: buttonSize, height: buttonHeight)
            .background(.brandBlack.opacity(0.5))
            .clipShape(RoundedRectangle(cornerRadius: 8))
    }
    
    var toggleImageButton: some View {
        Button {
            onToggleImage()
        } label: {
            toggleButtonContent
        }
    }
    
    var toggleButtonContent: some View {
        toggleButtonIcon
            .frame(width: buttonSize, height: buttonHeight)
            .background(.brandBlack.opacity(0.5))
            .clipShape(RoundedRectangle(cornerRadius: 8))
    }
    
    @ViewBuilder
    var toggleButtonIcon: some View {
        if showingOriginal {
            Image(systemName: "eye")
                .font(.system(size: 24, weight: .medium))
                .foregroundColor(.gray0)
        } else {
            Image(systemName: "eye")
                .font(.system(size: 24, weight: .medium))
                .foregroundStyle(
                    LinearGradient(
                        colors: [.sliderLeft, .sliderRight],
                        startPoint: .leading,
                        endPoint: .trailing
                    )
                )
        }
    }
    
    var screenWidth: CGFloat {
        UIScreen.main.bounds.width
    }
    
    var imageHeight: CGFloat {
        let imageAspectRatio = originalImage.size.width / originalImage.size.height
        let calculatedHeight = screenWidth / imageAspectRatio
        return min(calculatedHeight, maxHeight)
    }
}
