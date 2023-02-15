//
//  ProfileTabFlow.swift
//  Hotple
//
//  Created by SeongHoon Kim on 2023/02/10.
//

import Foundation
import RxFlow

class ProfileTabFlow: Flow {
    
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
        print("ProfileTabFlow deinit")
    }
    
    func navigate(to step: Step) -> FlowContributors {
        guard let step = step as? AppStep else { return . none }
        
        switch step {
            
        case .profileTabIsRequired:
            return self.navigateToProfileTab()
            
        default:
            return .none
        }
    }
    
    private func navigateToProfileTab() -> FlowContributors {
        
        let profileTabViewReactor = ProfileTabViewReactor()
        let profileTabViewController = ProfileTabViewController(reactor: profileTabViewReactor)
        self.rootViewController.navigationBar.isHidden = true
        self.rootViewController.pushViewController(profileTabViewController, animated: false)
        

        
        return .one(flowContributor: .contribute(withNextPresentable: profileTabViewController, withNextStepper: profileTabViewReactor))
    }
    
}
