//
//  NMFPolygonOverlay+.swift
//  BoostClusteringMaB
//
//  Created by 김석호 on 2020/12/01.
//
import Foundation
import NMapsMap
extension NMFPolygonOverlay {
    /// PolygonOverlay 하나 만들어주는 함수
    /// - Parameter points: 폴리곤 그릴 좌표
    /// - Returns: NMFPolygonOverlay
    static func create(points: [NMGLatLng]) -> NMFPolygonOverlay? {
        let polygon = NMGPolygon(ring: NMGLineString(points: points)) as NMGPolygon<AnyObject>
        guard let polygonOverlay = NMFPolygonOverlay(polygon) else { return nil }
        polygonOverlay.fillColor = UIColor.random()
        polygonOverlay.outlineWidth = 3
        polygonOverlay.outlineColor = UIColor(red: 25.0/255.0, green: 192.0/255.0, blue: 46.0/255.0, alpha: 1)
        return polygonOverlay
    }

    /// NMFPolygonOverlay 배열
    /// - Parameter convexHulls: 폴리곤 그릴 좌표(2차원 배열)
    /// - Returns: NMFPolygonOverlay로 만들어진 배열
    static func polygonOverlays(convexHulls: [[LatLng]]) -> [NMFPolygonOverlay] {
        return convexHulls.filter { $0.count > 3 }
            .compactMap { latlngs in
                let points = latlngs.map { NMGLatLng(lat: $0.lat, lng: $0.lng) }
                return NMFPolygonOverlay.create(points: points)
            }
    }
}
