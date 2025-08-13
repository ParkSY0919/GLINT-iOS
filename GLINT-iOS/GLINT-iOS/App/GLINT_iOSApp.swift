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
import FirebaseMessaging

// AppDelegate 클래스 추가
class AppDelegate: NSObject, UIApplicationDelegate {
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        print("🚀 AppDelegate - didFinishLaunchingWithOptions")
        
        // AppInitializer를 통한 초기화 (FCM 제외)
        AppInitManager.shared.setupCoreDataAndWebSocketWithoutFCM()
        
        // APNS 등록 (FCM은 APNS 토큰 설정 후에 초기화)
        application.registerForRemoteNotifications()
        
        print("🚀 GLINT 앱 초기화 완료 - CoreData & WebSocket 준비됨")
        return true
    }
    
    // 원격 푸시 알림 등록 성공
    func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        print("📱 APNS 디바이스 토큰 등록 성공")
        
        // APNS 토큰을 Firebase Messaging에 설정
        Messaging.messaging().apnsToken = deviceToken
        print("🔥 APNS 토큰 Firebase에 설정 완료")
        
        // 이제 FCM 초기화 진행
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            AppInitManager.shared.setupFCM()
            print("🔥 FCM 초기화 완료 (APNS 토큰 설정 후)")
        }
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
    @State private var showLaunchView = true
    
    init() {
        setupNavigationAppearance()
        setupImagePipeline()
        KeychainManager.shared.saveDeviceUUID()
    }
    
    var body: some Scene {
        WindowGroup {
            ZStack {
                if showLaunchView {
                    LaunchView()
                        .onAppear {
                            // 2초 후 메인 화면으로 전환
                            DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
                                withAnimation(.easeInOut(duration: 0.5)) {
                                    showLaunchView = false
                                }
                            }
                        }
                } else {
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
        imageCache.countLimit = 30 // 이미지 개수 제한
        imageCache.costLimit = 50 * 1024 * 1024 // 50MB 메모리 제한
        
        let dataCache = try! DataCache(name: "com.GLINT.nuke")
        dataCache.sizeLimit = 1024 * 1024 * 200 // 200MB
        
        // Nuke ImagePipeline 설정
        let pipeline = ImagePipeline {
            $0.dataLoader = AlamofireDataLoader(session: imageSession)
            $0.dataCache = dataCache
            $0.imageCache = ImageCache.shared
            $0.dataCachePolicy = .automatic
            $0.isRateLimiterEnabled = true
            $0.isTaskCoalescingEnabled = true
            
            // 캐시 설정 강화
            $0.isProgressiveDecodingEnabled = false
            $0.isDecompressionEnabled = true
        }

        ImagePipeline.shared = pipeline
    }
}

