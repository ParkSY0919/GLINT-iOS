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
    func optimized() -> some View {
        self
            .processors([])
            .priority(.high)
            .pipeline(.shared)
    }
}
