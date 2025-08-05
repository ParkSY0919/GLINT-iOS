//
//  NotificationRepository.swift
//  GLINT-iOS
//
//  Created by 박신영 on 7/24/25.
//

import Foundation

struct NotificationRepository {
    var push: (_ request: PushRequest) async throws -> Void
}
