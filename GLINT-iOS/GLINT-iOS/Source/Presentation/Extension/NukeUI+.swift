//
//  NukeUI+.swift
//  GLINT-iOS
//
//  Created by 박신영 on 6/26/25.
//

import SwiftUI

import NukeUI

extension LazyImage {
    /// 최적화된 LazyImage 설정 (고성능)
    func optimized(for imageType: NetworkAwareCacheManager.ImageType = .detail) -> some View {
        self
            .processors(NetworkAwareCacheManager.shared.getOptimizedProcessors(for: imageType))
            .priority(.high)
            .pipeline(.shared)
    }
    
    /// 기존 호환성을 위한 메서드 (deprecated)
    @available(*, deprecated, message: "Use optimized(for:) instead")
    func optimized() -> some View {
        self.optimized(for: .detail)
    }
}
