//
//  AttendanceView.swift
//  GLINT-iOS
//
//  Created by Claude on 8/9/25.
//

import SwiftUI

struct AttendanceView: View {
    @State private var store = AttendanceViewStore()
    
    var body: some View {
        ZStack {
            // 메인 WebView
            AttendanceWebView(
                onMessageReceived: { message in
                    store.send(.messageReceived(message))
                },
                onWebViewLoadFailed: {
                    store.send(.webViewLoadFailed)
                },
                onCoordinatorReady: { coordinator in
                    store.send(.webViewLoaded(coordinator: coordinator))
                }
            )
            .ignoresSafeArea(.all, edges: .bottom)
            .onAppear {
                store.send(.viewWillAppear)
            }
            
            // 로딩 인디케이터
            if store.isLoading {
                Color.black.opacity(0.3)
                    .ignoresSafeArea()
                
                ProgressView()
                    .progressViewStyle(CircularProgressViewStyle(tint: .white))
                    .scaleEffect(1.2)
            }
        }
        .navigationTitle("출석체크")
        .navigationBarTitleDisplayMode(.inline)
        .alert("출석 완료", isPresented: $store.showCompletionAlert) {
            Button("확인") {
                store.send(.dismissCompletionAlert)
            }
        } message: {
            Text(store.completionMessage)
        }
        .alert("로그인 필요", isPresented: $store.showTokenRefreshAlert) {
            Button("확인") {
                store.send(.dismissTokenRefreshAlert)
            }
        } message: {
            Text(store.errorMessage ?? "로그인이 필요합니다.")
        }
        .alert("오류", isPresented: Binding<Bool>(
            get: { store.errorMessage != nil && !store.showTokenRefreshAlert },
            set: { _ in store.send(.dismissError) }
        )) {
            Button("확인") {
                store.send(.dismissError)
            }
            
            if store.showRetryButton {
                Button("다시 시도") {
                    store.send(.retryButtonTapped)
                }
            }
        } message: {
            Text(store.errorMessage ?? "오류가 발생했습니다.")
        }
    }
}
