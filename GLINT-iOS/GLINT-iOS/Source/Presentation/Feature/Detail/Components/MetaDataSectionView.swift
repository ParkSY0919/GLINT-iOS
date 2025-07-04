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
    let latitude: Float?
    let longitude: Float?
    
    var body: some View {
        metaDataSection
            .padding(.top, 20)
    }
}

private extension MetaDataSectionView {
    var metaDataSection: some View {
        GTMetaDataView(
            camera: camera,
            photoMetadataString: photoMetadataString,
            megapixelInfo: megapixelInfo,
            address: address,
            latitude: latitude,
            longitude: longitude
        )
    }
} 
