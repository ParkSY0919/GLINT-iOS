//
//  NetworkAwareCacheManager.swift
//  GLINT-iOS
//

import Network
import Nuke
import NukeAlamofirePlugin
import Foundation
import Alamofire

/// 네트워크 상태에 따른 동적 캐시 정책 관리자
final class NetworkAwareCacheManager {
    
    // MARK: - Properties
    
    static let shared = NetworkAwareCacheManager()
    
    private let monitor = NWPathMonitor()
    private let monitorQueue = DispatchQueue(label: "NetworkMonitor")
    private var currentNetworkType: NetworkType = .unknown
    
    // 기존 설정 보존을 위한 프로퍼티들
    private var baseSession: Session?
    private var baseInterceptors: [GTInterceptor] = []
    
    // MARK: - NetworkType
    
    enum NetworkType {
        case wifi
        case cellular
        case offline
        case unknown
        
        var displayName: String {
            switch self {
            case .wifi: return "WiFi"
            case .cellular: return "Cellular"
            case .offline: return "Offline"
            case .unknown: return "Unknown"
            }
        }
    }
    
    // MARK: - Cache Configuration
    
    struct CacheConfiguration {
        let dataCacheSizeLimit: Int
        let imageCacheCostLimit: Int
        let dataCachePolicy: ImagePipeline.DataCachePolicy
        let description: String
        
        static let wifi = CacheConfiguration(
            dataCacheSizeLimit: 200 * 1024 * 1024, // 200MB
            imageCacheCostLimit: 50 * 1024 * 1024,  // 50MB
            dataCachePolicy: .automatic,
            description: "WiFi 적극적 캐싱"
        )
        
        static let cellular = CacheConfiguration(
            dataCacheSizeLimit: 100 * 1024 * 1024, // 100MB
            imageCacheCostLimit: 25 * 1024 * 1024,  // 25MB
            dataCachePolicy: .storeAll,
            description: "Cellular 보수적 캐싱"
        )
        
        static let offline = CacheConfiguration(
            dataCacheSizeLimit: 50 * 1024 * 1024,  // 50MB (최소)
            imageCacheCostLimit: 15 * 1024 * 1024,  // 15MB (최소)
            dataCachePolicy: .storeAll,
            description: "Offline 캐시 전용"
        )
    }
    
    // MARK: - Initialization
    
    private init() {
        print("🌐 NetworkAwareCacheManager 초기화")
    }
    
    // MARK: - Public Methods
    
    /// 기존 세션과 인터셉터를 설정하고 네트워크 모니터링을 시작
    func configure(with session: Session, interceptors: [GTInterceptor] = []) {
        self.baseSession = session
        self.baseInterceptors = interceptors
        
        startNetworkMonitoring()
    }
    
    /// 네트워크 모니터링 시작
    func startNetworkMonitoring() {
        monitor.pathUpdateHandler = { [weak self] path in
            DispatchQueue.main.async {
                self?.handleNetworkChange(path)
            }
        }
        
        monitor.start(queue: monitorQueue)
        print("📡 네트워크 모니터링 시작")
    }
    
    /// 네트워크 모니터링 중지
    func stopNetworkMonitoring() {
        monitor.cancel()
        print("📡 네트워크 모니터링 중지")
    }
    
    /// 현재 네트워크 타입 반환
    var networkType: NetworkType {
        return currentNetworkType
    }
    
    /// 현재 캐시 설정 정보 반환
    func getCurrentCacheInfo() -> (dataCache: Int, imageCache: Int, policy: String) {
        let config = getCacheConfiguration(for: currentNetworkType)
        return (
            dataCache: config.dataCacheSizeLimit / (1024 * 1024),
            imageCache: config.imageCacheCostLimit / (1024 * 1024),
            policy: config.dataCachePolicy == .automatic ? "automatic" : "storeAll"
        )
    }
    
    // MARK: - Private Methods
    
    private func handleNetworkChange(_ path: NWPath) {
        let previousType = currentNetworkType
        
        if path.status == .satisfied {
            if path.usesInterfaceType(.wifi) {
                currentNetworkType = .wifi
            } else if path.usesInterfaceType(.cellular) {
                currentNetworkType = .cellular
            } else {
                currentNetworkType = .unknown
            }
        } else {
            currentNetworkType = .offline
        }
        
        // 네트워크 타입이 변경된 경우에만 캐시 정책 업데이트
        if previousType != currentNetworkType {
            print("📶 네트워크 변경: \(previousType.displayName) → \(currentNetworkType.displayName)")
            updateImagePipelineCachePolicy()
            postNetworkChangeNotification()
        }
    }
    
    private func updateImagePipelineCachePolicy() {
        guard let session = baseSession else {
            print("⚠️ Base session이 설정되지 않음. 캐시 정책 업데이트 생략")
            return
        }
        
        let config = getCacheConfiguration(for: currentNetworkType)
        
        do {
            // 새로운 데이터 캐시 생성
            let dataCache = try DataCache(name: "com.GLINT.nuke")
            dataCache.sizeLimit = config.dataCacheSizeLimit
            
            // 새로운 이미지 캐시 생성
            let imageCache = ImageCache()
            imageCache.countLimit = getImageCountLimit(for: currentNetworkType)
            imageCache.costLimit = config.imageCacheCostLimit
            
            // ImagePipeline 설정
            let pipelineConfig: ImagePipeline.Configuration
            
            if currentNetworkType == .offline {
                // 오프라인 모드 설정
                let offlineSession = createOfflineSession()
                pipelineConfig = createPipelineConfiguration(
                    session: offlineSession,
                    dataCache: dataCache,
                    imageCache: imageCache,
                    dataCachePolicy: .storeAll,
                    isRateLimiterEnabled: false
                )
            } else {
                // 온라인 모드 설정
                pipelineConfig = createPipelineConfiguration(
                    session: session,
                    dataCache: dataCache,
                    imageCache: imageCache,
                    dataCachePolicy: config.dataCachePolicy,
                    isRateLimiterEnabled: true
                )
            }
            
            ImagePipeline.shared = ImagePipeline(configuration: pipelineConfig)
            
            print("✅ 캐시 정책 업데이트 완료 - \(config.description)")
            print("   📊 데이터 캐시: \(config.dataCacheSizeLimit / (1024 * 1024))MB")
            print("   🖼️ 이미지 캐시: \(config.imageCacheCostLimit / (1024 * 1024))MB")
            print("   📋 정책: \(config.dataCachePolicy)")
            print("   📱 이미지 개수 제한: \(getImageCountLimit(for: currentNetworkType))개")
            
        } catch {
            print("❌ 캐시 정책 업데이트 실패: \(error.localizedDescription)")
        }
    }
    
    /// ImagePipeline Configuration 생성
    private func createPipelineConfiguration(
        session: Session,
        dataCache: DataCache,
        imageCache: ImageCache,
        dataCachePolicy: ImagePipeline.DataCachePolicy,
        isRateLimiterEnabled: Bool
    ) -> ImagePipeline.Configuration {
        var configuration = ImagePipeline.Configuration()
        
        configuration.dataLoader = AlamofireDataLoader(session: session)
        configuration.dataCache = dataCache
        configuration.imageCache = imageCache
        configuration.dataCachePolicy = dataCachePolicy
        configuration.isRateLimiterEnabled = isRateLimiterEnabled
        configuration.isTaskCoalescingEnabled = true
        configuration.isProgressiveDecodingEnabled = false
        configuration.isDecompressionEnabled = true
        
        return configuration
    }
    
    /// 네트워크 타입별 이미지 개수 제한 반환
    private func getImageCountLimit(for networkType: NetworkType) -> Int {
        switch networkType {
        case .wifi:
            return 50 // WiFi에서는 더 많은 이미지 캐시
        case .cellular:
            return 30 // 기본값
        case .offline:
            return 20 // 오프라인에서는 최소한으로 제한
        case .unknown:
            return 25 // 안전한 기본값
        }
    }
    
    /// 오프라인 전용 세션 생성 (타임아웃 매우 짧게 설정)
    private func createOfflineSession() -> Session {
        let configuration = URLSessionConfiguration.default
        configuration.timeoutIntervalForRequest = 3.0 // 3초 타임아웃
        configuration.timeoutIntervalForResource = 5.0 // 5초 리소스 타임아웃
        configuration.waitsForConnectivity = false // 연결 대기 안함
        
        return Session(
            configuration: configuration,
            interceptor: Interceptor(interceptors: baseInterceptors)
        )
    }
    
    private func getCacheConfiguration(for networkType: NetworkType) -> CacheConfiguration {
        switch networkType {
        case .wifi:
            return .wifi
        case .cellular:
            return .cellular
        case .offline:
            return .offline
        case .unknown:
            return .cellular // 안전한 기본값으로 cellular 설정 사용
        }
    }
    
    // MARK: - Debug Methods
    
    func printNetworkStatus() {
        let cacheInfo = getCurrentCacheInfo()
        print("🌐 현재 네트워크 상태:")
        print("   타입: \(currentNetworkType.displayName)")
        print("   데이터 캐시: \(cacheInfo.dataCache)MB")
        print("   이미지 캐시: \(cacheInfo.imageCache)MB")
        print("   정책: \(cacheInfo.policy)")
    }
    
    deinit {
        stopNetworkMonitoring()
    }
}

// MARK: - Network Type Extensions

extension NetworkAwareCacheManager.NetworkType: CustomStringConvertible {
    var description: String {
        return displayName
    }
}

// MARK: - Notification Extensions

extension NetworkAwareCacheManager {
    
    /// 네트워크 변경 알림을 위한 Notification Name
    static let networkTypeDidChangeNotification = Notification.Name("NetworkTypeDidChange")
    
    /// 네트워크 변경 시 알림 발송
    private func postNetworkChangeNotification() {
        NotificationCenter.default.post(
            name: Self.networkTypeDidChangeNotification,
            object: self,
            userInfo: ["networkType": currentNetworkType]
        )
    }
}
