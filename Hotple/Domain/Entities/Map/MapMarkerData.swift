//
//  MapData.swift
//  Hotple
//
//  Created by SeongHoon Kim on 2023/05/22.
//

import Foundation

struct MapMarkerData {
    
    var id: String?
    
    /* 데이터 내 설정된 lat, lng */
    var latitude: Double?
    var longitude: Double?
    
    var title: String?
    var subTitle: String?
    
    var count: Int?
    
    var type: MapType?
    
}
