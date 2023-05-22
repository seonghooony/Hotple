//
//  PGClusteringManager.swift
//  PGClustering
//
//  Created by Pablo on 07/02/2019.
//  Copyright © 2019 Pablo Garcia. All rights reserved.
//

import UIKit
import MapKit
import NMapsMap

protocol PGClusteringManagerDelegate: AnyObject {
    
    func displayMarkers(markers: [NMFMarker])
}

class PGClusteringManager {

    weak var delegate: PGClusteringManagerDelegate?

    private let quadTree: PGQuadTree!

    init(mapView: NMFMapView, frame: CGRect) {

        
        self.quadTree = PGQuadTree(boundingBox: PGBoundingBox.mapRectToBoundingBox(mapRect: mapView.projection.latlngBounds(fromViewBounds: frame)))

    }
    
    public func resetQuadTreeBoundingBox(mapView: NMFMapView, frame: CGRect) {

        quadTree.resetMarkers()
        quadTree.boundingBox = PGBoundingBox.mapRectToBoundingBox(mapRect: mapView.projection.latlngBounds(fromViewBounds: frame))
        
    }
    
    public func addAnnotation(marker: NMFMarker) {

            self.quadTree.insertMarker(newMarker: marker)

    }

    public func addMarkers(markers: [NMFMarker]) {

            for marker in markers {
                self.quadTree.insertMarker(newMarker: marker)
            }

    }

    public func clusterAnnotationWithinMapRectangle(mapView: NMFMapView, frame: CGRect, zoomScale: Double) {

        guard !zoomScale.isInfinite else {
            return
        }

        var clusterMarkers = [NMFMarker]()

        let minX = mapView.projection.latlngBounds(fromViewBounds: frame).southWest.lng
        let maxX = mapView.projection.latlngBounds(fromViewBounds: frame).northEast.lng
        let minY = mapView.projection.latlngBounds(fromViewBounds: frame).southWest.lat
        let maxY = mapView.projection.latlngBounds(fromViewBounds: frame).northEast.lat

        
        let cellSizePoints = Double(maxX - minX) / Double(PGClusteringManager.cellSizeForZoomScale(zoomScale: zoomScale))
                    
            var currentnum = 1
            var yCoordinate = minY
            
            while yCoordinate<maxY {
                var xCoordinate = minX
                
                while xCoordinate<maxX {
                    
                    let sw = NMGLatLng(lat: yCoordinate, lng: xCoordinate)
                    let ne = NMGLatLng(lat: yCoordinate + cellSizePoints, lng: xCoordinate + cellSizePoints)

                    
                    let area = PGBoundingBox.mapRectToBoundingBox(mapRect: NMGLatLngBounds(southWest: sw, northEast: ne))

                    
                    self.quadTree.queryRegion(searchInBoundingBox: area) { (markers) in

                        if markers.count > 1 {
                            var totalX = 0.0
                            var totalY = 0.0
                            
                            for marker in markers {
                                totalX += marker.position.lat
                                totalY += marker.position.lng
                            }
                            let totalMarkers = markers.count
                            
                            let centerMarker = NMFMarker()
                            centerMarker.position = NMGLatLng(lat: totalX/Double(totalMarkers), lng: totalY/Double(totalMarkers))
                            
                            clusterMarkers.append(centerMarker)

                        } else if markers.count == 1 {
                            clusterMarkers.append(markers.first!)
                        }
                    }
                    xCoordinate+=cellSizePoints
                    currentnum += 1
                }
                yCoordinate+=cellSizePoints
                
            }
        Log.debug("while문 끝")
            Log.info("클러스터링 된 마커 수 : \(clusterMarkers.count)")
            DispatchQueue.main.async {
                self.delegate?.displayMarkers(markers: clusterMarkers)
            }
                        
            
            
//        }

        
    }
 
}

extension PGClusteringManager {

    class func zoomScaleToZoomLevel(scale: MKZoomScale) -> Int {

        let totalTilesAtMaxZoom = MKMapSize.world.width / 256.0
        let zoomLevelAtMaxZoom = CGFloat(log2(totalTilesAtMaxZoom))
        
        return Int(max(0,zoomLevelAtMaxZoom+CGFloat(floor(log2f(Float(scale))+0.5))))

    }

    class func cellSizeForZoomScale(zoomScale: Double) -> Int {
        
        let zoomLevel = Int(zoomScale)
        Log.debug("#zoomLevel: \(zoomLevel)")
        
        switch zoomLevel {
        case 0...4:
            return 32
        case 5...8:
            return 16
        case 9...16:
            return 8
        case 17...20:
            return 4
        default:
            return 10
        }
    }

}
