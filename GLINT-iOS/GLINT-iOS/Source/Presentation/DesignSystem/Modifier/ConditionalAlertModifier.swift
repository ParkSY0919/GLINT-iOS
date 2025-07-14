//
//  ConditionalAlertModifier.swift
//  GLINT-iOS
//
//  Created by 박신영 on 7/3/25.
//

import SwiftUI

struct ConditionalAlertModifier<Buttons: View, Message: View>: ViewModifier {
    let title: String
    @Binding var isPresented: Bool
    @ViewBuilder let buttons: () -> Buttons
    @ViewBuilder let message: () -> Message
    
    func body(content: Content) -> some View {
        content
            .alert(title, isPresented: $isPresented, actions: buttons, message: message)
    }
}

extension View {
    // MARK: - Single Button Alert
    func conditionalAlert(
        title: String,
        buttonTitle: String = "확인",
        isPresented: Binding<Bool>,
        onConfirm: @escaping () -> Void = {},
        @ViewBuilder message: @escaping () -> some View
    ) -> some View {
        modifier(ConditionalAlertModifier(
            title: title,
            isPresented: isPresented,
            buttons: {
                Button(buttonTitle) {
                    onConfirm()
                }
            },
            message: message
        ))
    }
    
    func conditionalAlert<Buttons: View, Message: View>(
        title: String,
        isPresented: Binding<Bool>,
        @ViewBuilder buttons: @escaping () -> Buttons,
        @ViewBuilder message: @escaping () -> Message
    ) -> some View {
        modifier(ConditionalAlertModifier(
            title: title,
            isPresented: isPresented,
            buttons: buttons,
            message: message
        ))
    }
}
