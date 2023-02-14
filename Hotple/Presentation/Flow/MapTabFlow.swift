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
    
//    var root: Presentable
//    
//    var rootViewController: UINavigationController
//    
//    init(rootViewController: UINavigationController) {
//        self.root = rootViewController
//        self.rootViewController = rootViewController
//    }
    
    deinit {
        print("MapTabFlow deinit")
    }
    
    func navigate(to step: Step) -> FlowContributors {
        guard let step = step as? AppStep else { return . none }
        
        switch step {
            
        case .mapTabIsRequired:
            return self.navigateToMapTab()
            
        default:
            return .none
        }
    }
    
    private func navigateToMapTab() -> FlowContributors {
        
        let mapTabViewReactor = MapTabViewReactor()
        let mapTabViewController = MapTabViewController(reactor: mapTabViewReactor)
        self.rootViewController.pushViewController(mapTabViewController, animated: false)
        

        
        return .one(flowContributor: .contribute(withNextPresentable: mapTabViewController, withNextStepper: mapTabViewReactor))
    }
    
}
