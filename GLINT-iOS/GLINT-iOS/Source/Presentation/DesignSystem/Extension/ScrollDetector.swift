//
//  ScrollDetector.swift
//  GLINT-iOS
//
//  Created by 박신영 on 6/1/25.
//

import SwiftUI

struct ScrollDetector: ViewModifier {
    @Environment(TabBarVisibilityManager.self) private var tabBarVisibility
    
    func body(content: Content) -> some View {
        content
            .onAppear {
                tabBarVisibility.setScrollable(true)
            }
            .simultaneousGesture(
                DragGesture()
                    .onChanged { _ in
                        tabBarVisibility.showTabBar()
                    }
            )
    }
}

struct ListScrollDetector: ViewModifier {
    @Environment(TabBarVisibilityManager.self) private var tabBarVisibility
    @State private var previousOffset: CGFloat = 0
    
    func body(content: Content) -> some View {
        ScrollViewReader { proxy in
            content
                .onAppear {
                    tabBarVisibility.setScrollable(true)
                }
                .background(
                    GeometryReader { geometry in
                        Color.clear
                            .onChange(of: geometry.frame(in: .global).minY) { oldValue, newValue in
                                if abs(newValue - previousOffset) > 1 {
                                    tabBarVisibility.showTabBar()
                                    previousOffset = newValue
                                }
                            }
                    }
                )
        }
    }
}

struct NonScrollableView: ViewModifier {
    @Environment(TabBarVisibilityManager.self) private var tabBarVisibility
    
    func body(content: Content) -> some View {
        content
            .onAppear {
                tabBarVisibility.setScrollable(false)
            }
    }
}

