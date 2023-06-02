//
//  MapUseCase.swift
//  Hotple
//
//  Created by SeongHoon Kim on 2023/05/26.
//

import Foundation

import RxSwift
import RxCocoa
import NMapsMap

protocol MapUserUseCaseProtocol {
    func generateRandomMarker(size: Int) -> [NMFMarker]
}

final class MapUseCase: MapUserUseCaseProtocol {
    private let localRepository: LocalRepository
    private let firebaseRepository: FirebaseRepository

    
    var randomMarkers = [NMFMarker]()
    
    var disposeBag = DisposeBag()
    
    init(localRepository: LocalRepository, firebaseRepository: FirebaseRepository) {
        Log.debug("MapUseCase init")
//        self.mapView = mapView
        self.localRepository = localRepository
        self.firebaseRepository = firebaseRepository
    }
    
    deinit {
        disposeBag = DisposeBag()
        Log.debug("MapUseCase deinit")
    }
    
    func generateRandomMarker(size: Int) -> [NMFMarker] {

        if self.randomMarkers.count > 0 {
            return self.randomMarkers
        } else {
            for i in 1...size {
                let marker = NMFMarker()
                let lat = 37.514634749 + Double.random(in: 0.01...0.1)
                let lng = 127.104260695 + Double.random(in: 0.01...0.1)
                marker.position = NMGLatLng(lat: lat, lng: lng)
                marker.iconImage = NMF_MARKER_IMAGE_BLACK
                marker.captionText = "\(i)번째 POI"
                marker.captionColor = UIColor.carrot
                marker.captionHaloColor = UIColor.white
    //                marker.iconTintColor = UIColor.clear
    //                marker.iconImage = NMFOverlayImage(image: UIImage())
    //                marker.width = 1
    //                marker.height = 1
                
                var mapMarkerData = MapMarkerData()
                mapMarkerData.latitude = lat
                mapMarkerData.longitude = lng
                mapMarkerData.title = "id : \(i)"
                mapMarkerData.type = MapType.Leaf
                
                marker.userInfo = [
                    "data" : mapMarkerData
                ]

                
                self.randomMarkers.append(marker)
            }
            
            
            return self.randomMarkers
        }
        
            
        
    }
    
}
