//
//  LoginView.swift
//  GLINT-iOS
//
//  Created by 박신영 on 5/12/25.
//

import SwiftUI
import AuthenticationServices


struct LoginView: View {
    var body: some View {
        Text("LoginView")
        
        Button("kakaoLogin") {
            print("kakao")
        }
        
        Button("appleLogin") {
            print("apple")
            checkAppleLogin()
        }
    }
    
    func checkAppleLogin() {
        
    }
}




#Preview {
    LoginView()
}
