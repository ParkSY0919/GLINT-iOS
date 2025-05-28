//
//  CustomTabBarView.swift
//  GLINT-iOS
//
//  Created by 박신영 on 5/12/25.
//

import SwiftUI

struct TabItemPreferenceKey: PreferenceKey {
    typealias Value = [Int: CGRect]

    static var defaultValue: Value = [:] // 기본값은 빈 딕셔셔리

    // 여러 자식 뷰에서 올라온 값들을 병합하는 방법 정의
    static func reduce(value: inout Value, nextValue: () -> Value) {
        value.merge(nextValue()) { $1 } // 중복 키 발생 시 nextValue 사용 (또는 다른 병합 로직)
    }
}

struct CustomTabBar: View {
    @Binding var selectedTab: Int
    let items: [TabBarItemModel]

    @State private var indicatorXOffset: CGFloat = 0
    @State private var tabItemFrames: [Int: CGRect] = [:]

    // --- 상수 정의 ---
    private let indicatorHeight: CGFloat = 3
    private let indicatorWidthRatio: CGFloat = 0.6
    private let tabBarHeight: CGFloat = 60 // 탭 바 내용물의 높이
    private let indicatorTopPadding: CGFloat = 4

    // --- 계산 프로퍼티 ---
    private var currentIndicatorWidth: CGFloat {
        guard let selectedFrame = tabItemFrames[selectedTab], selectedFrame.width > 0 else {
            return 30
        }
        let iconWidthEstimate = selectedFrame.width * 0.5
        return iconWidthEstimate * indicatorWidthRatio
    }

    var body: some View {
        GeometryReader { geometry in
            ZStack(alignment: .topLeading) {
                // 1. 탭 바 배경
                RoundedRectangle(cornerRadius: 25)
                    .fill(Color(UIColor.systemGray4))
                    .frame(height: tabBarHeight)
                    .shadow(color: .black.opacity(0.1), radius: 3, x: 0, y: -2)

                // 2. 탭 아이템들
                HStack(spacing: 0) {
                    ForEach(items) { item in
                        Spacer()
                        tabBarButton(for: item)
                        Spacer()
                    }
                }
                .frame(height: tabBarHeight)
                .coordinateSpace(name: "TabBarHStack")

                // 3. 인디케이터
                RoundedRectangle(cornerRadius: indicatorHeight / 2)
                    .fill(Color.white)
                    .frame(width: currentIndicatorWidth, height: indicatorHeight)
                    .offset(x: indicatorXOffset, y: indicatorTopPadding)
                    .animation(.spring(response: 0.3, dampingFraction: 0.7), value: selectedTab)
            }
            .frame(height: tabBarHeight)
            .padding(.horizontal)
            .padding(.bottom, geometry.safeAreaInsets.bottom > 0 ? geometry.safeAreaInsets.bottom : 10)
        }
        .frame(height: tabBarHeight + (UIApplication.shared.windows.first?.safeAreaInsets.bottom ?? 0 > 0 ? (UIApplication.shared.windows.first?.safeAreaInsets.bottom ?? 0) : 10)) // GeometryReader의 전체 높이
        .onPreferenceChange(TabItemPreferenceKey.self) { frames in
            self.tabItemFrames = frames
            self.updateIndicatorPosition(animated: false)
        }
        .onChange(of: selectedTab) { newTab in
            updateIndicatorPosition()
        }
    }

    @ViewBuilder
    private func tabBarButton(for item: TabBarItemModel) -> some View {
        Button {
            selectedTab = item.tag
        } label: {
            VStack(spacing: 4) {
                (selectedTab == item.tag ? item.selectedIcon : item.icon)
                    .font(.system(size: 22))
                    .foregroundColor(selectedTab == item.tag ? .accentColor : .gray)
            }
            .frame(maxWidth: .infinity)
            .frame(height: tabBarHeight - indicatorHeight - indicatorTopPadding * 2)
            .padding(.top, indicatorHeight + indicatorTopPadding)
            .background(
                GeometryReader { geo in
                    Color.clear
                        .preference(key: TabItemPreferenceKey.self,
                                    value: [item.tag: geo.frame(in: .named("TabBarHStack"))])
                }
            )
        }
        .buttonStyle(.plain)
    }

    private func updateIndicatorPosition(animated: Bool = true) {
        // ... (기존 updateIndicatorPosition 코드와 동일) ...
        guard let selectedItemFrame = tabItemFrames[selectedTab] else {
            print("Warning: Frame for selectedTab \(selectedTab) not found.")
            return
        }

        let indicatorWidth = currentIndicatorWidth
        let newXOffset = selectedItemFrame.midX - (indicatorWidth / 2)

        if animated {
            withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                indicatorXOffset = newXOffset
            }
        } else {
            indicatorXOffset = newXOffset
        }
    }
}

