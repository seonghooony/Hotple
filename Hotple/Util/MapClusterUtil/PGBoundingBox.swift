//
//  PGBox.swift
//  PGClustering
//
//  Created by Pablo on 30/03/2019.
//  Copyright © 2019 Pablo Garcia. All rights reserved.
//

import UIKit
import MapKit
import NMapsMap

struct PGBoundingBox {
    
    let xSouthWest: CGFloat
    let ySouthWest: CGFloat
    let xNorthEast: CGFloat
    let yNorthEast: CGFloat
    
    
    // 클러스터 될 영역의 박스를 설정한다.
    static func mapRectToBoundingBox(mapRect: NMGLatLngBounds) -> PGBoundingBox {

        let minLat = mapRect.southWest.lat //botRight.latitude
        let maxLat = mapRect.northEast.lat
        
        let minLon = mapRect.southWest.lng
        let maxLon = mapRect.northEast.lng
        
        return PGBoundingBox(xSouthWest: CGFloat(minLon),
                             ySouthWest: CGFloat(minLat),
                             xNorthEast: CGFloat(maxLon),
                             yNorthEast: CGFloat(maxLat))
    }
    
    // 마커가 박스 영역 안에 포함되는지 확인한다.
    func containsCoordinate(coordinate: NMGLatLng) -> Bool {
        
        let isContainedInX = self.xSouthWest <= CGFloat(coordinate.lng) && CGFloat(coordinate.lng) <= self.xNorthEast
        let isContainedInY = self.ySouthWest <= CGFloat(coordinate.lat) && CGFloat(coordinate.lat) <= self.yNorthEast
        
        return (isContainedInX && isContainedInY)
    }
    
    // 셀이 박스 영역 안에 포함되는지 확인한다.
    func intersectsWithBoundingBox(boundingBox: PGBoundingBox) -> Bool {
        
        return (xSouthWest <= boundingBox.xNorthEast && xNorthEast >= boundingBox.xSouthWest &&
                ySouthWest <= boundingBox.yNorthEast && yNorthEast >= boundingBox.ySouthWest)
    }
}
