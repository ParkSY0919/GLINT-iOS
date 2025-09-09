//
//  PrimaryButtonStyle.swift
//  GLINT-iOS
//
//  Created by 박신영 on 5/12/25.
//

import SwiftUI

struct GLCTAButton: ButtonStyle {
    let gradient: LinearGradient
    let shadowColor: Color
    
    init(
        gradient: LinearGradient = LinearGradient(
            colors: [.gradientStart, .gradientMid],
            startPoint: .leading,
            endPoint: .trailing
        ),
        shadowColor: Color = .pinterestRed
    ) {
        self.gradient = gradient
        self.shadowColor = shadowColor
    }
    
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.pretendardFont(.body_bold, size: 18))
            .foregroundColor(.white)
            .frame(maxWidth: .infinity)
            .frame(height: 56)
            .background(
                ZStack {
                    // Main gradient
                    gradient
                    
                    // Glassmorphism overlay
                    LinearGradient(
                        colors: [.glassLight, .clear],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                }
            )
            .clipShape(RoundedRectangle(cornerRadius: 16))
            .shadow(color: shadowColor.opacity(0.4), radius: 12, x: 0, y: 6)
            .shadow(color: .black.opacity(0.1), radius: 4, x: 0, y: 2)
            .scaleEffect(configuration.isPressed ? 0.96 : 1.0)
            .animation(.spring(response: 0.3, dampingFraction: 0.7), value: configuration.isPressed)
    }
}
