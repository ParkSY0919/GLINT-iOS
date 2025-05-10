//
//  ConstantLiterals.swift
//  GLINT-iOS
//
//  Created by 박신영 on 5/10/25.
//

import SwiftUI

struct ConstantLiterals {
    
    enum ScreenSize {
        static var width: CGFloat {
            guard let window = UIApplication.shared.connectedScenes.first as? UIWindowScene else {
                fatalError()
            }
            return window.screen.bounds.width
        }
        
        static var height: CGFloat {
            guard let window = UIApplication.shared.connectedScenes.first as? UIWindowScene else {
                fatalError()
            }
            return window.screen.bounds.height
        }
    }
    
}
