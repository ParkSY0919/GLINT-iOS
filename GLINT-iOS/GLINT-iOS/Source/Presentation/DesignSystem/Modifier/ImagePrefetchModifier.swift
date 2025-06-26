//
//  ImagePrefetchModifier.swift
//  GLINT-iOS
//
//  Created by 박신영 on 6/26/25.
//

import SwiftUI

import Nuke

struct ImagePrefetchModifier: ViewModifier {
    let imageURLs: [String]
    let priority: ImageRequest.Priority
    private let imagePrefetcher = ImagePrefetcher()
    
    init(imageURLs: [String], priority: ImageRequest.Priority = .normal) {
        self.imageURLs = imageURLs
        self.priority = priority
    }
    
    func body(content: Content) -> some View {
        content
            .onAppear {
                prefetchImages()
            }
    }
    
    private func prefetchImages() {
        let urls = imageURLs.compactMap { URL(string: $0) }
        guard !urls.isEmpty else { return }
        
        imagePrefetcher.startPrefetching(with: urls)
    }
}

extension View {
    /// 단일 이미지 URL 프리페칭
    func prefetchImage(
        _ imageURL: String,
        priority: ImageRequest.Priority = .normal
    ) -> some View {
        self.modifier(ImagePrefetchModifier(
            imageURLs: [imageURL],
            priority: priority
        ))
    }
    
    /// 여러 이미지 URL 프리페칭
    func prefetchImages(
        _ imageURLs: [String],
        priority: ImageRequest.Priority = .normal
    ) -> some View {
        self.modifier(ImagePrefetchModifier(
            imageURLs: imageURLs,
            priority: priority
        ))
    }
    
    /// Optional 이미지 URL 프리페칭
    func prefetchImageIfPresent(
        _ imageURL: String?,
        priority: ImageRequest.Priority = .normal
    ) -> some View {
        self.modifier(ImagePrefetchModifier(
            imageURLs: imageURL.map { [$0] } ?? [],
            priority: priority
        ))
    }
}
