//
//  TestData.swift
//  GLINT-iOS
//
//  Created by 박신영 on 5/21/25.
//

import SwiftUI

// MARK: - 오늘의 필터 모델
struct TodayFilter: Identifiable {
    let id = UUID()
    let smallTitle: String
    let largeTitle: String
    let description: String
    let backgroundImageName: String // 배경 이미지 에셋 이름
}

// MARK: - 카테고리 모델
struct FilterCategory: Identifiable, Hashable { // Hashable 추가 (버튼 식별용)
    let id = UUID()
    let iconName: String // SF Symbol 이름
    let name: String
}

// MARK: - 배너 모델
struct BannerItem: Identifiable {
    let id = UUID()
    let imageName: String
}

// MARK: - 핫 트렌드 모델
struct HotTrend: Identifiable {
    let id = UUID()
    let imageName: String
    let title: String
    let likes: Int
}

// MARK: - 오늘의 작가 모델
struct Artist: Identifiable {
    let id = UUID()
    let profileImageName: String
    let name: String
    let nickname: String
    let worksImageNames: [String] // 작가 작품 이미지 이름 배열
    let tags: [String]
    let introductionTitle: String
    let introductionBody: String
}

// MARK: - 더미 데이터
struct DummyFilterAppData {
    static let todayFilter = TodayFilter(
        smallTitle: "오늘의 필터 소개",
        largeTitle: "새싹을 담은 필터\n청록 새록",
        description: "햇살 아래 돋아나는 새싹처럼,\n맑고 투명한 빛을 담은 자연 감성 필터입니다.\n너무 과하지 않게, 부드러운 색감으로 분위기를 살려줍니다.\n새로운 시작, 순수한 감정을 담고 싶을 때 이 필터를 사용해보세요.",
        backgroundImageName: "today_filter_background" // 에셋에 추가할 이미지
    )

    static let categories: [FilterCategory] = [
        FilterCategory(iconName: "fork.knife", name: "푸드"),
        FilterCategory(iconName: "person.2.fill", name: "인물"),
        FilterCategory(iconName: "mountain.2.fill", name: "풍경"),
        FilterCategory(iconName: "moon.stars.fill", name: "야경"),
        FilterCategory(iconName: "sparkles", name: "별")
    ]

    static let bannerItems: [BannerItem] = (1...12).map { BannerItem(imageName: "banner_image_\($0)") } // "banner_image_1" ... "banner_image_12"

    static let hotTrends: [HotTrend] = [
        HotTrend(imageName: "trend_image_1", title: "어떤영화", likes: 30), // 왼쪽 어두운 이미지
        HotTrend(imageName: "trend_image_2", title: "소낙새", likes: 121), // 가운데 밝은 이미지
        HotTrend(imageName: "trend_image_3", title: "화양연화", likes: 88), // 오른쪽 어두운 이미지 (다음 슬라이드 시 가운데로 올 이미지)
        HotTrend(imageName: "trend_image_4", title: "다른느낌", likes: 55)
    ]

    static let todayArtist = Artist(
        profileImageName: "artist_profile",
        name: "윤새싹",
        nickname: "SESAC YOON",
        worksImageNames: ["artist_work_1", "artist_work_2", "artist_work_3"],
        tags: ["#섬세할", "#자연", "#미니멀"],
        introductionTitle: "\"자연의 섬세함을 담아내는 감성 사진작\"",
        introductionBody: "윤새싹은 자연의 섬세한 아름다움을 포착하는 데 탁월한 감각을 지닌 사진작가입니다. 그녀의 작품은 일상 속에서 쉽게 지나칠 수 있는 순간들을 특별하게 담아내며, 관람객들에게 새로운 시각을 선사합니다."
    )
}
