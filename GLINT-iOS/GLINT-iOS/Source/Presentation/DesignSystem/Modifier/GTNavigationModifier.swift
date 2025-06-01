//
//  GTNavigationModifier.swift
//  GLINT-iOS
//
//  Created by 박신영 on 6/1/25.
//

import SwiftUI

//TODO: Appear, titleStr, Font, backbtnhidden 등등 한번에 적용되도록 수정하기
struct NavigationTitleFontModifier: ViewModifier {
    let fontName: PointFontName
    let fontSize: CGFloat
    
    init(fontName: PointFontName, fontSize: CGFloat) {
        self.fontName = fontName
        self.fontSize = fontSize
    }
    
    func body(content: Content) -> some View {
        content
            .onAppear {
                let appearance = UINavigationBarAppearance()
                appearance.configureWithOpaqueBackground()
                appearance.backgroundColor = UIColor(Color.gray100)
                appearance.titleTextAttributes = [
                    .font: UIFont(name: fontName.rawValue, size: fontSize) ?? UIFont.systemFont(ofSize: fontSize, weight: .medium),
                    .foregroundColor: UIColor(Color.gray0)
                ]
                
                UINavigationBar.appearance().standardAppearance = appearance
                UINavigationBar.appearance().scrollEdgeAppearance = appearance
            }
    }
}
