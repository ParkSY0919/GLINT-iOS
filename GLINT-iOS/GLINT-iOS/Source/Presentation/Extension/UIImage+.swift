//
//  UIImage+.swift
//  GLINT-iOS
//
//  Created by 박신영 on 6/30/25.
//

import UIKit

extension UIImage {
    func resized(to maxSize: CGFloat) -> UIImage? {
        let ratio = min(maxSize / size.width, maxSize / size.height)
        if ratio >= 1.0 { return self }
        
        let newSize = CGSize(width: size.width * ratio, height: size.height * ratio)
        
        let renderer = UIGraphicsImageRenderer(size: newSize)
        return renderer.image { _ in
            draw(in: CGRect(origin: .zero, size: newSize))
        }
    }
}
