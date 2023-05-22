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

    static func mapRectToBoundingBox(mapRect: NMGLatLngBounds) -> PGBoundingBox {

//        let topLeft =  mapRect.origin.coordinate
//        let botRight = MKMapPoint(x: mapRect.maxX, y: mapRect.maxY).coordinate
//        Log.debug("박스 재설정")
        
        let minLat = mapRect.southWest.lat //botRight.latitude
        let maxLat = mapRect.northEast.lat

        let minLon = mapRect.southWest.lng
        let maxLon = mapRect.northEast.lng

        return PGBoundingBox(xSouthWest: CGFloat(minLon),
                             ySouthWest: CGFloat(minLat),
                             xNorthEast: CGFloat(maxLon),
                             yNorthEast: CGFloat(maxLat))
    }

    func containsCoordinate(coordinate: NMGLatLng) -> Bool {

        let isContainedInX = self.xSouthWest <= CGFloat(coordinate.lng) && CGFloat(coordinate.lng) <= self.xNorthEast
        let isContainedInY = self.ySouthWest <= CGFloat(coordinate.lat) && CGFloat(coordinate.lat) <= self.yNorthEast

        return (isContainedInX && isContainedInY)
    }

    func intersectsWithBoundingBox(boundingBox: PGBoundingBox) -> Bool {

        return (xSouthWest <= boundingBox.xNorthEast && xNorthEast >= boundingBox.xSouthWest &&
            ySouthWest <= boundingBox.yNorthEast && yNorthEast >= boundingBox.ySouthWest)
    }
}
