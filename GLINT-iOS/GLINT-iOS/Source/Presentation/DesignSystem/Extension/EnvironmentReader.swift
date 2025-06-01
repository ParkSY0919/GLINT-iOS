//
//  EnvironmentReader.swift
//  GLINT-iOS
//
//  Created by 박신영 on 6/1/25.
//

import SwiftUI

struct EnvironmentReader<Content: View>: View {
    @Environment(\.self) private var environment
    let content: (EnvironmentValues) -> Content
    
    var body: some View {
        content(environment)
    }
}
