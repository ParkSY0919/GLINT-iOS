//
//  GLINT_iOSApp.swift
//  GLINT-iOS
//
//  Created by 박신영 on 5/9/25.
//

import SwiftUI

import Alamofire
import Nuke
import NukeAlamofirePlugin

@main
struct GLINT_iOSApp: App {
    init() {
        setupNavigationAppearance()
        setupImagePipeline()
        KeychainManager.shared.saveDeviceUUID()
    }
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(\.loginViewUseCase, .liveValue)
        }
    }
    
    private func setupNavigationAppearance() {
        let appearance = UINavigationBarAppearance()
        appearance.configureWithOpaqueBackground()
        appearance.backgroundColor = UIColor(Color.gray100)
        if let pointFont = UIFont(name: "TTHakgyoansimMulgyeolB", size: 16) {
            appearance.titleTextAttributes = [
                .font: pointFont,
                .foregroundColor: UIColor(Color.gray0)
            ]
        }
        
        UINavigationBar.appearance().standardAppearance = appearance
        UINavigationBar.appearance().scrollEdgeAppearance = appearance
        UINavigationBar.appearance().compactAppearance = appearance
    }
    
    private func setupImageCaching() {
            // 메모리 캐시 크기 증가
            ImageCache.shared.costLimit = 1024 * 1024 * 200 // 200MB
            ImageCache.shared.countLimit = 200 // 이미지 개수
            
            // 디스크 캐시 설정
            let dataCache = try! DataCache(name: "com.yourapp.nuke")
            dataCache.sizeLimit = 1024 * 1024 * 500 // 500MB
            
            ImagePipeline.shared = ImagePipeline {
                $0.dataCache = dataCache
                $0.imageCache = ImageCache.shared
                $0.dataCachePolicy = .automatic
            }
        }
    private func setupImagePipeline() {
        let imageSession = Session(interceptor: Interceptor(
            interceptors: [GTInterceptor(type: .nuke)])
        )
        
        // ImageCache 설정 강화
        let imageCache = ImageCache()
        imageCache.countLimit = 200 // 이미지 개수 제한
        imageCache.costLimit = 200 * 1024 * 1024 // 200MB 메모리 제한
        
        let dataCache = try! DataCache(name: "com.yourapp.nuke")
        dataCache.sizeLimit = 1024 * 1024 * 500 // 500MB
        
        // Nuke ImagePipeline 설정
        let pipeline = ImagePipeline {
            $0.dataLoader = AlamofireDataLoader(session: imageSession)
            $0.dataCache = dataCache
            $0.imageCache = ImageCache.shared
            $0.dataCachePolicy = .automatic
//            $0.dataCachePolicy = .storeAll // 모든 데이터 캐시
            $0.isRateLimiterEnabled = true
            $0.isTaskCoalescingEnabled = true
            
            // 캐시 설정 강화
            $0.isProgressiveDecodingEnabled = false
            $0.isDecompressionEnabled = true
        }

        ImagePipeline.shared = pipeline
        
        GTLogger.shared.i("ImagePipeline configured with enhanced caching and GTInterceptor for token refresh functionality")
    }
}
