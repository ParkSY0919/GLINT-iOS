//
//  NotificationRepository+.swift
//  GLINT-iOS
//
//  Created by 박신영 on 7/24/25.
//

import Foundation

extension NotificationRepository {
    static let liveValue: NotificationRepository = {
        let provider = NetworkService<NotificationEndPoint>()
        
        return NotificationRepository(
            push: { request in
                let response: Void =  try await provider.requestVoid(.push(request))
                print("NotiRepo push 결과: \(response)")
            }
        )
    }()
}
