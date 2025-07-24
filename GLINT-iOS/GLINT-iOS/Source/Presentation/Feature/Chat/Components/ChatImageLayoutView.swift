//
//  ChatImageLayoutView.swift
//  GLINT-iOS
//
//  Created by 박신영 on 7/8/25.
//

import SwiftUI

struct ChatImageLayoutView: View {
    let imageUrls: [String]
    let onImageTapped: (Int) -> Void
    
    var body: some View {
        Group {
            switch imageUrls.count {
            case 1:
                singleImageLayout
            case 2:
                doubleImageLayout
            case 3:
                tripleImageLayout
            case 4:
                quadImageLayout
            case 5...:
                fiveImageLayout
            default:
                EmptyView()
            }
        }
    }
}

private extension ChatImageLayoutView {
    var singleImageLayout: some View {
        Button {
            onImageTapped(0)
        } label: {
            GTLazyImageView(urlString: imageUrls[0].imageURL) { image in
                image
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .frame(width: 200, height: 200)
                    .clipShape(RoundedRectangle(cornerRadius: 12))
            }
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(Color.gray, lineWidth: 0.4)
            )
        }
    }
    
    var doubleImageLayout: some View {
        HStack(spacing: 4) {
            ForEach(0..<2, id: \.self) { index in
                Button {
                    onImageTapped(index)
                } label: {
                    GTLazyImageView(urlString: imageUrls[index].imageURL) { image in
                        image
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                            .frame(width: 98, height: 200)
                            .clipShape(RoundedRectangle(cornerRadius: 12))
                    }
                    .overlay(
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(Color.gray, lineWidth: 0.4)
                    )
                }
            }
        }
    }
    
    var tripleImageLayout: some View {
        HStack(spacing: 4) {
            // 첫 번째 이미지 (좌측 세로 절반)
            Button {
                onImageTapped(0)
            } label: {
                GTLazyImageView(urlString: imageUrls[0].imageURL) { image in
                    image
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                        .frame(width: 120, height: 250)
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                }
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(Color.gray, lineWidth: 0.4)
                )
            }
            
            // 2, 3번째 이미지 (우측 상하 배치)
            VStack(spacing: 4) {
                ForEach(1..<3, id: \.self) { index in
                    Button {
                        onImageTapped(index)
                    } label: {
                        GTLazyImageView(urlString: imageUrls[index].imageURL) { image in
                            image
                                .resizable()
                                .aspectRatio(contentMode: .fill)
                                .frame(width: 78, height: 123)
                                .clipShape(RoundedRectangle(cornerRadius: 12))
                        }
                        .overlay(
                            RoundedRectangle(cornerRadius: 12)
                                .stroke(Color.gray, lineWidth: 0.4)
                        )
                    }
                }
            }
        }
    }
    
    var quadImageLayout: some View {
        VStack(spacing: 4) {
            HStack(spacing: 4) {
                ForEach(0..<2, id: \.self) { index in
                    Button {
                        onImageTapped(index)
                    } label: {
                        GTLazyImageView(urlString: imageUrls[index].imageURL) { image in
                            image
                                .resizable()
                                .aspectRatio(contentMode: .fill)
                                .frame(width: 98, height: 123)
                                .clipShape(RoundedRectangle(cornerRadius: 12))
                        }
                        .overlay(
                            RoundedRectangle(cornerRadius: 12)
                                .stroke(Color.gray, lineWidth: 0.4)
                        )
                    }
                }
            }
            
            HStack(spacing: 4) {
                ForEach(2..<4, id: \.self) { index in
                    Button {
                        onImageTapped(index)
                    } label: {
                        GTLazyImageView(urlString: imageUrls[index].imageURL) { image in
                            image
                                .resizable()
                                .aspectRatio(contentMode: .fill)
                                .frame(width: 98, height: 123)
                                .clipShape(RoundedRectangle(cornerRadius: 12))
                        }
                        .overlay(
                            RoundedRectangle(cornerRadius: 12)
                                .stroke(Color.gray, lineWidth: 0.4)
                        )
                    }
                }
            }
        }
    }
    
    var fiveImageLayout: some View {
        VStack(spacing: 4) {
            // 상단 2x2 그리드
            VStack(spacing: 4) {
                HStack(spacing: 4) {
                    ForEach(0..<2, id: \.self) { index in
                        Button {
                            onImageTapped(index)
                        } label: {
                            GTLazyImageView(urlString: imageUrls[index].imageURL) { image in
                                image
                                    .resizable()
                                    .aspectRatio(contentMode: .fill)
                                    .frame(width: 98, height: 98)
                                    .clipShape(RoundedRectangle(cornerRadius: 12))
                            }
                            .overlay(
                                RoundedRectangle(cornerRadius: 12)
                                    .stroke(Color.gray, lineWidth: 0.4)
                            )
                        }
                    }
                }
                
                HStack(spacing: 4) {
                    ForEach(2..<4, id: \.self) { index in
                        Button {
                            onImageTapped(index)
                        } label: {
                            GTLazyImageView(urlString: imageUrls[index].imageURL) { image in
                                image
                                    .resizable()
                                    .aspectRatio(contentMode: .fill)
                                    .frame(width: 98, height: 98)
                                    .clipShape(RoundedRectangle(cornerRadius: 12))
                            }
                            .overlay(
                                RoundedRectangle(cornerRadius: 12)
                                    .stroke(Color.gray, lineWidth: 0.4)
                            )
                        }
                    }
                }
            }
            
            // 하단 직사각형 이미지
            Button {
                onImageTapped(4)
            } label: {
                GTLazyImageView(urlString: imageUrls[4].imageURL) { image in
                    image
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                        .frame(width: 200, height: 80)
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                }
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(Color.gray, lineWidth: 0.4)
                )
            }
        }
    }
} 
