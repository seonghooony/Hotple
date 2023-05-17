//
//  Clustering.swift
//  BoostClusteringMaB
//
//  Created by 강민석 on 2020/11/26.
//
import Foundation

protocol ClusteringService {
    var data: ClusteringData? { get set }
    var tool: ClusteringTool? { get set }
    func findOptimalClustering(southWest: LatLng, northEast: LatLng, zoomLevel: Double)
    func combineClusters(clusters: [Cluster]) -> [Cluster]
}

final class Clustering: ClusteringService {
    typealias LatLngs = [LatLng]
    
    weak var data: ClusteringData?
    weak var tool: ClusteringTool?

    private let coreDataLayer: CoreDataManager

    private let queue: OperationQueue = {
        let queue = OperationQueue()
        queue.underlyingQueue = .global(qos: .userInteractive)
        queue.qualityOfService = .userInteractive
        return queue
    }()

    private let dbiOperationQueue = OperationQueue()
    
    var pois = [POI]()

    init(coreDataLayer: CoreDataManager) {
        self.coreDataLayer = coreDataLayer
        dbiOperationQueue.maxConcurrentOperationCount = 1
    }

    func findOptimalClustering(southWest: LatLng, northEast: LatLng, zoomLevel: Double) {
        
        queue.cancelAllOperations()
        Log.info("######1")
//        let poi = coreDataLayer.fetch(southWest: southWest, northEast: northEast, sorted: true)
        Log.info("######2")
//        guard let pois = poi?.map({$0.toPOI()}) else { return }
        
        var temppois = [POI]()
        
        if pois.count == 0 {
            let lati = 37.514634749
            let lngi = 127.104260695
            for i in 0...10 {
                for j in 0...10 {
                    
                    let templat = Double.random(in: southWest.lat...northEast.lat)
                    let templng = Double.random(in: southWest.lng...northEast.lng)
                    var tempPoi = POI(latLng: LatLng(lat: templat, lng: templng))
    //                var tempPoi = POI(latLng: LatLng(lat: lati + Double(i) * 0.01 + 0.0001 * Double.random(in: 0...10), lng: lngi + Double(j) * 0.01 + 0.0001 * Double.random(in: 0...10)) )
                    pois.append(tempPoi)
                }
                
            }
        } else {
            pois.map { poi in
                if southWest.lat < poi.latLng.lat && northEast.lat > poi.latLng.lat {
                    if southWest.lng < poi.latLng.lng && northEast.lng > poi.latLng.lng {
                        temppois.append(poi)
                    }
                }
                
            }
        }
        
        
//        let pois = [POI(latLng: LatLng(lat: 37.514634749, lng: 127.104260695))]
        
        guard !temppois.isEmpty else {
            self.data?.redrawMap([], [], [], [])
            return
        }
        runKMeans(pois: temppois, zoomLevel: zoomLevel)
    }

    private func runKMeans(pois: [POI], zoomLevel: Double) {
        let kRange = findKRange(zoomLevel: Int(zoomLevel))

        let kMeansArr = kRange.map { k -> KMeans in
            let kMeans = KMeans(k: k, pois: pois)
            queue.addOperation(kMeans)
            return kMeans
        }

        queue.addBarrierBlock { [weak self] in
            guard let minKmeans = kMeansArr.min(by: { $0.dbi < $1.dbi }) else { return }
            DispatchQueue.main.async {
                self?.groupNotifyTasks(minKmeans)
            }
        }
    }
    
    private func findKRange(zoomLevel: Int) -> Range<Int> {
        let start: Int
        let end: Int
        Log.debug("#zoom : \(zoomLevel)")
        let favorite = (13...17)
        if favorite.contains(zoomLevel) {
            start = zoomLevel - 10
        } else {
            start = 2
        }
        end = start + 10
        
        return (start..<end)
    }
    
    private func groupNotifyTasks(_ minKMeans: KMeans) {
        let combinedClusters = self.combineClusters(clusters: minKMeans.clusters)
        
        var points = [Int]()
        var centroids = LatLngs()
        var convexHullPoints = [LatLngs]()
        var bounds = [(southWest: LatLng, northEast: LatLng)]()

        combinedClusters.forEach({ cluster in
            points.append(cluster.pois.size)
            centroids.append(cluster.center)
            convexHullPoints.append(cluster.area())
            let cluster = cluster.southWestAndNorthEast()
            bounds.append((southWest: cluster.southWest,
                           northEast: cluster.northEast))
        })
        self.data?.redrawMap(centroids, points, bounds, convexHullPoints)
    }
    
    func combineClusters(clusters: [Cluster]) -> [Cluster] {
        let stdDistance: Double = 60
        var newClusters = clusters
        
        for i in 0..<clusters.count {
            for j in 0..<clusters.count where i < j {
                guard let point1 = tool?.convertLatLngToPoint(latLng: clusters[i].center),
                      let point2 = tool?.convertLatLngToPoint(latLng: clusters[j].center) else { return [] }
                let distance = point1.distance(to: point2)
                
                if stdDistance > distance {
                    newClusters[i].combine(other: newClusters[j])
                    newClusters.remove(at: j)
                    return combineClusters(clusters: newClusters)
                }
            }
        }
        return clusters
    }
}
