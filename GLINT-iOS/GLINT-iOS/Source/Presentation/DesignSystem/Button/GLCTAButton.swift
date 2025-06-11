//
//  PrimaryButtonStyle.swift
//  GLINT-iOS
//
//  Created by 박신영 on 5/12/25.
//

import SwiftUI

struct GLCTAButton: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.buttonFont)
            .padding()
            .frame(maxWidth: .infinity)
            .background(.brandBright)
            .foregroundColor(.gray0)
            .cornerRadius(8)
            .opacity(configuration.isPressed ? 0.8 : 1.0)
    }
}
