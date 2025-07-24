//
//  MessageInputSectionView.swift
//  GLINT-iOS
//
//  Created by 박신영 on 7/8/25.
//

import SwiftUI

struct MessageInputSectionView: View {
    let newMessage: String
    let isConnected: Bool
    let isUploading: Bool
    let selectedImages: [UIImage]
    let onMessageChanged: (String) -> Void
    let onSendMessage: () -> Void
    let onAttachFile: () -> Void
    let onRemoveImage: (Int) -> Void
    
    @FocusState private var isTextFieldFocused: Bool
    
    var body: some View {
        VStack(spacing: 0) {
            // 선택된 이미지들 표시
            if !selectedImages.isEmpty {
                selectedImagesView
            }
            
            // 상단 구분선
            Rectangle()
                .frame(height: 0.5)
                .foregroundStyle(Color.glintTextSecondary.opacity(0.2))
            
            HStack(spacing: 12) {
                // 파일 첨부 버튼
                Button {
                    onAttachFile()
                } label: {
                    Image(systemName: "plus.circle.fill")
                        .font(.system(size: 28, weight: .medium))
                        .foregroundStyle(
                            isUploading ? Color.glintTextSecondary.opacity(0.5) : Color.glintPrimary
                        )
                }
                .disabled(isUploading)
                .scaleEffect(isUploading ? 0.9 : 1.0)
                .animation(.bouncy(duration: 0.3), value: isUploading)
                
                // 메시지 입력 필드
                HStack(spacing: 8) {
                    TextField("메시지를 입력하세요", text: Binding(
                        get: { newMessage },
                        set: { onMessageChanged($0) }
                    ), axis: .vertical)
                    .focused($isTextFieldFocused)
                    .font(.system(size: 16, weight: .regular))
                    .foregroundStyle(Color.glintTextPrimary)
                    .lineLimit(1...4)
                    .disabled(isUploading)
                    .onSubmit {
                        if !newMessage.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                            onSendMessage()
                        }
                    }
                    
                    // 전송 버튼
                    Button {
                        onSendMessage()
                    } label: {
                        Image(systemName: sendButtonIcon)
                            .font(.system(size: 18, weight: .semibold))
                            .foregroundStyle(.white)
                            .frame(width: 32, height: 32)
                            .background(
                                Circle()
                                    .fill(sendButtonGradient)
                                    .shadow(color: sendButtonShadowColor, radius: 4, x: 0, y: 2)
                            )
                    }
                    .disabled(isSendButtonDisabled)
                    .scaleEffect(isSendButtonDisabled ? 0.8 : 1.0)
                    .opacity(isSendButtonDisabled ? 0.6 : 1.0)
                    .animation(.bouncy(duration: 0.3), value: isSendButtonDisabled)
                }
                .padding(.horizontal, 16)
                .padding(.vertical, 12)
                .background(
                    RoundedRectangle(cornerRadius: 24)
                        .fill(Color.glintCardBackground)
                        .stroke(
                            isTextFieldFocused ? Color.glintPrimary.opacity(0.6) : Color.glintTextSecondary.opacity(0.2),
                            lineWidth: isTextFieldFocused ? 2 : 1
                        )
                        .shadow(
                            color: isTextFieldFocused ? Color.glintPrimary.opacity(0.1) : Color.black.opacity(0.02),
                            radius: isTextFieldFocused ? 8 : 2,
                            x: 0,
                            y: isTextFieldFocused ? 4 : 1
                        )
                )
                .animation(.smooth(duration: 0.2), value: isTextFieldFocused)
            }
            .padding(.horizontal, 16)
            .padding(.top, 12)
            .padding(.bottom, 16)
            .background(
                Rectangle()
                    .fill(.ultraThinMaterial)
                    .ignoresSafeArea(edges: .bottom)
            )
        }
    }
}

private extension MessageInputSectionView {
    var sendButtonIcon: String {
        if isUploading {
            return "hourglass"
        } else if !isConnected {
            return "wifi.slash"
        } else {
            return "paperplane.fill"
        }
    }
    
    var sendButtonGradient: LinearGradient {
        if isUploading {
            return LinearGradient(
                colors: [Color.glintWarning, Color.glintWarning.opacity(0.8)],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        } else if !isConnected {
            return LinearGradient(
                colors: [Color.glintError, Color.glintError.opacity(0.8)],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        } else {
            return LinearGradient(
                colors: [Color.glintPrimary, Color.glintAccent],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        }
    }
    
    var sendButtonShadowColor: Color {
        if isUploading {
            return Color.glintWarning.opacity(0.3)
        } else if !isConnected {
            return Color.glintError.opacity(0.3)
        } else {
            return Color.glintPrimary.opacity(0.3)
        }
    }
    
    var isSendButtonDisabled: Bool {
        return isUploading || 
               (newMessage.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty && 
                selectedImages.isEmpty)
    }
    
    var selectedImagesView: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 12) {
                ForEach(selectedImages.indices, id: \.self) { index in
                    ZStack(alignment: .topTrailing) {
                        // 이미지
                        Image(uiImage: selectedImages[index])
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                            .frame(width: 80, height: 80)
                            .clipShape(RoundedRectangle(cornerRadius: 12))
                        
                        // X 버튼
                        Button {
                            onRemoveImage(index)
                        } label: {
                            Image(systemName: "xmark.circle.fill")
                                .font(.system(size: 20))
                                .foregroundStyle(.white)
                                .background(
                                    Circle()
                                        .fill(.black.opacity(0.6))
                                        .frame(width: 20, height: 20)
                                )
                        }
                        .offset(x: 6, y: -6)
                    }
                }
            }
            .padding(.horizontal, 16)
        }
        .frame(height: 100)
        .background(Color.glintBackground.opacity(0.5))
    }
} 
