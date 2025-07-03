//
//  ConditionalAlertModifier.swift
//  GLINT-iOS
//
//  Created by 박신영 on 7/3/25.
//

import SwiftUI

struct ConditionalAlertModifier<MessageContent: View>: ViewModifier {
    let title: String
    let buttonTitle: String
    @Binding var isPresented: Bool
    let messageContent: () -> MessageContent
    let onConfirm: (() -> Void)?
    
    func body(content: Content) -> some View {
        content
            .alert(title, isPresented: $isPresented) {
                Button(buttonTitle) {
                    onConfirm?()
                    isPresented = false
                }
            } message: {
                messageContent()
            }
    }
}
