//
//  OptimizedLazyImageView.swift
//  GLINT-iOS
//
//  Created by 박신영 on 6/26/25.
//

import SwiftUI

import NukeUI

/// NukeUI: 간단한 이미지 로딩
struct GTLazyImageView: View {
    let urlString: String
    let priority: ImageRequest.Priority
    let imageTransform: (Image) -> AnyView
    
    init(
        urlString: String,
        priority: ImageRequest.Priority = .high,
        @ViewBuilder imageTransform: @escaping (Image) -> some View
    ) {
        self.urlString = urlString
        self.priority = priority
        self.imageTransform = { AnyView(imageTransform($0)) }
    }
    
    var body: some View {
        LazyImage(url: URL(string: urlString)) { state in
            lazyImageTransform(state, transform: imageTransform)
        }
        .processors([])
        .priority(priority)
        .pipeline(.shared)
    }
}
