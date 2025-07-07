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
                return Strings.Login.emailLabel
            case .password:
                return Strings.Login.passwordLabel
            }
        }
        
        var placeholder : String {
            switch self {
            case .email:
                return Strings.Login.emailPlaceholder
            case .password:
                return Strings.Login.passwordPlaceholder
            }
        }
    }
    
    let formCase: FormFieldCase
    var errorMessage: String? = nil
    @Binding var text: String
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            formLabelSection
            formFieldSection($text)
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
    
    func formFieldSection(_ text: Binding<String>) -> some View {
        Group {
            switch formCase {
            case .email:
                TextField(formCase.placeholder, text: text)
                    .keyboardType(.emailAddress)
            case .password:
                SecureField(formCase.placeholder, text: text)
                    .textContentType(.none)
            }
        }
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
    
    func textFieldStyle() -> some View {
        self
            .padding()
            .background(.gray60)
            .cornerRadius(8)
            .font(.textFieldFont)
    }
}
