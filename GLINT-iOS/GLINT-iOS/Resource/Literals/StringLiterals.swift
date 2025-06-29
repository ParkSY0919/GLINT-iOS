//
//  StringLiterals.swift
//  GLINT-iOS
//
//  Created by 박신영 on 5/10/25.
//

import Foundation

enum StringLiterals {}

extension StringLiterals {
    
    static let categories: [FilterCategoryItem] = [
        FilterCategoryItem(icon: ImageLiterals.Main.food, name: "푸드"),
        FilterCategoryItem(icon: ImageLiterals.Main.person, name: "인물"),
        FilterCategoryItem(icon: ImageLiterals.Main.landscape, name: "풍경"),
        FilterCategoryItem(icon: ImageLiterals.Main.nightscape, name: "야경"),
        FilterCategoryItem(icon: ImageLiterals.Main.star, name: "별")
    ]
    
}
