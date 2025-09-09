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
        
        var icon: String {
            switch self {
            case .email:
                return "envelope.fill"
            case .password:
                return "lock.fill"
            }
        }
    }
    
    let formCase: FormFieldCase
    var errorMessage: String? = nil
    @Binding var text: String
    @FocusState private var isFocused: Bool
    @State private var isVisible: Bool = false
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            formLabelSection
            formFieldSection($text)
            if let errorMessage = errorMessage, !text.isEmpty {
                errorMessageSection(error: errorMessage)
            }
        }
        .onAppear {
            withAnimation(.spring(response: 0.6, dampingFraction: 0.8, blendDuration: 0)) {
                isVisible = true
            }
        }
    }
}

private extension FormFieldView {
    var formLabelSection: some View {
        HStack(spacing: 8) {
            Image(systemName: formCase.icon)
                .font(.system(size: 14, weight: .medium))
                .foregroundColor(.pinterestRed)
            
            Text(formCase.label)
                .font(.pretendardFont(.body_medium, size: 15))
                .foregroundColor(.pinterestTextPrimary)
        }
        .opacity(isVisible ? 1 : 0)
        .animation(.spring(response: 0.6, dampingFraction: 0.8).delay(0.1), value: isVisible)
    }
    
    func formFieldSection(_ text: Binding<String>) -> some View {
        ZStack {
            // Glassmorphism background with dynamic stroke
            RoundedRectangle(cornerRadius: 16)
                .fill(
                    LinearGradient(
                        colors: [.glassLight, .glassDark],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .overlay(
                    RoundedRectangle(cornerRadius: 16)
                        .stroke(
                            isFocused ? 
                            LinearGradient(
                                colors: [.pinterestRed, .gradientMid],
                                startPoint: .leading,
                                endPoint: .trailing
                            ) : 
                            LinearGradient(
                                colors: [.glassStroke, .glassStroke],
                                startPoint: .leading,
                                endPoint: .trailing
                            ),
                            lineWidth: isFocused ? 2 : 1
                        )
                        .animation(.spring(response: 0.3, dampingFraction: 0.7), value: isFocused)
                )
                .shadow(color: .black.opacity(0.1), radius: 8, x: 0, y: 4)
            
            // Input field
            HStack(spacing: 16) {
                Image(systemName: formCase.icon)
                    .font(.system(size: 16, weight: .medium))
                    .foregroundColor(isFocused ? .pinterestRed : .pinterestTextTertiary)
                    .animation(.spring(response: 0.3, dampingFraction: 0.7), value: isFocused)
                
                Group {
                    switch formCase {
                    case .email:
                        TextField("", text: text, prompt: Text(formCase.placeholder).foregroundColor(.pinterestTextTertiary))
                            .keyboardType(.emailAddress)
                            .focused($isFocused)
                    case .password:
                        SecureField("", text: text, prompt: Text(formCase.placeholder).foregroundColor(.pinterestTextTertiary))
                            .textContentType(.none)
                            .focused($isFocused)
                    }
                }
                .font(.pretendardFont(.body_medium, size: 16))
                .foregroundColor(.pinterestTextPrimary)
            }
            .padding(.horizontal, 20)
            .padding(.vertical, 18)
        }
        .frame(height: 56)
        .opacity(isVisible ? 1 : 0)
        .scaleEffect(isVisible ? 1 : 0.95)
        .animation(.spring(response: 0.6, dampingFraction: 0.8).delay(0.2), value: isVisible)
        .onTapGesture {
            isFocused = true
        }
    }
    
    func errorMessageSection(error: String) -> some View {
        HStack(spacing: 8) {
            Image(systemName: "exclamationmark.triangle.fill")
                .font(.system(size: 12, weight: .medium))
                .foregroundColor(.pinterestError)
            
            Text(error)
                .font(.pretendardFont(.caption, size: 12))
                .foregroundColor(.pinterestError)
            
            Spacer()
        }
        .padding(.horizontal, 4)
        .opacity(isVisible ? 1 : 0)
        .animation(.spring(response: 0.6, dampingFraction: 0.8).delay(0.3), value: isVisible)
    }
    
    func textFieldStyle() -> some View {
        self
            .padding()
            .background(.gray60)
            .cornerRadius(8)
            .font(.textFieldFont)
    }
}
