//
//  StringLiterals.swift
//  GLINT-iOS
//
//  Created by 박신영 on 5/10/25.
//

import Foundation

enum StringLiterals {}

extension StringLiterals {
    
    static let categories: [FilterCategoryModel] = [
        FilterCategoryModel(icon: ImageLiterals.Main.food, name: "푸드"),
        FilterCategoryModel(icon: ImageLiterals.Main.person, name: "인물"),
        FilterCategoryModel(icon: ImageLiterals.Main.landscape, name: "풍경"),
        FilterCategoryModel(icon: ImageLiterals.Main.nightscape, name: "야경"),
        FilterCategoryModel(icon: ImageLiterals.Main.star, name: "별")
    ]
    
}
