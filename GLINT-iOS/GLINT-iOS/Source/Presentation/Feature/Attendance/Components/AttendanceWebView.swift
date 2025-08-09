//
//  AttendanceWebView.swift
//  GLINT-iOS
//
//  Created by Claude on 8/9/25.
//

import SwiftUI
import WebKit

struct AttendanceWebView: UIViewRepresentable {
    let onMessageReceived: (AttendanceMessage) -> Void
    let onWebViewLoadFailed: (() -> Void)?
    let onCoordinatorReady: ((Coordinator) -> Void)?
    
    func makeUIView(context: Context) -> WKWebView {
        let coordinator = context.coordinator
        
        // WKWebViewConfiguration 설정
        let configuration = WKWebViewConfiguration()
        configuration.userContentController.add(coordinator, name: "click_attendance_button")
        configuration.userContentController.add(coordinator, name: "complete_attendance")
        
        // WKWebView 생성
        let webView = WKWebView(frame: .zero, configuration: configuration)
        webView.navigationDelegate = coordinator
        
        // 저장해둔 참조로 JavaScript 호출을 위해
        coordinator.webView = webView
        
        // Coordinator를 외부로 전달
        onCoordinatorReady?(coordinator)
        
        return webView
    }
    
    func updateUIView(_ uiView: WKWebView, context: Context) {
        // URL 로드 - baseURL에서 호스트와 포트 추출
        let baseURL = Config.baseURL
        var urlString: String
        
        // baseURL이 이미 완전한 URL인 경우 처리
        if baseURL.hasPrefix("http://") || baseURL.hasPrefix("https://") {
            // baseURL에서 호스트와 포트 추출하여 event-application 경로 추가
            if baseURL.hasSuffix("/") {
                urlString = baseURL + "event-application"
            } else {
                urlString = baseURL + "/event-application"
            }
        } else {
            // 요구사항에 따른 기본 구성
            urlString = "http://\(baseURL):3001/event-application"
        }
        
        guard let url = URL(string: urlString) else {
            print("❌ Invalid URL: \(urlString)")
            return
        }
        
        // 요청에 헤더 추가
        var request = URLRequest(url: url)
        request.setValue(Config.sesacKey, forHTTPHeaderField: "SeSACKey")
        
        uiView.load(request)
    }
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    // MARK: - Coordinator
    class Coordinator: NSObject, WKScriptMessageHandler, WKNavigationDelegate {
        let parent: AttendanceWebView
        weak var webView: WKWebView?
        
        init(_ parent: AttendanceWebView) {
            self.parent = parent
        }
        
        // MARK: - WKScriptMessageHandler
        func userContentController(_ userContentController: WKUserContentController, didReceive message: WKScriptMessage) {
            print("📨 Received message from web: \(message.name), body: \(message.body)")
            
            switch message.name {
            case "click_attendance_button":
                parent.onMessageReceived(.clickAttendanceButton)
                
            case "complete_attendance":
                // message.body에서 출석 횟수 추출
                var attendanceCount: Int = 0
                if let bodyDict = message.body as? [String: Any],
                   let count = bodyDict["attendanceCount"] as? Int {
                    attendanceCount = count
                } else if let count = message.body as? Int {
                    attendanceCount = count
                }
                parent.onMessageReceived(.completeAttendance(count: attendanceCount))
                
            default:
                print("⚠️ Unknown message: \(message.name)")
            }
        }
        
        // MARK: - WKNavigationDelegate
        func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
            print("✅ WebView finished loading")
        }
        
        func webView(_ webView: WKWebView, didFail navigation: WKNavigation!, withError error: Error) {
            print("❌ WebView failed to load: \(error.localizedDescription)")
            parent.onWebViewLoadFailed?()
        }
        
        func webView(_ webView: WKWebView, didFailProvisionalNavigation navigation: WKNavigation!, withError error: Error) {
            print("❌ WebView failed provisional navigation: \(error.localizedDescription)")
            parent.onWebViewLoadFailed?()
        }
        
        // MARK: - JavaScript Communication
        func sendAccessToken(_ token: String, completion: @escaping (Bool, Error?) -> Void) {
            guard let webView = webView else {
                print("❌ WebView is not available")
                completion(false, NSError(domain: "WebViewError", code: -1, userInfo: [NSLocalizedDescriptionKey: "WebView is not available"]))
                return
            }
            
            let javascript = "requestAttendance('\(token)')"
            webView.evaluateJavaScript(javascript) { result, error in
                if let error = error {
                    print("❌ Failed to execute JavaScript: \(error.localizedDescription)")
                    completion(false, error)
                } else {
                    print("✅ Successfully sent access token to web")
                    completion(true, nil)
                }
            }
        }
        
        func reloadWebView() {
            webView?.reload()
        }
    }
}

// MARK: - AttendanceMessage
enum AttendanceMessage {
    case clickAttendanceButton
    case completeAttendance(count: Int)
}