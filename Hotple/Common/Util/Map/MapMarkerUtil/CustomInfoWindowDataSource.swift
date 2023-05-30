//
//  CustomInfoWindowDataSource.swift
//  Hotple
//
//  Created by SeongHoon Kim on 2023/05/22.
//

import UIKit
import NMapsMap
import SnapKit

class CustomInfoWindowDataSource : NSObject {


}

extension CustomInfoWindowDataSource : NMFOverlayImageDataSource {
    
    func view(with overlay: NMFOverlay) -> UIView {
        if let infoWindow = overlay as? NMFInfoWindow {
            
            var mapMarkerData: MapMarkerData?
            
            if let marker = infoWindow.marker {
                mapMarkerData = marker.userInfo["data"] as? MapMarkerData
                
            } else {
                mapMarkerData = infoWindow.userInfo["data"] as? MapMarkerData
            }
            
            guard let mapType = mapMarkerData?.type else {
                Log.error("마커 생성 불가 : MapType이 명확하지 않음")
                return UIView()
            }
            
            
            
            switch mapType {
            case .Cluster:
//                Log.debug("cluster 뷰 만들기 시작")
                
                guard let mapCount = mapMarkerData?.count else {
                    Log.error("마커 생성 불가 : MapCount가 명확하지 않음")
                    return UIView()
                }
                
                let r: CGFloat = 18 + CGFloat(2 * log2(Double(mapCount)))
                
                let clusteredMarkerView = ClusteredMarkerView(frame: CGRect(x: 0, y: 0, width: 2 * r, height: 2 * r), count: mapCount)

                clusteredMarkerView.layoutIfNeeded()
                
                


                
                return clusteredMarkerView
                
            case .Leaf:
                let leafMarkerView = LeafMarkerView(frame: CGRect(x: 0, y: 0, width: 40,  height: 40))

                leafMarkerView.layoutIfNeeded()
                
                
                return leafMarkerView

            }
            
            
            
        }
        
        return UIView()
    }
}
