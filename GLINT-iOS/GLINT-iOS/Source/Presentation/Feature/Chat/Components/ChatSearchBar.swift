//
//  ChatSearchBar.swift
//  GLINT-iOS
//
//  Created by Claude on 8/9/25.
//

import SwiftUI

struct ChatSearchBar: View {
    @Binding var searchText: String
    @Binding var isActive: Bool
    let onSearchCommitted: (String) -> Void
    let onCancel: () -> Void
    
    @FocusState private var isTextFieldFocused: Bool
    
    var body: some View {
        HStack(spacing: 12) {
            // 검색 입력 필드
            HStack(spacing: 8) {
                Image(systemName: "magnifyingglass")
                    .font(.system(size: 16, weight: .medium))
                    .foregroundColor(.glintTextSecondary)
                
                TextField("메시지 검색", text: $searchText)
                    .font(.system(size: 16, weight: .regular))
                    .focused($isTextFieldFocused)
                    .textInputAutocapitalization(.never)
                    .onSubmit {
                        onSearchCommitted(searchText)
                    }
                    .onChange(of: searchText) { _, newValue in
                        // 실시간 검색 (디바운싱 필요 시 추가 구현)
                        if newValue.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                            onSearchCommitted("")
                        }
                    }
                
                // 검색어 지우기 버튼
                if !searchText.isEmpty {
                    Button(action: {
                        searchText = ""
                        onSearchCommitted("")
                    }) {
                        Image(systemName: "xmark.circle.fill")
                            .font(.system(size: 16, weight: .medium))
                            .foregroundColor(.glintTextSecondary)
                    }
                }
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 8)
            .background(Color.glintCardBackground)
            .cornerRadius(20)
            
            // 취소 버튼
            Button("취소") {
                onCancel()
            }
            .font(.system(size: 16, weight: .medium))
            .foregroundColor(.glintPrimary)
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 8)
        .background(Color.glintBackground)
        .onAppear {
            isTextFieldFocused = true
        }
        .animation(.easeInOut(duration: 0.3), value: isActive)
    }
}

// MARK: - 검색 결과 네비게이션 바
struct ChatSearchNavigationBar: View {
    let currentIndex: Int
    let totalCount: Int
    let onPreviousPressed: () -> Void
    let onNextPressed: () -> Void
    let onClosePressed: () -> Void
    
    private var canNavigatePrevious: Bool {
        currentIndex > 0
    }
    
    private var canNavigateNext: Bool {
        currentIndex < totalCount - 1
    }
    
    var body: some View {
        HStack(spacing: 16) {
            // 검색 결과 카운터
            if totalCount > 0 {
                Text("\(currentIndex + 1) / \(totalCount)")
                    .font(.system(size: 16, weight: .medium))
                    .foregroundColor(.glintTextPrimary)
            } else {
                Text("결과 없음")
                    .font(.system(size: 16, weight: .medium))
                    .foregroundColor(.glintTextSecondary)
            }
            
            Spacer()
            
            // 네비게이션 버튼들
            HStack(spacing: 8) {
                // 이전 결과 버튼
                Button(action: onPreviousPressed) {
                    Image(systemName: "chevron.up")
                        .font(.system(size: 18, weight: .medium))
                        .foregroundColor(canNavigatePrevious ? .glintPrimary : .glintTextSecondary)
                }
                .disabled(!canNavigatePrevious)
                
                // 다음 결과 버튼
                Button(action: onNextPressed) {
                    Image(systemName: "chevron.down")
                        .font(.system(size: 18, weight: .medium))
                        .foregroundColor(canNavigateNext ? .glintPrimary : .glintTextSecondary)
                }
                .disabled(!canNavigateNext)
                
                // 검색 종료 버튼
                Button(action: onClosePressed) {
                    Image(systemName: "xmark")
                        .font(.system(size: 18, weight: .medium))
                        .foregroundColor(.glintTextSecondary)
                }
            }
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
        .background(Color.glintBackground)
        .overlay(
            Rectangle()
                .frame(height: 0.5)
                .foregroundColor(Color.glintTextSecondary.opacity(0.2)),
            alignment: .bottom
        )
    }
}

// MARK: - 통합 검색 헤더
struct ChatSearchHeader: View {
    @Binding var searchText: String
    @Binding var isSearchMode: Bool
    
    let searchManager: ChatSearchManager
    let onSearch: (String) -> Void
    let onNavigatePrevious: () -> Void
    let onNavigateNext: () -> Void
    let onCloseSearch: () -> Void
    
    var body: some View {
        VStack(spacing: 0) {
            if isSearchMode {
                if searchManager.hasResults && !searchText.isEmpty {
                    // 검색 결과가 있을 때: 네비게이션 바 표시
                    ChatSearchNavigationBar(
                        currentIndex: searchManager.currentResultIndex,
                        totalCount: searchManager.totalResultsCount,
                        onPreviousPressed: onNavigatePrevious,
                        onNextPressed: onNavigateNext,
                        onClosePressed: onCloseSearch
                    )
                } else {
                    // 검색 중이거나 결과가 없을 때: 검색바 표시
                    ChatSearchBar(
                        searchText: $searchText,
                        isActive: $isSearchMode,
                        onSearchCommitted: onSearch,
                        onCancel: onCloseSearch
                    )
                }
            }
        }
        .animation(.easeInOut(duration: 0.2), value: isSearchMode)
        .animation(.easeInOut(duration: 0.2), value: searchManager.hasResults)
    }
}

#if DEBUG
struct ChatSearchBar_Previews: PreviewProvider {
    @State static var searchText = "검색어 테스트"
    @State static var isActive = true
    
    static var previews: some View {
        VStack(spacing: 20) {
            ChatSearchBar(
                searchText: $searchText,
                isActive: $isActive,
                onSearchCommitted: { query in
                    print("검색: \(query)")
                },
                onCancel: {
                    print("검색 취소")
                }
            )
            
            ChatSearchNavigationBar(
                currentIndex: 2,
                totalCount: 10,
                onPreviousPressed: { print("이전") },
                onNextPressed: { print("다음") },
                onClosePressed: { print("닫기") }
            )
        }
        .background(Color.glintBackground)
    }
}
#endif