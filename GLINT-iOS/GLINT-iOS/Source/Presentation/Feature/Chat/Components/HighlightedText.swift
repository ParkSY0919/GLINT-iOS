//
//  HighlightedText.swift
//  GLINT-iOS
//
//  Created by Claude on 8/9/25.
//

import SwiftUI

struct HighlightedText: View {
    let text: String
    let searchQuery: String
    let font: Font
    let textColor: Color
    let highlightTextColor: Color
    let highlightBackgroundColor: Color
    
    init(
        text: String,
        searchQuery: String,
        font: Font = .system(size: 16, weight: .regular),
        textColor: Color = .primary,
        highlightTextColor: Color = .blue,
        highlightBackgroundColor: Color = .yellow.opacity(0.3)
    ) {
        self.text = text
        self.searchQuery = searchQuery
        self.font = font
        self.textColor = textColor
        self.highlightTextColor = highlightTextColor
        self.highlightBackgroundColor = highlightBackgroundColor
    }
    
    var body: some View {
        if searchQuery.isEmpty {
            // 검색어가 없으면 일반 텍스트 표시
            Text(text)
                .font(font)
                .foregroundColor(textColor)
        } else {
            // 검색어가 있으면 하이라이팅된 텍스트 표시
            highlightedTextView
        }
    }
    
    @ViewBuilder
    private var highlightedTextView: some View {
        let highlightedParts = highlightSearchQuery(in: text, query: searchQuery)
        
        // HStack과 ForEach를 사용하여 뷰 조합
        HStack(spacing: 0) {
            ForEach(highlightedParts.indices, id: \.self) { index in
                let part = highlightedParts[index]
                
                if part.isHighlighted {
                    Text(part.text)
                        .font(font)
                        .foregroundColor(highlightTextColor)
                        .background(
                            RoundedRectangle(cornerRadius: 4)
                                .fill(highlightBackgroundColor)
                                .padding(.horizontal, -2)
                                .padding(.vertical, -1)
                        )
                } else {
                    Text(part.text)
                        .font(font)
                        .foregroundColor(textColor)
                }
            }
        }
    }
}

// MARK: - Helper Structures
private struct TextPart {
    let text: String
    let isHighlighted: Bool
}

// MARK: - Helper Functions
private func highlightSearchQuery(in text: String, query: String) -> [TextPart] {
    guard !query.isEmpty else { return [TextPart(text: text, isHighlighted: false)] }
    
    let lowercaseText = text.lowercased()
    let lowercaseQuery = query.lowercased()
    
    var parts: [TextPart] = []
    var searchStartIndex = lowercaseText.startIndex
    
    while searchStartIndex < lowercaseText.endIndex {
        if let range = lowercaseText.range(of: lowercaseQuery, range: searchStartIndex..<lowercaseText.endIndex) {
            // 검색어 이전 부분 추가 (일반 텍스트)
            if searchStartIndex < range.lowerBound {
                let beforeText = String(text[searchStartIndex..<range.lowerBound])
                parts.append(TextPart(text: beforeText, isHighlighted: false))
            }
            
            // 검색어 부분 추가 (하이라이트)
            let highlightedText = String(text[range])
            parts.append(TextPart(text: highlightedText, isHighlighted: true))
            
            // 다음 검색 시작 위치 설정
            searchStartIndex = range.upperBound
        } else {
            // 더 이상 검색어가 없으면 나머지 텍스트 추가
            let remainingText = String(text[searchStartIndex..<text.endIndex])
            if !remainingText.isEmpty {
                parts.append(TextPart(text: remainingText, isHighlighted: false))
            }
            break
        }
    }
    
    return parts
}

// MARK: - Preview and Extensions
extension HighlightedText {
    /// 채팅 메시지용 프리셋
    static func chatMessage(
        text: String,
        searchQuery: String,
        isFromMe: Bool
    ) -> HighlightedText {
        return HighlightedText(
            text: text,
            searchQuery: searchQuery,
            font: .system(size: 16, weight: .regular),
            textColor: isFromMe ? .white : Color.glintTextPrimary,
            highlightTextColor: .blue,
            highlightBackgroundColor: .yellow.opacity(0.4)
        )
    }
}

#if DEBUG
struct HighlightedText_Previews: PreviewProvider {
    static var previews: some View {
        VStack(alignment: .leading, spacing: 20) {
            HighlightedText(
                text: "안녕하세요! 오늘 날씨가 정말 좋네요.",
                searchQuery: "날씨"
            )
            
            HighlightedText(
                text: "Multiple search query test in this text with query words",
                searchQuery: "query"
            )
            
            HighlightedText(
                text: "대소문자 구분 없는 Search 테스트입니다.",
                searchQuery: "search"
            )
        }
        .padding()
    }
}
#endif
