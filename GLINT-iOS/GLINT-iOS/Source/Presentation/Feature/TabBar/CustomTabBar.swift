//
//  CustomTabBarView.swift
//  GLINT-iOS
//
//  Created by 박신영 on 5/12/25.
//

import SwiftUI

//TODO: Geometry Effect 사용한 탭바로 수정하기
struct CustomTabBar: View {
    @Binding var selectedTab: Int
    let items: [TabBarItemModel]
    
    @State private var indicatorXOffset: CGFloat = 0
    @State private var tabItemFrames: [Int: CGRect] = [:]
    
    private let indicatorHeight: CGFloat = 3
    private let indicatorWidthRatio: CGFloat = 0.6
    private let tabBarHeight: CGFloat = 60 // 탭 바 내용물의 높이
    private let indicatorTopPadding: CGFloat = 4
    
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
                RoundedRectangle(cornerRadius: 34)
                    .fill(Color.gray75.opacity(0.5))
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
        .frame(height: tabBarHeight + 20)
        .onPreferenceChange(TabItemPreferenceKey.self) { frames in
            self.tabItemFrames = frames
            self.updateIndicatorPosition(animated: false)
        }
        .onChange(of: selectedTab) {
            updateIndicatorPosition()
        }
    }
    
    private func tabBarButton(for item: TabBarItemModel) -> some View {
        Button {
            selectedTab = item.tag
        } label: {
            VStack(spacing: 4) {
                (selectedTab == item.tag ? item.selectedIcon : item.icon)
                    .font(.system(size: 22))
                    .foregroundColor(selectedTab == item.tag ? .gray15 : .gray45)
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

struct TabItemPreferenceKey: PreferenceKey {
    typealias Value = [Int: CGRect]
    
    static var defaultValue: Value = [:] // 기본값은 빈 딕셔셔리
    
    // 여러 자식 뷰에서 올라온 값들을 병합하는 방법 정의
    static func reduce(value: inout Value, nextValue: () -> Value) {
        value.merge(nextValue()) { $1 } // 중복 키 발생 시 nextValue 사용 (또는 다른 병합 로직)
    }
}


@Observable
final class TabBarVisibilityManager {
    var isVisible = true
    var isScrollableView = true
    private var hideTimer: Timer?
    
    func showTabBar() {
        isVisible = true
        
        // 스크롤 가능한 뷰에서만 타이머 설정
        if isScrollableView {
            // 기존 타이머 취소
            hideTimer?.invalidate()
            
            // 2초 후 숨기기
            hideTimer = Timer.scheduledTimer(withTimeInterval: 2.0, repeats: false) { _ in
                self.isVisible = false
            }
        }
    }
    
    func setScrollable(_ scrollable: Bool) {
        isScrollableView = scrollable
        if !scrollable {
            // 스크롤 불가능한 뷰에서는 항상 표시
            hideTimer?.invalidate()
            isVisible = true
        } else {
            // 스크롤 가능한 뷰로 전환 시 타이머 시작
            showTabBar()
        }
    }
}

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

extension View {
    func detectScroll() -> some View {
        modifier(ScrollDetector())
    }
    
    func detectListScroll() -> some View {
        modifier(ListScrollDetector())
    }
    
    func nonScrollable() -> some View {
        modifier(NonScrollableView())
    }
}
