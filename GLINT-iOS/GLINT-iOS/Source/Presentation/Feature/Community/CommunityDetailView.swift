//
//  CommunityDetailView.swift
//  GLINT-iOS
//
//  Created by 박신영 on 5/26/25.
//

import SwiftUI

struct CommunityDetailView: View {
    @State private var animateGradient = false
    @State private var showComments = false
    @State private var commentText = ""
    @State private var isLiked = false
    @State private var likeCount = Int.random(in: 50...500)
    @State private var replyingTo: String? = nil // 대댓글 대상 사용자명
    
    let id: String
    
    // 더미 카테고리 데이터
    private let categories = ["Photography", "Art", "Design", "Portrait", "Nature", "Urban", "Vintage"]
    
    init(id: String) {
        self.id = id
    }
    
    var body: some View {
        ZStack {
            backgroundGradient
            
            contentView
        }
        .navigationSetup(
            title: getConsistentCategory(),
            backAction: { },
            likeAction: { 
                withAnimation(.spring(response: 0.3, dampingFraction: 0.6)) {
                    isLiked.toggle()
                    likeCount += isLiked ? 1 : -1
                }
            },
            isLiked: isLiked
        )
        .ignoresSafeArea(.all)
        .onAppear {
            withAnimation(.easeInOut(duration: 4.0).repeatForever(autoreverses: true)) {
                animateGradient.toggle()
            }
        }
    }
    
    var backgroundGradient: some View {
        LinearGradient(
            colors: [
                Color.pinterestDarkBg,
                Color.pinterestDarkSurface,
                animateGradient ? Color.pinterestRedSoft.opacity(0.3) : Color.pinterestDarkBg
            ],
            startPoint: animateGradient ? .topLeading : .bottomTrailing,
            endPoint: animateGradient ? .bottomTrailing : .topLeading
        )
        .ignoresSafeArea(.all)
    }
}

private extension CommunityDetailView {
    var contentView: some View {
        ScrollView(showsIndicators: false) {
            VStack(spacing: 24) {
                // 헤더 스페이서
                Spacer()
                    .frame(height: 0)
                    .padding(.top, UIApplication.shared.windows.first?.safeAreaInsets.top ?? 44)
                
                modernContentCard {
                    VStack(spacing: 20) {
                        postImageSection
                        postInfoSection
                        interactionSection
                        commentsSection
                    }
                }
            }
            .padding(.bottom, 20)
        }
        .scrollContentBackground(.hidden)
    }
    
    
    func modernContentCard<Content: View>(@ViewBuilder content: () -> Content) -> some View {
        content()
            .padding(.horizontal, 24)
            .padding(.vertical, 28)
            .background(
                ZStack {
                    RoundedRectangle(cornerRadius: 24)
                        .fill(.ultraThinMaterial)
                        .background(
                            RoundedRectangle(cornerRadius: 24)
                                .fill(Color.pinterestDarkCard.opacity(0.6))
                        )
                    
                    RoundedRectangle(cornerRadius: 24)
                        .stroke(Color.glassStroke.opacity(0.5), lineWidth: 1)
                }
            )
            .shadow(color: .black.opacity(0.2), radius: 20, x: 0, y: 10)
            .padding(.horizontal, 24)
    }
    
    var postImageSection: some View {
        AsyncImage(url: URL(string: "https://picsum.photos/400/300?random=\(id.hashValue)")) { image in
            image
                .resizable()
                .scaledToFill()
        } placeholder: {
            Rectangle()
                .fill(
                    LinearGradient(
                        colors: [.pinterestDarkCard.opacity(0.3), .pinterestDarkSurface.opacity(0.5)],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .overlay {
                    VStack(spacing: 8) {
                        Image(systemName: "photo")
                            .font(.system(size: 32, weight: .light))
                            .foregroundColor(.pinterestTextTertiary)
                        
                        ProgressView()
                            .progressViewStyle(CircularProgressViewStyle(tint: .pinterestRed))
                    }
                }
        }
        .aspectRatio(16/9, contentMode: .fill)
        .frame(maxHeight: 300)
        .clipped()
        .clipShape(RoundedRectangle(cornerRadius: 20))
        .overlay(
            RoundedRectangle(cornerRadius: 20)
                .stroke(Color.glassStroke.opacity(0.3), lineWidth: 1)
        )
    }
    
    var postInfoSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            // 제목
            Text(getConsistentTitle())
                .font(.pretendardFont(.title_bold, size: 24))
                .foregroundColor(.pinterestTextPrimary)
                .shadow(color: .black.opacity(0.1), radius: 1, x: 0, y: 1)
                .padding(.horizontal, 4)
            
            // 작성자 정보
            HStack(spacing: 12) {
                Circle()
                    .fill(
                        LinearGradient(
                            colors: [.pinterestRed, .gradientMid],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .frame(width: 40, height: 40)
                    .overlay(
                        Image(systemName: "person.fill")
                            .font(.system(size: 18, weight: .medium))
                            .foregroundColor(.white)
                    )
                    .shadow(color: .pinterestRed.opacity(0.3), radius: 4, x: 0, y: 2)
                
                VStack(alignment: .leading, spacing: 2) {
                    Text(getConsistentAuthor())
                        .font(.pretendardFont(.body_bold, size: 16))
                        .foregroundColor(.pinterestTextPrimary)
                    
                    Text("@\(getConsistentUsername())")
                        .font(.pretendardFont(.body_medium, size: 14))
                        .foregroundColor(.pinterestTextSecondary)
                }
                
                Spacer()
                
                Text(getConsistentTimeStamp())
                    .font(.pretendardFont(.caption, size: 12))
                    .foregroundColor(.pinterestTextTertiary)
            }
            .padding(.horizontal, 4)
            
            // 내용
            Text(getConsistentContent())
                .font(.pretendardFont(.body_medium, size: 16))
                .foregroundColor(.pinterestTextSecondary)
                .lineLimit(nil)
                .lineSpacing(4)
                .padding(.horizontal, 4)
        }
    }
    
    var interactionSection: some View {
        HStack(spacing: 24) {
            // 좋아요 버튼
            Button(action: {
                withAnimation(.spring(response: 0.3, dampingFraction: 0.6)) {
                    isLiked.toggle()
                    likeCount += isLiked ? 1 : -1
                }
            }) {
                HStack(spacing: 8) {
                    Image(systemName: isLiked ? "heart.fill" : "heart")
                        .font(.system(size: 18, weight: .semibold))
                        .foregroundColor(isLiked ? .pinterestRed : .pinterestTextSecondary)
                        .scaleEffect(isLiked ? 1.2 : 1.0)
                    
                    Text("\(likeCount)")
                        .font(.pretendardFont(.body_medium, size: 16))
                        .foregroundColor(.pinterestTextSecondary)
                }
            }
            .buttonStyle(PlainButtonStyle())
            
            // 댓글 버튼
            Button(action: {
                withAnimation(.spring(response: 0.4, dampingFraction: 0.7)) {
                    showComments.toggle()
                }
            }) {
                HStack(spacing: 8) {
                    Image(systemName: "bubble.left")
                        .font(.system(size: 18, weight: .semibold))
                        .foregroundColor(.pinterestTextSecondary)
                    
                    Text("\(getConsistentCommentCount())")
                        .font(.pretendardFont(.body_medium, size: 16))
                        .foregroundColor(.pinterestTextSecondary)
                }
            }
            .buttonStyle(PlainButtonStyle())
            
            Spacer()
            
            // 공유 버튼
            Button(action: {}) {
                HStack(spacing: 8) {
                    Image(systemName: "square.and.arrow.up")
                        .font(.system(size: 18, weight: .semibold))
                        .foregroundColor(.pinterestTextSecondary)
                    
                    Text("공유")
                        .font(.pretendardFont(.body_medium, size: 16))
                        .foregroundColor(.pinterestTextSecondary)
                }
            }
            .buttonStyle(PlainButtonStyle())
        }
        .padding(.horizontal, 4)
        .padding(.vertical, 8)
    }
    
    var commentsSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            if showComments {
                commentsListSection
                commentInputSection
            } else {
                // 댓글 미리보기
                commentPreviewSection
            }
        }
    }
    
    var commentPreviewSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("댓글")
                .font(.pretendardFont(.body_bold, size: 18))
                .foregroundColor(.pinterestTextPrimary)
                .padding(.horizontal, 4)
            
            // 댓글 미리보기
            VStack(spacing: 8) {
                commentItemView(
                    username: "photo_lover",
                    comment: "정말 멋진 효과네요! 어떤 앱으로 만드셨어요?",
                    time: "2시간 전",
                    isReply: false,
                    onReplyTapped: { username in
                        replyingTo = username
                        showComments = true
                    }
                )
                
                commentItemView(
                    username: "filter_master",
                    comment: "색감이 너무 자연스러워요 ✨",
                    time: "1시간 전",
                    isReply: false,
                    onReplyTapped: { username in
                        replyingTo = username
                        showComments = true
                    }
                )
            }
            
            Button(action: {
                withAnimation(.spring(response: 0.4, dampingFraction: 0.7)) {
                    showComments = true
                }
            }) {
                Text("댓글 \(getConsistentCommentCount())개 모두 보기")
                    .font(.pretendardFont(.body_medium, size: 14))
                    .foregroundColor(.pinterestRed)
            }
            .buttonStyle(PlainButtonStyle())
            .padding(.horizontal, 4)
        }
    }
    
    var commentsListSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Text("댓글")
                    .font(.pretendardFont(.body_bold, size: 18))
                    .foregroundColor(.pinterestTextPrimary)
                
                Spacer()
                
                Button(action: {
                    withAnimation(.spring(response: 0.4, dampingFraction: 0.7)) {
                        showComments = false
                    }
                }) {
                    Text("접기")
                        .font(.pretendardFont(.body_medium, size: 14))
                        .foregroundColor(.pinterestRed)
                }
                .buttonStyle(PlainButtonStyle())
            }
            .padding(.horizontal, 4)
            
            VStack(spacing: 12) {
                commentItemView(
                    username: "photo_lover",
                    comment: "정말 멋진 효과네요! 어떤 앱으로 만드셨어요?",
                    time: "2시간 전",
                    isReply: false,
                    onReplyTapped: { username in
                        replyingTo = username
                    }
                )
                
                commentItemView(
                    username: "creative_user",
                    comment: "@photo_lover 감사합니다! GLINT 앱으로 만들었어요 😊",
                    time: "2시간 전",
                    isReply: true,
                    onReplyTapped: { username in
                        replyingTo = username
                    }
                )
                
                commentItemView(
                    username: "filter_master",
                    comment: "색감이 너무 자연스러워요 ✨ 저도 써보고 싶어요",
                    time: "1시간 전",
                    isReply: false,
                    onReplyTapped: { username in
                        replyingTo = username
                    }
                )
                
                commentItemView(
                    username: "photo_enthusiast",
                    comment: "와 이 필터 정말 좋네요! 다운로드 링크 있나요?",
                    time: "45분 전",
                    isReply: false,
                    onReplyTapped: { username in
                        replyingTo = username
                    }
                )
                
                commentItemView(
                    username: "creative_user",
                    comment: "@photo_enthusiast 프로필 링크로 들어오시면 받으실 수 있어요!",
                    time: "30분 전",
                    isReply: true,
                    onReplyTapped: { username in
                        replyingTo = username
                    }
                )
            }
        }
    }
    
    var commentInputSection: some View {
        VStack(spacing: 12) {
            // 대댓글 상태 표시
            if let replyingTo = replyingTo {
                HStack(spacing: 8) {
                    Text("@\(replyingTo)에게 답글")
                        .font(.pretendardFont(.caption_medium, size: 12))
                        .foregroundColor(.pinterestRed)
                    
                    Spacer()
                    
                    Button(action: {
                        self.replyingTo = nil
                    }) {
                        Image(systemName: "xmark")
                            .font(.system(size: 12, weight: .medium))
                            .foregroundColor(.pinterestTextTertiary)
                    }
                    .buttonStyle(PlainButtonStyle())
                }
                .padding(.horizontal, 4)
            }
            
            HStack(spacing: 12) {
                Circle()
                    .fill(Color.pinterestTextTertiary.opacity(0.3))
                    .frame(width: 32, height: 32)
                    .overlay(
                        Image(systemName: "person.fill")
                            .font(.system(size: 14, weight: .medium))
                            .foregroundColor(.pinterestTextTertiary)
                    )
                
                TextField(replyingTo != nil ? "@\(replyingTo!) " : "댓글을 입력하세요...", text: $commentText)
                    .font(.pretendardFont(.body_medium, size: 14))
                    .foregroundColor(.pinterestTextPrimary)
                    .padding(.horizontal, 16)
                    .padding(.vertical, 12)
                    .background(
                        RoundedRectangle(cornerRadius: 20)
                            .fill(.ultraThinMaterial)
                            .background(
                                RoundedRectangle(cornerRadius: 20)
                                    .fill(Color.pinterestDarkCard.opacity(0.3))
                            )
                    )
                    .overlay(
                        RoundedRectangle(cornerRadius: 20)
                            .stroke(Color.glassStroke.opacity(0.3), lineWidth: 1)
                    )
                
                Button(action: {
                    // 댓글 전송 로직
                    commentText = ""
                    replyingTo = nil
                }) {
                    Image(systemName: "paperplane.fill")
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundColor(.pinterestRed)
                }
                .buttonStyle(PlainButtonStyle())
            }
            .padding(.horizontal, 4)
        }
    }
    
    func commentItemView(username: String, comment: String, time: String, isReply: Bool, onReplyTapped: @escaping (String) -> Void) -> some View {
        HStack(alignment: .top, spacing: 12) {
            if isReply {
                Spacer()
                    .frame(width: 24)
            }
            
            Circle()
                .fill(
                    LinearGradient(
                        colors: [.pinterestRed.opacity(0.7), .gradientMid.opacity(0.7)],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .frame(width: 28, height: 28)
                .overlay(
                    Image(systemName: "person.fill")
                        .font(.system(size: 12, weight: .medium))
                        .foregroundColor(.white)
                )
            
            VStack(alignment: .leading, spacing: 6) {
                HStack(spacing: 8) {
                    Text("@\(username)")
                        .font(.pretendardFont(.body_bold, size: 14))
                        .foregroundColor(.pinterestTextPrimary)
                    
                    Text(time)
                        .font(.pretendardFont(.caption, size: 12))
                        .foregroundColor(.pinterestTextTertiary)
                    
                    Spacer()
                }
                
                Text(comment)
                    .font(.pretendardFont(.body_medium, size: 14))
                    .foregroundColor(.pinterestTextSecondary)
                    .lineLimit(nil)
                    .multilineTextAlignment(.leading)
                
                // 대댓글 버튼 (대댓글이 아닌 원댓글에만 표시)
                if !isReply {
                    Button(action: {
                        onReplyTapped(username)
                    }) {
                        Text("답글")
                            .font(.pretendardFont(.caption_medium, size: 12))
                            .foregroundColor(.pinterestTextTertiary)
                            .padding(.horizontal, 8)
                            .padding(.vertical, 4)
                            .background(
                                RoundedRectangle(cornerRadius: 12)
                                    .fill(Color.pinterestTextTertiary.opacity(0.1))
                            )
                            .overlay(
                                RoundedRectangle(cornerRadius: 12)
                                    .stroke(Color.pinterestTextTertiary.opacity(0.2), lineWidth: 1)
                            )
                    }
                    .buttonStyle(PlainButtonStyle())
                }
            }
            
            Spacer()
        }
        .padding(.leading, isReply ? 16 : 0)
    }
    
    // 일관된 더미 데이터를 생성하는 헬퍼 메서드들
    private func getConsistentCategory() -> String {
        let index = abs(id.hashValue) % categories.count
        return categories[index]
    }
    
    private func getConsistentTitle() -> String {
        let titles = [
            "Creative Filter Effect",
            "Vintage Film Look",
            "Modern Portrait Style",
            "Nature Color Boost",
            "Dreamy Sunset Glow",
            "Urban Street Vibe",
            "Classic B&W Filter"
        ]
        let index = abs(id.hashValue) % titles.count
        return titles[index]
    }
    
    private func getConsistentAuthor() -> String {
        let authors = [
            "Creative Artist",
            "Photo Master", 
            "Filter Expert",
            "Visual Creator",
            "Art Enthusiast",
            "Photo Wizard",
            "Creative User"
        ]
        let index = abs(id.hashValue) % authors.count
        return authors[index]
    }
    
    private func getConsistentUsername() -> String {
        let usernames = [
            "creative_artist",
            "photo_lover", 
            "filter_master",
            "visual_creator",
            "art_enthusiast",
            "photo_wizard",
            "creative_user"
        ]
        let index = abs(id.hashValue) % usernames.count
        return usernames[index]
    }
    
    private func getConsistentTimeStamp() -> String {
        let timeStamps = [
            "30분 전", "1시간 전", "2시간 전", "3시간 전", 
            "5시간 전", "1일 전", "2일 전", "3일 전"
        ]
        let index = abs(id.hashValue) % timeStamps.count
        return timeStamps[index]
    }
    
    private func getConsistentCommentCount() -> Int {
        let seed = abs(id.hashValue)
        return (seed % 7) + 1 // 1-7 범위
    }
    
    private func getConsistentContent() -> String {
        let contents = [
            "이 필터는 자연스러운 색감과 부드러운 톤을 만들어내는 특별한 효과를 가지고 있습니다. 일상 사진을 더욱 따뜻하고 아늑한 느낌으로 변화시켜 드립니다.",
            "빈티지한 필름 느낌을 완벽하게 재현한 필터입니다. 노스탤지어한 분위기를 연출하고 싶을 때 사용하면 정말 좋아요!",
            "모던하고 세련된 느낌의 인물 사진을 만들 수 있는 필터예요. 특히 프로필 사진이나 셀피에 적용하면 놀라운 결과를 얻을 수 있습니다.",
            "자연 사진의 색감을 한층 더 생생하고 아름답게 만들어주는 필터입니다. 풍경 사진에 적용하면 마치 영화 속 한 장면같은 느낌을 연출할 수 있어요.",
            "꿈결같이 부드럽고 따뜻한 석양 느낌을 만들어주는 특별한 필터입니다. 로맨틱한 분위기를 연출하고 싶을 때 완벽한 선택이에요.",
            "도시의 역동적이고 힙한 분위기를 표현할 수 있는 필터예요. 거리 사진이나 건축물 사진에 적용하면 정말 멋진 결과를 얻을 수 있습니다.",
            "클래식하고 우아한 흑백 필터입니다. 시대를 초월하는 아름다움을 표현하고 싶을 때 사용하면 정말 좋아요!"
        ]
        let index = abs(id.hashValue) % contents.count
        return contents[index]
    }
}