//
//  GLINT_iOSApp.swift
//  GLINT-iOS
//
//  Created by 박신영
//

import SwiftUI
import Combine

import Alamofire
import Nuke
import NukeAlamofirePlugin

// AppDelegate 클래스 추가
class AppDelegate: NSObject, UIApplicationDelegate {
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        application.registerForRemoteNotifications()
        print("🚀 AppDelegate - didFinishLaunchingWithOptions")
        
        // AppInitializer를 통한 초기화
        AppInitManager.shared.setupCoreDataAndWebSocket()
        
        print("🚀 GLINT 앱 초기화 완료 - CoreData & WebSocket 준비됨")
        return true
    }
    
    // 원격 푸시 알림 등록 성공
    func application(_ application: UIApplication, didRegisterForRemoteNotificationsWitheviceToken deviceToken: Data) {
        print("📱 APNS 디바이스 토큰 등록 성공")
        // FCM에 APNS 토큰 설정
        // Firebase Messaging에서 자동으로 처리되므로 별도 구현 불필요
    }
    
    // 원격 푸시 알림 등록 실패
    func application(_ application: UIApplication, didFailToRegisterForRemoteNotificationsWithError error: Error) {
        print("❌ APNS 디바이스 토큰 등록 실패: \(error)")
    }
    
    // 백그라운드에서 푸시 알림 수신
    func application(_ application: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable: Any], fetchCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void) {
        print("📱 백그라운드 푸시 알림 수신: \(userInfo)")
        
        // FCMManager를 통한 알림 처리
        FCMManager.shared.handleRemoteNotification(userInfo)
        
        completionHandler(.newData)
    }
}

@main
struct GLINT_iOSApp: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) var delegate
    @State private var cancellables = Set<AnyCancellable>()
    
    init() {
        setupNavigationAppearance()
        setupImagePipeline()
        KeychainManager.shared.saveDeviceUUID()
    }
    
    var body: some Scene {
        WindowGroup {
            RootView()
                .onReceive(NotificationCenter.default.publisher(for: UIApplication.didEnterBackgroundNotification)) { _ in
                    // 백그라운드 진입 시 CoreData 저장
                    CoreDataManager.shared.saveContext()
                    print("📱 백그라운드 진입 - CoreData 저장 완료")
                }
                .onReceive(NotificationCenter.default.publisher(for: UIApplication.willTerminateNotification)) { _ in
                    // 앱 종료 시 CoreData 저장
                    CoreDataManager.shared.saveContext()
                    print("📱 앱 종료 - CoreData 저장 완료")
                }
        }
    }
    
    private func setupNavigationAppearance() {
        let appearance = UINavigationBarAppearance()
        appearance.configureWithOpaqueBackground()
        appearance.backgroundColor = UIColor(Color.gray100)
        if let pointFont = UIFont(name: "TTHakgyoansimMulgyeolB", size: 20) {
            appearance.titleTextAttributes = [
                .font: pointFont,
                .foregroundColor: UIColor(Color.gray0)
            ]
        }
        
        UINavigationBar.appearance().standardAppearance = appearance
        UINavigationBar.appearance().scrollEdgeAppearance = appearance
        UINavigationBar.appearance().compactAppearance = appearance
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
    }
}
