//
//  DetailViewData.swift
//  GLINT-iOS
//
//  Created by AI Assistant on 1/19/25.
//

import Foundation

// MARK: - Helper Extensions
extension Array where Element == String {
    func toStringArray() -> [String] {
        return self
    }
}

// MARK: - Helper Functions
struct DetailViewHelper {
    static func formatCount(_ count: Int) -> String {
        if count >= 1000 {
            return "\(count / 1000)k"
        }
        return "\(count)"
    }
    
    static func formatPrice(_ price: Int) -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        return formatter.string(from: NSNumber(value: price)) ?? "\(price)"
    }
} 