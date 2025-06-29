//
//  FormFieldView.swift
//  GLINT-iOS
//
//  Created by 박신영 on 5/12/25.
//

import SwiftUI

struct FormFieldView: View {
    enum FormFieldCase {
        case email
        case password
        
        var label : String {
            switch self {
            case .email:
                return "Email"
            case .password:
                return "Password"
            }
        }
        
        var placeholder : String {
            switch self {
            case .email:
                return "Enter your email"
            case .password:
                return "Enter your password"
            }
        }
    }
    
    let formCase: FormFieldCase
    var isSecure: Bool = false
    var errorMessage: String? = nil
    @Binding var text: String
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            formLabelSection
            formFieldSection(SecureField(formCase.placeholder, text: $text), isSecure: self.isSecure)
            HStack {
                Spacer()
                if let errorMessage = errorMessage, !text.isEmpty {
                    errorMessageSection(error: errorMessage)
                }
            }
        }
    }
}

private extension FormFieldView {
    var formLabelSection: some View {
        Text(formCase.label)
            .font(.fieldLabel)
            .foregroundColor(.gray0)
    }
    
    @ViewBuilder
    func formFieldSection<Content: View>(_ content: Content, isSecure: Bool) -> some View {
        content
            .padding()
            .background(.gray60)
            .cornerRadius(8)
            .font(.textFieldFont)
    }
    
    func errorMessageSection(error: String) -> some View {
        Text(error)
            .font(.system(size: 12))
            .foregroundColor(.red)
            .padding(.bottom, -50)
            .padding(.trailing, 4)
    }
}
