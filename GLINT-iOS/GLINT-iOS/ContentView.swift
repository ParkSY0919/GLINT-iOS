//
//  ContentView.swift
//  GLINT-iOS
//
//  Created by 박신영 on 5/9/25.
//

import SwiftUI

struct ContentView: View {
    var body: some View {
        VStack {
            Image(systemName: "globe")
                .imageScale(.large)
                .foregroundStyle(.tint)
            Text("Hello, world! - Title")
                .font(.pointFont(.title_32))
            Text("Hello, world! - Body")
                .font(.pointFont(.body_20))
            Text("Hello, world! - Caption")
                .font(.pointFont(.caption_14))
            Button("Tap me") {
                // Config가 정의되지 않음. 임시 주석 처리
                // print(Config.baseURL)
                print("Button tapped")
            }
        }
        .padding()
        .onAppear {
            // 폰트 로드 확인 (디버깅용)
            print("Available font families: \(UIFont.familyNames)")
            let fontNames = UIFont.fontNames(forFamilyName: "Pretendard")
                print("Available fonts: \(fontNames)")
            
            
            
        }
    }
}
#Preview {
    ContentView()
}
