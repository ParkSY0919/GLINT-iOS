//
//  GTHashTagsView.swift
//  GLINT-iOS
//
//  Created by 박신영 on 6/26/25.
//

import SwiftUI

struct GTHashTagsView: View {
    let hashTags: [String]?
    
    var body: some View {
        HStack {
            ForEach(hashTags ?? [], id: \.self) { tag in
                Text(tag)
                    .font(.pointFont(.caption, size: 10))
                    .foregroundColor(.gray60)
                    .padding(.horizontal, 10)
                    .padding(.vertical, 5)
                    .background(.quaternary)
                    .clipShape(Capsule())
            }
        }
    }
}
