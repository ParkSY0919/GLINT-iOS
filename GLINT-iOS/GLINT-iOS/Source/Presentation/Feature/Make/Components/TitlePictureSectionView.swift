//
//  TitlePictureSectionView.swift
//  GLINT-iOS
//
//  Created by AI Assistant on 1/19/25.
//

import SwiftUI
import PhotosUI

struct TitlePictureSectionView: View {
    let selectedImage: UIImage?
    let imageMetaData: PhotoMetadataModel?
    let address: String?
    let onImageSelected: (UIImage, PhotoMetadataModel?) -> Void // 메타데이터도 함께 전달
    let onImageChangeRequested: () -> Void
    let onEditButtonTapped: () -> Void
    
    @State private var showingImagePicker = false
    @State private var showingChangeImagePicker = false
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            // 타이틀과 버튼들
            HStack {
                Text("대표 사진 등록")
                    .font(.pretendardFont(.body_bold, size: 16))
                    .foregroundColor(.gray60)
                    .padding(.leading, 20)
                
                Spacer()
                
                if selectedImage != nil {
                    Button("사진 변경하기") {
                        showingChangeImagePicker = true
                    }
                    .font(.pretendardFont(.body_medium, size: 16))
                    .foregroundColor(.brandDeep)
                    
                    Button("수정하기") {
                        onEditButtonTapped()
                    }
                    .font(.pretendardFont(.body_medium, size: 16))
                    .foregroundColor(.brandDeep)
                    .padding(.leading, 8)
                    .padding(.trailing, 22)
                }
            }
            
            // 이미지 영역
            if let image = selectedImage {
                // 선택된 이미지 표시
                GeometryReader { geometry in
                    let imageWidth = geometry.size.width - 40
                    let imageAspectRatio = image.size.width / image.size.height
                    let imageHeight = imageWidth / imageAspectRatio
                    
                    Image(uiImage: image)
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                        .frame(width: imageWidth, height: imageHeight)
                        .clipRectangle(12)
                        .overlay(
                            RoundedRectangle(cornerRadius: 12, style: .continuous)
                                .strokeBorder(.brandDeep, lineWidth: 2)
                        )
                        .padding(.horizontal, 20)
                    
                }
                .frame(height: calculateImageHeight(for: selectedImage, containerWidth: UIScreen.main.bounds.width - 40))
                
                
                
                // 메타데이터 표시
                if let metaData = imageMetaData {
                    GLMetaDataView(
                        camera: metaData.camera,
                        photoMetadataString: metaData.photoMetadataString,
                        megapixelInfo: metaData.megapixelInfo,
                        address: address,
                        latitude: metaData.latitude,
                        longitude: metaData.longitude
                    )
                }
            } else {
                // 이미지 추가 버튼
                Button {
                    showingImagePicker = true
                } label: {
                    RoundedRectangle(cornerRadius: 12)
                        .fill(.gray90)
                        .frame(height: 200)
                        .overlay {
                            Image(systemName: "plus")
                                .font(.system(size: 40, weight: .light))
                                .foregroundColor(.gray60)
                        }
                        .padding(.horizontal, 20)
                }
                .buttonStyle(.plain)
            }
        }
        .padding(.top, 26)
        .sheet(isPresented: $showingImagePicker) {
            ImagePicker { image, metadata in
                onImageSelected(image, metadata)
            }
        }
        .sheet(isPresented: $showingChangeImagePicker) {
            ImagePicker { image, metadata in
                onImageSelected(image, metadata)
            }
        }
    }
    
    private func calculateImageHeight(for image: UIImage?, containerWidth: CGFloat) -> CGFloat {
        guard let image = image else { return 200 }
        let aspectRatio = image.size.width / image.size.height
        return containerWidth / aspectRatio
    }
}


