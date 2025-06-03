//
//  MetaDataSectionView.swift
//  GLINT-iOS
//
//  Created by AI Assistant on 1/19/25.
//

import SwiftUI

struct MetaDataSectionView: View {
    let camera: String?
    let photoMetadataString: String
    let megapixelInfo: String
    let address: String?
    let latitude: Double?
    let longitude: Double?
    
    var body: some View {
        GLMetaDataView(
            camera: camera,
            photoMetadataString: photoMetadataString,
            megapixelInfo: megapixelInfo,
            address: address,
            latitude: latitude,
            longitude: longitude
        )
        .padding(.top, 20)
    }
} 
