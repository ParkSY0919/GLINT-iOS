//
//  StateViewBuilder.swift
//  GLINT-iOS
//
//  Created by 박신영 on 6/1/25.
//

import SwiftUI

struct StateViewBuilder {
    
    // MARK: - LoadingState Handler (새로 추가)
    
    /// LoadingState에 따라 적절한 뷰를 반환
    /// - Parameters:
    ///   - state: LoadingState
    ///   - content: 로드된 데이터를 표시할 뷰
    ///   - loadingMessage: 로딩 메시지 (옵션)
    ///   - emptyMessage: 빈 상태 메시지 (옵션)
    ///   - retryAction: 에러 시 재시도 액션
    @ViewBuilder
    static func buildView<T, Content: View>(
        for state: LoadingState<T>,
        @ViewBuilder content: @escaping (T) -> Content,
        loadingMessage: String = "데이터를 불러오는 중...",
        emptyMessage: String? = nil,
        retryAction: (() -> Void)? = nil
    ) -> some View {
        switch state {
        case .idle:
            if let emptyMessage = emptyMessage {
                emptyStateView(message: emptyMessage)
            } else {
                Color.clear
            }
            
        case .loading:
            loadingView(message: loadingMessage)
            
        case .loaded(let data):
            content(data)
            
        case .failed(let error):
            errorView(
                errorMessage: error.localizedDescription,
                retryAction: retryAction ?? {}
            )
        }
    }
    
    // MARK: - Loading View
    
    /// 로딩 상태를 표시하는 뷰
    /// - Parameters:
    ///   - message: 표시할 로딩 메시지 (기본값: "데이터를 불러오는 중...")
    ///   - backgroundColor: 배경 색상 (기본값: .gray100)
    ///   - progressColor: 프로그레스 인디케이터 색상 (기본값: .gray75)
    @ViewBuilder
    static func loadingView(
        message: String = "데이터를 불러오는 중...",
        backgroundColor: Color = .gray100,
        progressColor: Color = .gray75
    ) -> some View {
        ZStack {
            backgroundColor.ignoresSafeArea()
            
            VStack(spacing: 20) {
                ProgressView()
                    .progressViewStyle(CircularProgressViewStyle(tint: progressColor))
                    .scaleEffect(1.2)
                
                Text(message)
                    .font(.pretendardFont(.caption, size: 14))
                    .foregroundColor(.gray60)
            }
        }
        .transition(.opacity.combined(with: .scale(scale: 0.9)))
    }
    
    // MARK: - Error View
    
    /// 에러 상태를 표시하는 뷰
    /// - Parameters:
    ///   - errorMessage: 에러 메시지
    ///   - title: 에러 제목 (기본값: "오류가 발생했습니다")
    ///   - retryButtonTitle: 재시도 버튼 텍스트 (기본값: "다시 시도")
    ///   - backgroundColor: 배경 색상 (기본값: .gray100)
    ///   - retryAction: 재시도 버튼 클릭 시 실행될 액션
    @ViewBuilder
    static func errorView(
        errorMessage: String,
        title: String = "오류가 발생했습니다",
        retryButtonTitle: String = "다시 시도",
        backgroundColor: Color = .gray100,
        retryAction: @escaping () -> Void
    ) -> some View {
        VStack(spacing: 16) {
            Image(systemName: "exclamationmark.triangle")
                .font(.title)
                .foregroundColor(.red)
                .symbolEffect(.appear, options: .repeating)
            
            Text(title)
                .font(.pretendardFont(.title_bold, size: 18))
                .foregroundColor(.gray0)
            
            Text(errorMessage)
                .font(.pretendardFont(.body_bold, size: 14))
                .foregroundColor(.gray60)
                .multilineTextAlignment(.center)
            
            Button(retryButtonTitle) {
                retryAction()
            }
            .font(.pretendardFont(.caption_medium, size: 14))
            .padding(.horizontal, 24)
            .padding(.vertical, 12)
            .background(.gray75)
            .foregroundColor(.gray0)
            .clipShape(RoundedRectangle(cornerRadius: 8))
            .sensoryFeedback(.impact(weight: .medium), trigger: errorMessage)
        }
        .padding(.horizontal, 20)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(backgroundColor)
        .transition(.opacity.combined(with: .move(edge: .bottom)))
    }
    
    // MARK: - Empty State View
    
    /// 빈 상태를 표시하는 뷰 (추가 보너스)
    /// - Parameters:
    ///   - message: 표시할 메시지
    ///   - systemImageName: 시스템 이미지 이름 (기본값: "tray")
    ///   - backgroundColor: 배경 색상 (기본값: .gray100)
    @ViewBuilder
    static func emptyStateView(
        message: String,
        systemImageName: String = "tray",
        backgroundColor: Color = .gray100
    ) -> some View {
        VStack(spacing: 16) {
            Image(systemName: systemImageName)
                .font(.title)
                .foregroundColor(.gray60)
            
            Text(message)
                .font(.pretendardFont(.body_bold, size: 16))
                .foregroundColor(.gray60)
                .multilineTextAlignment(.center)
        }
        .padding(.horizontal, 20)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(backgroundColor)
        .transition(.opacity.combined(with: .scale(scale: 0.9)))
    }
    
    
    @ViewBuilder
    static func loadingIndicator() -> some View {
        HStack {
            Spacer()
            ProgressView()
                .scaleEffect(0.8)
                .padding()
            Spacer()
        }
    }
}

// MARK: - View Extension for Convenience

extension View {
    /// LoadingState에 따라 자동으로 뷰를 전환
    func loadingState<T>(
        _ state: LoadingState<T>,
        @ViewBuilder content: @escaping (T) -> some View,
        loadingMessage: String = "데이터를 불러오는 중...",
        emptyMessage: String? = nil,
        retryAction: (() -> Void)? = nil
    ) -> some View {
        StateViewBuilder.buildView(
            for: state,
            content: content,
            loadingMessage: loadingMessage,
            emptyMessage: emptyMessage,
            retryAction: retryAction
        )
    }
}
