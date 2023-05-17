//
//  MapTabViewController.swift
//  Hotple
//
//  Created by SeongHoon Kim on 2023/02/10.
//

import UIKit
import SnapKit
import RxFlow
import RxCocoa
import ReactorKit

import NMapsMap
import CoreLocation

class MapTabViewController: UIViewController, View {
    
    var disposeBag: DisposeBag = DisposeBag()
    
    typealias Reactor = MapTabViewReactor
    
    weak var windowNavigationController: UINavigationController?
    
    private let locationManager = CLLocationManager()
    
    private var naverMapView = NMFNaverMapView()
    
    private lazy var animationController: MainAnimationController = {
        let controller = MainAnimationController(frame: view.frame, mapView: mapView)
        guard let animationView = controller.view else { return controller }
        mapView.addSubview(animationView)
        if let mapController = mapView.subviews.first(where: { $0 is UIImageView }) {
            mapView.bringSubviewToFront(mapController)
        }
        return controller
    }()
    
    private var boundsLatLng: (southWest: LatLng, northEast: LatLng) {
//        let boundsLatLngs = mapView.coveringBounds.boundsLatLngs
//        let point = CGPoint(x: 0, y: view.bounds.height)
        
        let southWest = LatLng(mapView.projection.latlngBounds(fromViewBounds: self.view.frame).southWest)
        let northEast = LatLng(mapView.projection.latlngBounds(fromViewBounds: self.view.frame).northEast)
        
        return (southWest: southWest, northEast: northEast)
    }
    
    var interactor: MainBusinessLogic?
    private var displayedData: ViewModel = .init(markers: [], polygons: [], bounds: [], count: 0)
    private var mapView: NMFMapView { naverMapView.mapView }
    private var projection: NMFProjection { naverMapView.mapView.projection }

    private var highlightMarker: NMFMarker? {
        didSet {
            guard highlightMarker != oldValue else { return }
            highlightMarker?.iconImage = NMF_MARKER_IMAGE_RED
            if let position = highlightMarker?.position {
                highlightMarker?.captionText = "\(position.lat),\n \(position.lng)"
            }
            oldValue?.iconImage = NMF_MARKER_IMAGE_GREEN
            oldValue?.captionText = ""
        }
    }

    
    /** Zoom Level **/
    let MIN_ZOOM_LEVEL = 5.5    // zoom level 최소값
    let MAX_ZOOM_LEVEL = 19.5   // zoom level 최대값
    
    override func loadView() {
        
        initView()
        initNaverMapView()
       
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        initNotificationCenter()
        initConstraint()
        
        configureVIP()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        initNavigationBar()
        
    }
    
    init(reactor: Reactor) {
        super.init(nibName: nil, bundle: nil)
        self.reactor = reactor
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    deinit {
        Log.debug("MapTabViewController deinit")
    }
    
    private func initNotificationCenter() {
        NotificationCenter.default.addObserver(self, selector: #selector(didEnterBackgroundObserver), name: UIApplication.willEnterForegroundNotification, object: nil)
    }
    
    /*
        상단 네비게이션 바 초기화
     */
    private func initNavigationBar() {
        
        let tempBtn1 = UIBarButtonItem(customView: UIView())
        let tempBtn2 = UIBarButtonItem(customView: UIView())
        
        _ = windowNavigationController?.viewControllers.map({ viewcontroller in
            if viewcontroller is UITabBarController {
                viewcontroller.navigationItem.rightBarButtonItems = [tempBtn1]
                viewcontroller.navigationItem.titleView = nil
                viewcontroller.navigationItem.leftBarButtonItems = [tempBtn2]
            }
        })

    }
    
    private func initView() {
        
        let view = UIView()
        
        self.view = view
        
        self.view.backgroundColor = .systemBrown
    }
    
    private func initNaverMapView() {
        
        // 지도 뷰
        NMFAuthManager.shared().delegate = self // 지도 권한 delegate
        naverMapView.mapView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: 5, right: 0)
        naverMapView.showScaleBar = true   // 축척(기준 거리)바 비활성화
        naverMapView.showLocationButton = true  // 현위치 버튼 활성화
        naverMapView.showCompass = true // 나침반 활성화
        naverMapView.showZoomControls = false    // 줌 버튼 활성화
        naverMapView.showIndoorLevelPicker = true   // 실내지도 층 피커
        naverMapView.mapView.mapType = .basic   // 일반 지도. 하천, 녹지, 도로, 심벌 등 다양한 정보
        naverMapView.mapView.setLayerGroup(NMF_LAYER_GROUP_TRANSIT, isEnabled: true)    // 대중교통 그룹. 철도, 지하철 노선, 버스정류장 등 대중교통과 관련된 요소가 노출
        naverMapView.mapView.isTiltGestureEnabled = false   // 두손가락으로 위아래 드래그 시 기울기 비활성화
        naverMapView.mapView.isStopGestureEnabled = false   // ?
        naverMapView.mapView.isIndoorMapEnabled = true  //  실내지도를 활성화
        naverMapView.mapView.logoAlign = .rightTop  // 네이버 로고
        naverMapView.mapView.logoMargin = UIEdgeInsets(top: 60, left: 0, bottom: 0, right: 10)
        naverMapView.mapView.extent = NMGLatLngBounds(southWest: NMGLatLng(lat: 31.43, lng: 122.37), northEast: NMGLatLng(lat: 44.35, lng: 132))    // 카메라의 대상 지점을 한반도 인근으로 제한
        naverMapView.mapView.minZoomLevel = MIN_ZOOM_LEVEL  // 카메라의 최소 줌 레벨
        naverMapView.mapView.maxZoomLevel = MAX_ZOOM_LEVEL  // 카메라의 최대 줌 레벨
        naverMapView.mapView.touchDelegate = self   // 지도 안 탭 할 경우 터치 이벤트 설정delegate (심벌 터치 포함) NMFMapViewTouchDelegate
        naverMapView.mapView.addCameraDelegate(delegate: self)  // 카메라 변경 이벤트 대기 이벤트 NMFMapViewCameraDelegate
        view.addSubview(naverMapView)
        

        
        checkLocationPermission()
        
        
    }
    
    
    func initConstraint() {
        
        naverMapView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        
    }
    
    /*
        사용자의 위치 정보를 확인할 수 있도록 위치 권한을 확인한다.
     */
    func checkLocationPermission() {
        
        switch locationManager.authorizationStatus {
        // 위치 사용 권한이 허용되어 있음
        case .authorizedAlways, .authorizedWhenInUse:
            Log.debug(".authorizedAlways, .authorizedWhenInUse")
            locationManager.delegate = self
            trackingCurrLocation()
            break
            
        // 위치 사용 권한 허용 여부 미결정 상태. 권한을 허용할 것인지 여부를 묻는 팝업이 나타난다.
        case .notDetermined:
            Log.debug(".notDetermined")
            
            locationManager.delegate = self
            locationManager.requestWhenInUseAuthorization()
            stopTrackingCurrLocation()
            break
            
        // 위치 사용 권한이 허용되지 않은 상태.
        case .restricted, .denied:
            Log.debug(".restricted, .denied")
            stopTrackingCurrLocation()
           break
            
        // [개인정보보호] -> [위치 서비스] 활성화 X
        @unknown default:
            Log.debug("default")
            
            break

        }
    }
    
    func trackingCurrLocation() {
        locationManager.startUpdatingLocation()

    }
    
    func stopTrackingCurrLocation() {
        locationManager.stopUpdatingLocation()
        
    }
        
    private func randomScale() -> Double {
        return Double(arc4random()) / Double(UINT32_MAX) * 2.0 - 1.0
    }
    
    @objc func didEnterBackgroundObserver() {
        Log.debug("didEnterBackground")
        
        checkLocationPermission()
    }
    
    func bind(reactor: MapTabViewReactor) {
        bindAction(reactor)
        bindState(reactor)
        
    }
    
    
    func bindAction(_ reactor: MapTabViewReactor) {
        //action
//        kakaoBtn.rx.tap
//            .map { _ in
//                return Reactor.Action.clickToKakao
//            }
//            .bind(to: reactor.action)
//            .disposed(by: disposeBag)
        
        

        
    }
    
    
    func bindState(_ reactor: MapTabViewReactor) {
        //state
        
//        reactor.state
//            .map { state in
//                print("reactor")
//                print(state.userData)
//                return String(state.userData.id)
//            }
//            .distinctUntilChanged()
//            .bind(to: testLbl.rx.text)
//            .disposed(by: disposeBag)
        
    }
    
}

// CLLocation 관련 delegate
extension MapTabViewController: CLLocationManagerDelegate {
    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        Log.debug("[locationManagerDidChangeAuthorization]")
        
        
        switch manager.authorizationStatus {
        // 사용자가 위치 권한 사용을 허용함
        case .authorizedAlways, .authorizedWhenInUse:
            Log.debug("CLLocationManagerDelegate - 사용자가 위치 권한 사용을 허용한 상태임")
            trackingCurrLocation()
            
        // 위치 사용 권한 허용 여부 미결정 상태. 권한을 허용할 것인지 여부를 묻는 팝업이 나타난다.
        case .notDetermined:
            Log.debug("CLLocationManagerDelegate - 사용자가 위치 권한 사용에 대한 허용 미결정 상태임")
            stopTrackingCurrLocation()
            break
            
        // 위치 사용 권한이 허용되지 않은 상태.
        case .denied, .restricted:
            Log.debug("CLLocationManagerDelegate - 사용자가 위치 권한 사용을 허용하지 않은 상태임")
            stopTrackingCurrLocation()
        // 그 외.
        @unknown default:
            Log.debug("CLLocationManagerDelegate - 사용자가 위치 권한 사용을 허용하지 않은 상태임 (DEFAULT)")
            stopTrackingCurrLocation()
        }

    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        Log.debug("[didUpdateLocations]")
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        Log.debug("[didFailWithError]")
        
        // 사용자가 장치에서 위치 서비스를 활성화하지 않았을때나,
        // 건물 내부에 있어 GPS 신호가 잡히지 않을 경우 호출된다.
    }
}

/* extension for NMFAuthManagerDelegate */
extension MapTabViewController: NMFAuthManagerDelegate {
    func authorized(_ state: NMFAuthState, error: Error?) {
            switch state {
            case .authorized:   // 인증 완료
                Log.network("naver map is authorized.")
            case .authorizing:  // 인증 진행중
                break
            case .pending:  // 인증 대기중
                break
            case .unauthorized: // 인증되지 않음
                Log.network("naver map is unauthorized.")
                
                if let error = error as NSError? {
                    let code = error.code
                }
                break
            default:
                break
            }
        }
}

/* extension for NMFMapViewTouchDelegate */
extension MapTabViewController: NMFMapViewTouchDelegate {
    /*
        지도를 탭했을때 호출된다.
     */
    func mapView(_ mapView: NMFMapView, didTapMap latlng: NMGLatLng, point: CGPoint) {
        Log.action("지도 탭")
        
    }
    
    /*
        지도 위의 심벌을 탭했을 때 호출된다.
        반환값이 true : 심벌 탭 이벤트에서 이벤트를 소비한 것으로 처리되어 지도 탭 이벤트 호출되지 않음.
        반환값이 false : 이벤트를 소비하지 않는 것으로 처리되어 지도 탭 이벤트로 이벤트 전파됨.
     */
    func mapView(_ mapView: NMFMapView, didTap symbol: NMFSymbol) -> Bool {
        return false
    }
}

/* extension for NMFMapViewCameraDelegate */
extension MapTabViewController: NMFMapViewCameraDelegate {
    // NMFMapChangedByDeveloper ==> 0 개발자가 API를 호출해 카메라가 움직였음을 나타냅니다. 기본값입니다.
    // NMFMapChangedByGesture ==> -1 사용자의 제스처로 인해 카메라가 움직였음을 나타냅니다.
    // NMFMapChangedByControl ==> -2 사용자의 버튼 선택으로 인해 카메라가 움직였음을 나타냅니다.
    // NMFMapChangedByLocation ==> -3 위치 트래킹 기능으로 인해 카메라가 움직였음을 나타냅니다.
    
    //카메라 변화 모든 제스처 시마다 호출 (드래그, 틸트, 줌 시)
    func mapView(_ mapView: NMFMapView, cameraDidChangeByReason reason: Int, animated: Bool) {
        Log.debug("1. cameraDidChangeByReason, reason : \(reason)")

    }
    
    //카메라 변화 제스처 후 자동 밀릴 때 호출 (빠른 이동 제스처 후 끝자락에서 부드럽게 움직이게 동작할 때 호출)
    func mapView(_ mapView: NMFMapView, cameraIsChangingByReason reason: Int) {
        Log.debug("2. cameraIsChangingByReason, reason : \(reason)")
        
    }
    
    //카메라 이동이 멈춘 후 대기 중일 때 한번 호출
    func mapViewCameraIdle(_ mapView: NMFMapView) {
        Log.debug("mapViewCameraIdle")
        let zoomLevel = mapView.zoomLevel
            
        interactor?.fetchPOI(southWest: boundsLatLng.southWest, northEast: boundsLatLng.northEast, zoomLevel: zoomLevel)
        
//        log("북서 꼭지점 위치: \(mapView.projection.latlngBounds(fromViewBounds: self.view.frame).southWest)")
//        log("남동 꼭지점 위치: \(mapView.projection.latlngBounds(fromViewBounds: self.view.frame).northEast)")
//        log("가운데 꼭지점 위치: \(mapView.projection.latlngBounds(fromViewBounds: self.view.frame).center)")
//        let centerAimPoint = mapView.projection.latlngBounds(fromViewBounds: self.view.frame).center
//        let southWestAimPoint = mapView.projection.latlngBounds(fromViewBounds: self.view.frame).southWest
//        let northEastAimPoint = mapView.projection.latlngBounds(fromViewBounds: self.view.frame).northEast


    }


    //줌 레벨 설정
    private func cameraChangeAction(_ mapView: NMFMapView, cameraIsChangingByReason reason: Int) {
        Log.debug("cameraIsChangingByReason, reason : \(reason)")

            
        
    }
}


extension MapTabViewController {
    
    private func configureVIP() {
        let interactor = MainInteractor()
        let presenter = MainPresenter()
        self.interactor = interactor
        interactor.presenter = presenter
        interactor.clustering?.tool = self
        interactor.clustering?.data = presenter
        presenter.viewController = self
    }
    
    private func setMarkersTouchHandler(markers: [NMFMarker], bounds: [NMGLatLngBounds]) {
            zip(markers, bounds).forEach { [weak self] marker, bound in
                guard let self = self,
                      let pointCount = marker.userInfo["pointCount"] as? Int
                else { return }
                
                guard pointCount == 1 else {
                    marker.touchHandler = { [weak self] _ in
                        self?.touchedClusterMarker(bounds: bound, insets: 10)
                        return true
                    }
                    return
                }
                
                marker.touchHandler = { [weak self] _ in
                    guard marker == self?.highlightMarker else {
                        self?.highlightMarker = marker
                        return true
                    }
                    self?.touchedLeafMarker(marker: marker)
                    return true
                }
            }
        }
    
    private func touchedClusterMarker(bounds: NMGLatLngBounds, insets: CGFloat) {
            
            let edgeInsets = UIEdgeInsets(top: insets, left: insets, bottom: insets , right: insets)
            let cameraUpdate = NMFCameraUpdate(fit: bounds,
                                               paddingInsets: edgeInsets,
                                               cameraAnimation: .easeIn,
                                               duration: 0.8)
            mapView.moveCamera(cameraUpdate)
        }
        
        private func touchedLeafMarker(marker: NMFMarker) {
            
        }
    
    func configureFirstMarkers(newMarkers: [NMFMarker], bounds: [NMGLatLngBounds]) {
            self.setOverlaysMapView(overlays: newMarkers, mapView: mapView)
            self.setMarkersTouchHandler(markers: newMarkers, bounds: bounds)
        }
        
        func setOverlaysMapView(overlays: [NMFOverlay], mapView: NMFMapView?) {
            return overlays.forEach { $0.mapView = mapView }
        }
        
        func markerChangeAnimation(oldMarkers: [NMFMarker],
                                   newMarkers: [NMFMarker],
                                   bounds: [NMGLatLngBounds],
                                   completion: (() -> Void)?) {
            self.setOverlaysMapView(overlays: oldMarkers, mapView: nil)

            self.animationController.clusteringAnimation(
                old: oldMarkers.map {
                    (latLng: $0.position, size: $0.iconImage.image)
                },
                new: newMarkers.map {
                    (latLng: $0.position, size: $0.iconImage.image)
                },
                isMerge: oldMarkers.count > newMarkers.count,
                completion: {
                    self.setOverlaysMapView(overlays: newMarkers, mapView: self.mapView)
                    self.setMarkersTouchHandler(markers: newMarkers, bounds: bounds)
                    completion?()
                })
        }
}

extension MapTabViewController: ClusteringTool {
    func convertLatLngToPoint(latLng: LatLng) -> CGPoint {
        return projection.point(from: NMGLatLng(lat: latLng.lat, lng: latLng.lng))
    }
}

extension MapTabViewController: MainDisplayLogic {
    func displayFetch(viewModel: ViewModel) {
        displayedData.markers.forEach({
            $0.touchHandler = nil
        })
        let oldViewModel = displayedData
        displayedData = viewModel
        redrawMap(oldViewModel: oldViewModel, newViewModel: viewModel)
    }
    
    private func redrawMap(oldViewModel: ViewModel?, newViewModel: ViewModel) {
        guard let oldViewModel = oldViewModel else {
            self.configureFirstMarkers(newMarkers: newViewModel.markers, bounds: newViewModel.bounds)
            return
        }

        self.setOverlaysMapView(overlays: oldViewModel.polygons, mapView: nil)
        
        self.markerChangeAnimation(
            oldMarkers: oldViewModel.markers,
            newMarkers: newViewModel.markers,
            bounds: newViewModel.bounds,
            completion: {
                self.setOverlaysMapView(overlays: newViewModel.polygons, mapView: self.mapView)
            })
    }
}
