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
    }
    
    var body: some Scene {
        WindowGroup {
            ContentView()
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
        UINavigationBar.appearance().compactAppearance = appearance // 추가 권장
    }
    
    private func setupImagePipeline() {
        let imageSession = Session(interceptor: Interceptor(
            interceptors: [GTInterceptor(type: .nuke)])
        )
        // Nuke ImagePipeline 설정
        let pipeline = ImagePipeline {
            $0.dataLoader = AlamofireDataLoader(session: imageSession)
            $0.imageCache = ImageCache.shared
            $0.dataCachePolicy = .automatic
            $0.isRateLimiterEnabled = true
            $0.isTaskCoalescingEnabled = true
        }

        ImagePipeline.shared = pipeline
        
        GTLogger.shared.i("ImagePipeline configured with GTInterceptor for token refresh functionality")
    }
}
