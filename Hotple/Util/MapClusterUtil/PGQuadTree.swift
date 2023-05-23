//
//  QuadTree.swift
//  PGClustering
//
//  Created by Pablo on 19/01/2019.
//  Copyright © 2019 Pablo Garcia. All rights reserved.
//

import Foundation
import UIKit
import CoreGraphics
import MapKit
import NMapsMap

class PGQuadTree {

    static let capacity = 4

    var markers = [NMFMarker]()
    var boundingBox: PGBoundingBox
    var isDivided = false

    private var northWest: PGQuadTree?
    private var northEast: PGQuadTree?
    private var southWest: PGQuadTree?
    private var southEast: PGQuadTree?

    init(boundingBox: PGBoundingBox) {
        self.boundingBox = boundingBox

    }
    
    deinit {
        self.markers.removeAll()
        isDivided = false

        northWest = nil
        northEast = nil
        southWest = nil
        southEast = nil
    }
    
    // 쿼드 트리 알고리즘을 적용 시킬 변수 초기화
    public func resetQuadTree() {
        self.markers.removeAll()
        isDivided = false

        northWest = nil
        northEast = nil
        southWest = nil
        southEast = nil
        
    }
    
    public func insertMarker(newMarker: NMFMarker) {

        guard self.boundingBox.containsCoordinate(coordinate: newMarker.position) else {

            return
        }
        if markers.count < PGQuadTree.capacity {
            
            markers.append(newMarker)
        } else {
            
            if northWest == nil {
                self.subdivideNode()
            }
            northWest?.insertMarker(newMarker: newMarker)
            northEast?.insertMarker(newMarker: newMarker)
            southWest?.insertMarker(newMarker: newMarker)
            southEast?.insertMarker(newMarker: newMarker)
        }
    }

    func queryRegion(searchInBoundingBox: PGBoundingBox, completion: ([NMFMarker]) -> Void) {
        
        guard searchInBoundingBox.intersectsWithBoundingBox(boundingBox: self.boundingBox) else {
            
            return
        }

        var totalMarkers = [NMFMarker]()
        for marker in self.markers {

            if searchInBoundingBox.containsCoordinate(coordinate: marker.position) {
                totalMarkers.append(marker)
            }
            
        }
        if self.isDivided {

            northEast?.queryRegion(searchInBoundingBox: searchInBoundingBox, completion: { (markers) in
                totalMarkers.append(contentsOf: markers)
            })
            northWest?.queryRegion(searchInBoundingBox: searchInBoundingBox, completion: { (markers) in
                totalMarkers.append(contentsOf: markers)
            })
            southEast?.queryRegion(searchInBoundingBox: searchInBoundingBox, completion: { (markers) in
                totalMarkers.append(contentsOf: markers)
            })
            southWest?.queryRegion(searchInBoundingBox: searchInBoundingBox, completion: { (markers) in
                totalMarkers.append(contentsOf: markers)
            })
        }
        completion(totalMarkers)
    }

    func getSubQuadTrees() -> [PGQuadTree] {
        if isDivided {
            return [northWest!, northEast!, southWest!, southEast!]
        } else {
            return []
        }
    }
}

extension PGQuadTree {

    private func subdivideNode() {
        self.isDivided = true

        let xMiddle = (boundingBox.xNorthEast+boundingBox.xSouthWest)/2.0
        let yMiddle = (boundingBox.yNorthEast+boundingBox.ySouthWest)/2.0

        self.northWest = PGQuadTree(boundingBox: PGBoundingBox(xSouthWest: boundingBox.xSouthWest, ySouthWest: yMiddle, xNorthEast: xMiddle, yNorthEast: boundingBox.yNorthEast))
        self.northEast = PGQuadTree(boundingBox: PGBoundingBox(xSouthWest: xMiddle, ySouthWest: yMiddle, xNorthEast: boundingBox.xNorthEast, yNorthEast: boundingBox.yNorthEast))
        self.southWest = PGQuadTree(boundingBox: PGBoundingBox(xSouthWest: boundingBox.xSouthWest, ySouthWest: boundingBox.ySouthWest, xNorthEast: xMiddle, yNorthEast: yMiddle))
        self.southEast = PGQuadTree(boundingBox: PGBoundingBox(xSouthWest: xMiddle, ySouthWest: boundingBox.ySouthWest, xNorthEast: boundingBox.xNorthEast, yNorthEast: yMiddle))

    }

}
