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
        let imageSession = Session(interceptor: Interceptor(
            interceptors: [GTInterceptor(type: .nuke)])
        )
        
        let pipeline = ImagePipeline {
            $0.dataLoader = AlamofireDataLoader(session: imageSession)
            $0.imageCache = ImageCache.shared
            $0.dataCachePolicy = .automatic
            $0.isRateLimiterEnabled = true
        }

        ImagePipeline.shared = pipeline
    }
    
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
    }
}
