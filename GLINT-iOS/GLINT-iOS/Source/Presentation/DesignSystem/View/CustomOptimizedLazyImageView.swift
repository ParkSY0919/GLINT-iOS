//
//  CustomOptimizedLazyImageView.swift
//  GLINT-iOS
//
//  Created by 박신영 on 6/26/25.
//

import SwiftUI

import NukeUI

/// NukeUI: 커스텀 로딩/에러 UI 필요한 경우
struct CustomOptimizedLazyImageView<Content: View>: View {
    let urlString: String
    let priority: ImageRequest.Priority
    let stateTransform: (LazyImageState) -> Content
    
    init(
        urlString: String,
        priority: ImageRequest.Priority = .high,
        @ViewBuilder content: @escaping (LazyImageState) -> Content
    ) {
        self.urlString = urlString
        self.priority = priority
        self.stateTransform = content
    }
    
    var body: some View {
        LazyImage(url: URL(string: urlString), content: stateTransform)
            .processors([])
            .priority(priority)
            .pipeline(.shared)
    }
}
