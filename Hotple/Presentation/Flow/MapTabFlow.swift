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
    
//    var root: Presentable
    
//    var rootViewController: UINavigationController
//
    init(windowNavigationController: UINavigationController) {
        
        self.windowNavigationController = windowNavigationController
        
        print("MapTabFlow init")
        print("windowNavigationController : \(windowNavigationController.viewControllers)")
    }
    
    deinit {
        print("MapTabFlow deinit")
    }
    
    func navigate(to step: Step) -> FlowContributors {
        print("excuting MapTabFlow navigate")
        guard let step = step as? AppStep else { return . none }
        
        switch step {
            
        case .mapTabIsRequired:
            return self.navigateToMapTab()
            
        case .logoutIsRequired:
            return logout()
            
        default:
            return .none
        }
    }
    
    private func navigateToMapTab() -> FlowContributors {
        
        let mapTabViewReactor = MapTabViewReactor()
        let mapTabViewController = MapTabViewController(reactor: mapTabViewReactor)
        mapTabViewController.windowNavigationController = windowNavigationController
        self.rootViewController.navigationBar.isHidden = true
        self.rootViewController.pushViewController(mapTabViewController, animated: false)
        

        
        return .one(flowContributor: .contribute(withNextPresentable: mapTabViewController, withNextStepper: mapTabViewReactor))
    }
    
    private func logout() -> FlowContributors {
        
        self.rootViewController.popViewController(animated: true)
        return .none
        
    }
    
}
