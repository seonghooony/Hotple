//
//  SearchTabFlow.swift
//  Hotple
//
//  Created by SeongHoon Kim on 2023/02/10.
//

import Foundation
import RxFlow

class SearchTabFlow: Flow {
    
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
     
        print("SearchTabFlow init")
        print("windowNavigationController : \(windowNavigationController.viewControllers)")
        
    }
    
    deinit {
        print("SearchTabFlow deinit")
    }
    
    func navigate(to step: Step) -> FlowContributors {
        print("excuting SearchTabFlow navigate")
        guard let step = step as? AppStep else { return . none }
        
        switch step {
            
        case .searchTabIsRequired:
            return self.navigateToSearchTab()
            
        case .logoutIsRequired:
            return logout()
            
        default:
            return .none
        }
    }
    
    private func navigateToSearchTab() -> FlowContributors {
        
        let searchTabViewReactor = SearchTabViewReactor()
        let searchTabViewController = SearchTabViewController(reactor: searchTabViewReactor)
        searchTabViewController.windowNavigationController = windowNavigationController
        self.rootViewController.navigationBar.isHidden = true
        self.rootViewController.pushViewController(searchTabViewController, animated: false)
        

        
        return .one(flowContributor: .contribute(withNextPresentable: searchTabViewController, withNextStepper: searchTabViewReactor))
    }
    
    
    private func logout() -> FlowContributors {
        
        self.rootViewController.popViewController(animated: true)
        return .none
        
    }
}
