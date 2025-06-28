//
//  Array+.swift
//  GLINT-iOS
//
//  Created by 박신영 on 6/26/25.
//

import Foundation

extension Array {
    func chunked(into size: Int) -> [[Element]] {
        return stride(from: 0, to: count, by: size).map {
            Array(self[$0..<Swift.min($0 + size, count)])
        }
    }
}
