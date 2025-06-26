//
//  GTProfileInfoView.swift
//  GLINT-iOS
//
//  Created by 박신영 on 6/26/25.
//

import SwiftUI

struct GTProfileInfoView: View {
    let introduction: String?
    let description: String?
    
    private var displayIntroduction: String {
        introduction ?? "내용 없음"
    }
    
    private var displayDescription: String {
        description ?? "내용 없음"
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(displayIntroduction)
                .font(.pointFont(.body, size: 14))
                .foregroundColor(.gray60)
            
            Text(displayDescription)
                .font(.pretendardFont(.caption, size: 12))
                .foregroundColor(.gray60)
        }
    }
}
