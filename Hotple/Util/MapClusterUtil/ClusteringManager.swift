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

protocol ClusteringManagerDelegate: AnyObject {
    
    func displayMarkers(markersTuple: [(NMFMarker, NMFInfoWindow?)])
}

class ClusteringManager {
    
    private let infoWindowDataSource = CustomInfoWindowDataSource()
    
    weak var delegate: ClusteringManagerDelegate?
    
    private let quadTree: QuadTree!
    
    init(mapView: NMFMapView, frame: CGRect) {
        
        
        self.quadTree = QuadTree(boundingBox: BoundingBox.mapRectToBoundingBox(mapRect: mapView.projection.latlngBounds(fromViewBounds: frame)))
        
    }
    
    public func resetQuadTreeSetting(mapView: NMFMapView, frame: CGRect) {
        
        quadTree.resetQuadTree()
        quadTree.boundingBox = BoundingBox.mapRectToBoundingBox(mapRect: mapView.projection.latlngBounds(fromViewBounds: frame))
        
    }
    
    public func addMarkers(markers: [NMFMarker]) {
        
        for marker in markers {
            self.quadTree.insertMarker(newMarker: marker)
        }
        
    }
    
    public func runClustering(mapView: NMFMapView, frame: CGRect, zoomScale: Double) {
        
        guard !zoomScale.isInfinite else {
            return
        }
        
        var clusterMarkers = [(NMFMarker, NMFInfoWindow?)]()
        
        let minX = mapView.projection.latlngBounds(fromViewBounds: frame).southWest.lng
        let maxX = mapView.projection.latlngBounds(fromViewBounds: frame).northEast.lng
        let minY = mapView.projection.latlngBounds(fromViewBounds: frame).southWest.lat
        let maxY = mapView.projection.latlngBounds(fromViewBounds: frame).northEast.lat
        
        
        let cellSizePoints = Double(maxX - minX) / Double(ClusteringManager.cellSizeForZoomScale(zoomScale: zoomScale))
        
        var currentnum = 1
        var yCoordinate = minY
        
        while yCoordinate<maxY {
            var xCoordinate = minX
            
            while xCoordinate<maxX {
                
                let sw = NMGLatLng(lat: yCoordinate, lng: xCoordinate)
                let ne = NMGLatLng(lat: yCoordinate + cellSizePoints, lng: xCoordinate + cellSizePoints)
                
                
                let area = BoundingBox.mapRectToBoundingBox(mapRect: NMGLatLngBounds(southWest: sw, northEast: ne))
                
                
                self.quadTree.queryRegion(searchInBoundingBox: area) { (markers) in
                    
                    if markers.count > 1 {
                        
                        let centerMarker = makeClusteredMarker(markers: markers, mapView: mapView)
                        
                        clusterMarkers.append(centerMarker)
                        
                    } else if markers.count == 1 {
                        
                        let leafMarker = makeLeafMarker(marker: markers.first!, mapView: mapView)
                        
                        
                        clusterMarkers.append(leafMarker)
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
            self.delegate?.displayMarkers(markersTuple: clusterMarkers)
        }
        
    }
    
    // 클러스터링 된 마커의 Marker와 InfoWindow 튜플 배출
    private func makeClusteredMarker(markers: [NMFMarker], mapView: NMFMapView) -> (NMFMarker, NMFInfoWindow?) {
        var totalX = 0.0
        var totalY = 0.0
        
        for marker in markers {
            totalX += marker.position.lat
            totalY += marker.position.lng
        }
        let totalMarkers = markers.count
        
        var mapMarkerData = MapMarkerData()
        mapMarkerData.latitude = totalX
        mapMarkerData.longitude = totalY
        mapMarkerData.title = "\(markers.count) 개"
        mapMarkerData.type = MapType.Cluster
        mapMarkerData.count = markers.count
        
        let centerMarker = NMFMarker()
//        centerMarker.iconImage = NMFOverlayImage(image: UIImage())
        centerMarker.position = NMGLatLng(lat: totalX/Double(totalMarkers), lng: totalY/Double(totalMarkers))
        centerMarker.userInfo = [
            "data" : mapMarkerData
        ]
        
        
//        centerMarker.touchHandler = { [weak self] (overlay:NMFOverlay) -> Bool in
//
//            return true
//        }
        
        let infoWindow = NMFInfoWindow()
        infoWindow.position = NMGLatLng(lat: totalX/Double(totalMarkers), lng: totalY/Double(totalMarkers))
        infoWindow.userInfo = [
            "data" : mapMarkerData
        ]
        infoWindow.dataSource = infoWindowDataSource
        
        
        infoWindow.touchHandler = { [weak self] (overlay:NMFOverlay) -> Bool in
            guard let self = self else { return true }
            let cameraUpdate = NMFCameraUpdate(scrollTo: centerMarker.position, zoomTo: mapView.zoomLevel + 1)
            cameraUpdate.animation = .linear
            mapView.moveCamera(cameraUpdate)
            
            return true
        }
        
        
        return (centerMarker, infoWindow)
    }
    
    // 끝단 실제 마커의 Marker와 InfoWindow 튜플 배출
    private func makeLeafMarker(marker: NMFMarker, mapView: NMFMapView) -> (NMFMarker, NMFInfoWindow?) {

//        let infoWindow = NMFInfoWindow()
//        infoWindow.position = marker.position
//        infoWindow.userInfo = marker.userInfo
//        infoWindow.dataSource = infoWindowDataSource
//
//        infoWindow.touchHandler = { [weak self] (overlay:NMFOverlay) -> Bool in
//            guard let self = self else { return true }
//            let cameraUpdate = NMFCameraUpdate(scrollTo: marker.position, zoomTo: mapView.zoomLevel + 0.3)
//            cameraUpdate.animation = .linear
//            mapView.moveCamera(cameraUpdate)
//
//            return true
//        }
        
        return (marker, nil)
//        return (marker, infoWindow)
        
    }
    
}

extension ClusteringManager {
    
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
