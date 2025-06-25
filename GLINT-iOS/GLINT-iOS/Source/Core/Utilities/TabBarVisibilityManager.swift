//
//  TabBarVisibilityManager.swift
//  GLINT-iOS
//
//  Created by 박신영 on 6/1/25.
//

import Foundation

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

