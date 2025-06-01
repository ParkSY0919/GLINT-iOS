//
//  View+.swift
//  GLINT-iOS
//
//  Created by 박신영 on 5/30/25.
//

import SwiftUI

import NukeUI

extension View {
    @ViewBuilder
    func `if`<Content: View>(
        _ condition: Bool,
        transform: (Self) -> Content
    ) -> some View {
        if condition {
            transform(self)
        } else {
            self
        }
    }
    
    @ViewBuilder
    func ifLet<Content: View, T>(
        _ value: T?,
        transform: (Self, T) -> Content
    ) -> some View {
        if let value {
            transform(self, value)
        } else {
            self
        }
    }
    
    func clipRectangle(_ radius: CGFloat) -> some View {
        self.clipShape(RoundedRectangle(
            cornerRadius: radius,
            style: .continuous
        ))
    }
    
    func roundedRectangleStroke(
        radius: CGFloat,
        color: Color,
        lineWidth: CGFloat = 1
    ) -> some View {
        self.overlay {
            RoundedRectangle(cornerRadius: radius, style: .continuous)
                .stroke(color, lineWidth: lineWidth)
        }
    }
    
    @ViewBuilder
    func lazyImageTransform(
        _ state: LazyImageState,
        @ViewBuilder transform: (Image) -> some View
    ) -> some View {
        VStack {
            if state.isLoading {
                Color.secondary.opacity(0.5)
                    .overlay {
                        ProgressView()
                            .controlSize(.regular)
                            .tint(.brandBright)
                    }
            } else {
                switch state.result {
                case .success(let success):
                    transform(
                        Image(uiImage: success.image)
                            .resizable()
                    )
                case .failure(let failure):
                    Color.secondary.opacity(0.5)
                        .onAppear { print(failure) }
                case .none:
                    Color.secondary.opacity(0.5)
                }
            }
        }
        .animation(.smooth, value: state.isLoading)
    }
    
    @ViewBuilder
    func systemNavigationBarHidden(_ hidden: Bool = true) -> some View {
        if #available(iOS 18.0, *) {
            self.toolbarVisibility(hidden ? .hidden : .visible, for: .navigationBar)
        } else {
            self.navigationBarBackButtonHidden()
        }
    }
    
    func detectScroll() -> some View {
        modifier(ScrollDetector())
    }
    
    func detectListScroll() -> some View {
        modifier(ListScrollDetector())
    }
    
    func nonScrollable() -> some View {
        modifier(NonScrollableView())
    }
    
    func navigationBarTitleFont(_ font: PointFontName, size: CGFloat) -> some View {
        self.modifier(NavigationTitleFontModifier(fontName: font, fontSize: size))
    }
}

