//
//  FilterCategoryItem.swift
//  GLINT-iOS
//
//  Created by 박신영 on 6/29/25.
//

import SwiftUI

struct FilterCategoryItem: Identifiable, Equatable {
    enum CategoryType: String, CaseIterable {
        case 푸드 = "푸드"
        case 인물 = "인물"
        case 풍경 = "풍경"
        case 야경 = "야경"
        case 별 = "별"
        
        var displayName: String {
            return self.rawValue
        }
    }
    
    let id = UUID()
    let icon: Image
    let name: String
}
