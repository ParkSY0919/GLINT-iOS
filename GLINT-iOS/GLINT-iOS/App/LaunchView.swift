//
//  LaunchView.swift
//  GLINT-iOS
//
//  Created by 박신영 on 7/25/25.
//

import SwiftUI

struct LaunchView: View {
    var body: some View {
        ZStack {
            Images.Launch.screen
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(.brandDeep)
    }
}

#Preview {
    LaunchView()
}
