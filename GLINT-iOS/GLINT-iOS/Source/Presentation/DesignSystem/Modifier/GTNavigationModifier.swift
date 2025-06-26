//
//  GTNavigationModifier.swift
//  GLINT-iOS
//
//  Created by 박신영 on 6/1/25.
//

import SwiftUI

struct GTNavigationSetupModifier: ViewModifier {
    let title: String
    let onBackButtonTapped: (() -> Void)?
    
    func body(content: Content) -> some View {
        content
            .navigationTitle(title)
            .navigationBarTitleDisplayMode(.inline)
            .navigationBarBackButtonHidden(true)
            .toolbar {
                if let backAction = onBackButtonTapped {
                    ToolbarItem(placement: .navigationBarLeading) {
                        Button(action: backAction) {
                            Image(systemName: "arrow.left")
                                .frame(width: 32, height: 32)
                                .font(.system(size: 16, weight: .medium))
                                .foregroundColor(.gray75)
                        }
                    }
                }
            }
    }
}

extension View {
    func navigationSetup(
        title: String,
        onBackButtonTapped: (() -> Void)? = nil
    ) -> some View {
        self.modifier(
            GTNavigationSetupModifier(
                title: title,
                onBackButtonTapped: onBackButtonTapped
            )
        )
    }
}
