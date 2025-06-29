//
//  FilterCategoryItem.swift
//  GLINT-iOS
//
//  Created by 박신영 on 6/29/25.
//

import SwiftUI

struct FilterCategoryItem: Identifiable, Equatable {
    let id = UUID()
    let icon: Image
    let name: String
}
