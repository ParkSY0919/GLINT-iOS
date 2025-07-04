//
//  ScreenStyleModifier.swift
//  GLINT-iOS
//
//  Created by 박신영 on 7/3/25.
//

import SwiftUI

struct ScreenStyleModifier: ViewModifier {
    let backgroundColor: Color
    let ignoresSafeArea: Bool
    let safeAreaEdges: Edge.Set
    let isLoading: Bool
    let errorMessage: String?
    let animationDuration: Double
    let feedbackType: SensoryFeedback
    
    init(
        backgroundColor: Color = .gray100,
        ignoresSafeArea: Bool = true,
        safeAreaEdges: Edge.Set = .top,
        isLoading: Bool = false,
        errorMessage: String? = nil,
        animationDuration: Double = 0.3,
        feedbackType: SensoryFeedback = .impact(weight: .light)
    ) {
        self.backgroundColor = backgroundColor
        self.ignoresSafeArea = ignoresSafeArea
        self.safeAreaEdges = safeAreaEdges
        self.isLoading = isLoading
        self.errorMessage = errorMessage
        self.animationDuration = animationDuration
        self.feedbackType = feedbackType
    }
    
    func body(content: Content) -> some View {
        content
            .ignoresSafeArea(ignoresSafeArea ? .all : [], edges: safeAreaEdges)
            .background(backgroundColor)
            .animation(.easeInOut(duration: animationDuration), value: isLoading)
            .sensoryFeedback(feedbackType, trigger: errorMessage)
    }
}
