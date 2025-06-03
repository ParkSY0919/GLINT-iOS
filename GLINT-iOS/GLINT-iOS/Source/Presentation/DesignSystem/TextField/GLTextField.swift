//
//  GLTextField.swift
//  GLINT-iOS
//
//  Created by AI Assistant on 1/19/25.
//

import SwiftUI

enum GLTextFieldType {
    case filterName
    case introduce
    case price
    
    var placeholder: String {
        switch self {
        case .filterName:
            return "필터 이름을 입력해주세요."
        case .introduce:
            return "이 필터에 대해 간단하게 소개해주세요."
        case .price:
            return "해당 필터가 판매될 가격을 입력해주세요."
        }
    }
    
    var title: String {
        switch self {
        case .filterName:
            return "필터명"
        case .introduce:
            return "필터 소개"
        case .price:
            return "판매 가격"
        }
    }
    
    var lineLimit: Int? {
        switch self {
        case .filterName:
            return 1
        case .introduce:
            return nil
        case .price:
            return 1
        }
    }
    
    var keyboardType: UIKeyboardType {
        switch self {
        case .filterName, .introduce:
            return .default
        case .price:
            return .numberPad
        }
    }
    
    var needsDoneButton: Bool {
        switch self {
        case .filterName:
            return false
        case .introduce, .price:
            return true
        }
    }
}

struct GLTextField: View {
    let type: GLTextFieldType
    @Binding var text: String
    @FocusState private var isFocused: Bool
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(type.title)
                .font(.pretendardFont(.body_bold, size: 16))
                .foregroundColor(.gray60)
            
            ZStack(alignment: .topLeading) {
                // 배경 및 테두리
                RoundedRectangle(cornerRadius: 12)
                    .stroke(.brandDeep, lineWidth: 2)
                    .background(
                        RoundedRectangle(cornerRadius: 12)
                            .fill(.clear)
                    )
                    .frame(minHeight: type == .introduce ? 100 : 56)
                
                // TextField 영역
                HStack {
                    if type == .introduce {
                        // 여러줄 텍스트
                        TextField(type.placeholder, text: $text, axis: .vertical)
                            .font(.pretendardFont(.body_medium, size: 14))
                            .foregroundColor(.gray0)
                            .lineLimit(type.lineLimit)
                            .keyboardType(type.keyboardType)
                            .focused($isFocused)
                    } else if type == .price {
                        // 가격 입력 (실시간 포맷팅)
                        TextField(type.placeholder, text: formattedPriceBinding)
                            .font(.pretendardFont(.body_medium, size: 14))
                            .foregroundColor(.gray0)
                            .lineLimit(type.lineLimit)
                            .keyboardType(type.keyboardType)
                            .focused($isFocused)
                    } else {
                        // 한줄 텍스트
                        TextField(type.placeholder, text: $text)
                            .font(.pretendardFont(.body_medium, size: 14))
                            .foregroundColor(.gray0)
                            .lineLimit(type.lineLimit)
                            .keyboardType(type.keyboardType)
                            .focused($isFocused)
                    }
                    
                    // 가격 입력시 원 표시
                    if type == .price {
                        Text("원")
                            .font(.pretendardFont(.body_bold, size: 14))
                            .foregroundColor(.gray75)
                    }
                }
                .padding(.horizontal, 16)
                .padding(.vertical, type == .introduce ? 16 : 18)
            }
        }
        .padding(.top, 26)
        .background(.clear)
        .contentShape(Rectangle())
        .onTapGesture {
            // 텍스트필드가 포커스되지 않은 상태에서 탭하면 키보드 내리기
            if isFocused {
                hideKeyboard()
            }
        }
        .toolbar {
            if isFocused && type.needsDoneButton {
                ToolbarItem(placement: .keyboard) {
                    HStack {
                        Spacer()
                        Button("완료") {
                            isFocused = false
                        }
                        .font(.pretendardFont(.body_medium, size: 16))
                        .foregroundColor(.brandDeep)
                    }
                }
            }
        }
    }
    
    private var formattedPriceBinding: Binding<String> {
        Binding(
            get: {
                if !text.isEmpty {
                    // 숫자만 추출
                    let numbers = text.components(separatedBy: CharacterSet.decimalDigits.inverted).joined()
                    if let number = Int(numbers) {
                        return number.formatted()
                    }
                }
                return text
            },
            set: { newValue in
                // 숫자만 추출해서 저장
                let numbers = newValue.components(separatedBy: CharacterSet.decimalDigits.inverted).joined()
                text = numbers
            }
        )
    }
    
    private func hideKeyboard() {
        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
    }
} 
