//
//  Color+.swift
//  GLINT-iOS
//
//  Created by 박신영 on 5/12/25.
//

import SwiftUI

//extension UIColor {
//    
//    convenience init(hexCode: String, alpha: CGFloat = 1.0) {
//        var hexFormatted: String = hexCode.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines).uppercased()
//        
//        if hexFormatted.hasPrefix("#") {
//            hexFormatted = String(hexFormatted.dropFirst())
//        }
//        
//        assert(hexFormatted.count == 6, "Invalid hex code used.")
//        
//        var rgbValue: UInt64 = 0
//        Scanner(string: hexFormatted).scanHexInt64(&rgbValue)
//        
//        self.init(red: CGFloat((rgbValue & 0xFF0000) >> 16) / 255.0,
//                  green: CGFloat((rgbValue & 0x00FF00) >> 8) / 255.0,
//                  blue: CGFloat(rgbValue & 0x0000FF) / 255.0,
//                  alpha: alpha)
//    }
//}
//
//extension Color {
//    static let brand100 = Color.brandBlack
//    static let brand200 = Color.brandDeep
//    static let brand300 = Color.brandBright
//    static let gray0: Color = .gray0
//    static let gray15 = Color.gray15
//    static let gray30 = Color.gray30
//    static let gray45 = Color.gray45
//    static let gray60 = Color.gray60
//    static let gray75 = Color.gray75
//    static let gray90 = Color.gray90
//    static let gray100 = Color.gray100
//}

extension Color {
    static let textFieldBackground = Color(UIColor.systemGray6)
    static let primaryButtonBackground = Color.brandBright
    static let primaryButtonText = Color.white
    static let socialButtonBackground = Color.black
    static let socialButtonForeground = Color.white // Apple 로고용
    static let placeholderText = Color(UIColor.systemGray)
    static let labelText = Color.white
    static let orSignInWithText = Color.white
}
