//
//  MapTabFlow.swift
//  Hotple
//
//  Created by SeongHoon Kim on 2023/02/10.
//

import Foundation
import RxFlow

class MapTabFlow: Flow {
    
    var root: Presentable {
        return self.rootViewController
    }
    
    private let rootViewController = UINavigationController()
    
    private weak var windowNavigationController: UINavigationController?
    
    let mapUseCase: MapUseCase

    init(windowNavigationController: UINavigationController) {
        Log.debug("MapTabFlow init")
        
        self.windowNavigationController = windowNavigationController
        
        let localRepository = LocalRepository()
        let firebaseRepository = FirebaseRepository()
        self.mapUseCase = MapUseCase(localRepository: localRepository, firebaseRepository: firebaseRepository)
        
    }
    
    deinit {
        Log.debug("MapTabFlow deinit")
    }
    
    func navigate(to step: Step) -> FlowContributors {

        guard let step = step as? AppStep else { return . none }
        
        Log.flow("excuting MapTabFlow navigate")
        
        switch step {
            
        case .mapTabIsRequired:
            return self.navigateToMapTab()
            
//        case .logoutIsRequired:
//            return logout()
            
        default:
            return .none
        }
    }
    
    private func navigateToMapTab() -> FlowContributors {
        
        Log.flow("MapTabFlow navigateToMapTab")
        
        let mapTabViewReactor = MapTabViewReactor(mapUseCase: mapUseCase)
        let mapTabViewController = MapTabViewController(reactor: mapTabViewReactor)
        mapTabViewController.windowNavigationController = windowNavigationController
        self.rootViewController.navigationBar.isHidden = true
        self.rootViewController.pushViewController(mapTabViewController, animated: false)
        

        
        return .one(flowContributor: .contribute(withNextPresentable: mapTabViewController, withNextStepper: mapTabViewReactor))
    }
    
//    private func logout() -> FlowContributors {
//        
//        self.rootViewController.popViewController(animated: true)
//        return .none
//        
//    }
    
}
