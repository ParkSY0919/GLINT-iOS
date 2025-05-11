//
//  CustomTabBarView.swift
//  GLINT-iOS
//
//  Created by 박신영 on 5/12/25.
//

import SwiftUI

struct CustomTabBar: View {
    @Binding var selectedTab: Int
    let items: [TabBarItemModel]

    @State private var indicatorXOffset: CGFloat = 0
    @State private var tabItemFrames: [CGRect] = Array(repeating: .zero, count: TabBarItems.items.count)

    private let indicatorHeight: CGFloat = 3
    private let indicatorWidthRatio: CGFloat = 0.6 // 아이콘 너비 대비 인디케이터 너비 비율
    private let tabBarHeight: CGFloat = 60 // 탭 바 전체 높이
    private let indicatorTopPadding: CGFloat = 4 // 탭 바 상단과 인디케이터 사이 여백

    var body: some View {
        ZStack(alignment: .topLeading) { // 인디케이터를 내부 상단에 배치
            // 1. 탭 바 배경 (ZStack의 가장 아래에 위치)
            RoundedRectangle(cornerRadius: 25)
                .fill(Color(UIColor.systemGray4)) // 배경색
                .frame(height: tabBarHeight)
                .shadow(color: .black.opacity(0.1), radius: 3, x: 0, y: -2)

            // 2. 탭 아이템들 (배경 위에 배치)
            HStack(spacing: 0) {
                ForEach(items) { item in
                    Spacer()
                    Button {
                        withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                            selectedTab = item.tag
                        }
                    } label: {
                        VStack(spacing: 4) {
                                // 삼항 연산자로 Image 뷰 직접 반환
                                (selectedTab == item.tag ? item.selectedIcon : item.icon)
                                    .font(.system(size: 22))
                                    .foregroundColor(selectedTab == item.tag ? .accentColor : .gray)
                            }
                            .frame(maxWidth: .infinity)
                            .frame(height: tabBarHeight - indicatorHeight - indicatorTopPadding * 2)
                            .padding(.top, indicatorHeight + indicatorTopPadding)
                            // --- GeometryReader 수정 ---
                            .background(
                                GeometryReader { geo -> Color in // 명시적으로 Color 반환 타입 지정
                                    // DispatchQueue 작업은 뷰 반환과 별개로 처리
                                    DispatchQueue.main.async {
                                        if item.tag < self.tabItemFrames.count {
                                            self.tabItemFrames[item.tag] = geo.frame(in: .named("TabBarHStack"))
                                            if item.tag == selectedTab && self.indicatorXOffset == 0 {
                                                self.updateIndicatorPosition(animated: false)
                                            }
                                        }
                                    }
                                    return Color.clear // GeometryReader는 항상 Color.clear를 반환
                                }
                            )
                    }
                    .buttonStyle(.plain)
                    Spacer()
                }
            }
            .frame(height: tabBarHeight) // HStack 높이도 탭 바 배경과 동일하게
            .coordinateSpace(name: "TabBarHStack") // HStack에 좌표 공간 이름 부여

            // 3. 인디케이터 (탭 아이템들 위에, 배경 안쪽에 배치)
            RoundedRectangle(cornerRadius: indicatorHeight / 2)
                .fill(Color.white)
                .frame(width: calculateIndicatorWidth(), height: indicatorHeight)
                .offset(x: indicatorXOffset, y: indicatorTopPadding) // --- offset 변경 ---
                .animation(.spring(response: 0.3, dampingFraction: 0.7), value: selectedTab)

        }
        .frame(height: tabBarHeight) // ZStack 전체 높이 고정
        .padding(.horizontal)
        .padding(.bottom, UIApplication.shared.windows.first?.safeAreaInsets.bottom == 0 ? 10 : 0)
        .onChange(of: selectedTab) { _ in
            updateIndicatorPosition()
        }
        .onAppear {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                updateIndicatorPosition(animated: false)
            }
        }
    }

    private func calculateIndicatorWidth() -> CGFloat {
        guard selectedTab < tabItemFrames.count, tabItemFrames[selectedTab].width > 0 else {
            return 30
        }
        let iconWidthEstimate = tabItemFrames[selectedTab].width * 0.5
        return iconWidthEstimate * indicatorWidthRatio
    }

    private func updateIndicatorPosition(animated: Bool = true) {
        guard selectedTab < tabItemFrames.count else { return }
        // --- 중요: tabItemFrames는 이제 HStack 기준이므로, selectedFrame.midX를 바로 사용 ---
        let selectedItemFrame = tabItemFrames[selectedTab]
        let indicatorWidth = calculateIndicatorWidth()

        // 선택된 아이템의 중앙 X 좌표 - (인디케이터 너비 / 2)
        // selectedItemFrame.origin.x는 HStack 내에서의 x 시작점
        let newXOffset = selectedItemFrame.midX - (indicatorWidth / 2)

        print("Updating indicator to X: \(newXOffset) for tab \(selectedTab)")

        if animated {
            withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                indicatorXOffset = newXOffset
            }
        } else {
            indicatorXOffset = newXOffset
        }
    }
}

