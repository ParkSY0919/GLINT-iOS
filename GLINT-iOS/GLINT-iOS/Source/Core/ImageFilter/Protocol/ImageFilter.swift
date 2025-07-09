//
//  ImageFilter.swift
//  GLINT-iOS
//
//  Created by 박신영
//

import CoreImage
import UIKit

protocol ImageFilter {
    func apply(to image: CIImage, value: Float) -> CIImage?
    var defaultValue: Float { get }
    var range: ClosedRange<Float> { get }
} 
