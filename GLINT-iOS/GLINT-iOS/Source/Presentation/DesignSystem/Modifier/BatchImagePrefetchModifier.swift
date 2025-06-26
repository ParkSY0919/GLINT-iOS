//
//  BatchImagePrefetchModifier.swift
//  GLINT-iOS
//
//  Created by 박신영 on 6/26/25.
//

import SwiftUI

import Nuke

struct BatchImagePrefetchModifier: ViewModifier {
    let imageURLs: [String]
    let batchSize: Int
    let delay: TimeInterval
    let priority: ImageRequest.Priority
    
    init(
        imageURLs: [String],
        batchSize: Int = 5,
        delay: TimeInterval = 0.1,
        priority: ImageRequest.Priority = .normal
    ) {
        self.imageURLs = imageURLs
        self.batchSize = batchSize
        self.delay = delay
        self.priority = priority
    }
    
    func body(content: Content) -> some View {
        content
            .onAppear {
                prefetchImagesInBatches()
            }
    }
    
    private func prefetchImagesInBatches() {
        let urls = imageURLs.compactMap { URL(string: $0) }
        guard !urls.isEmpty else { return }
        
        // URL을 배치로 나누기
        let batches = urls.chunked(into: batchSize)
        
        // 각 배치를 지연시간을 두고 프리페치
        for (index, batch) in batches.enumerated() {
            let delayTime = Double(index) * delay
            
            DispatchQueue.main.asyncAfter(deadline: .now() + delayTime) {
                let prefetcher = ImagePrefetcher()
                prefetcher.startPrefetching(with: batch)
            }
        }
    }
}

extension View {
    /// 대량 이미지 배치 프리페칭
    func prefetchImagesInBatches(
        _ imageURLs: [String],
        batchSize: Int = 5,
        delay: TimeInterval = 0.1,
        priority: ImageRequest.Priority = .normal
    ) -> some View {
        self.modifier(BatchImagePrefetchModifier(
            imageURLs: imageURLs,
            batchSize: batchSize,
            delay: delay,
            priority: priority
        ))
    }
}
