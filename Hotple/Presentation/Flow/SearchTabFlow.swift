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
    
    
    init(windowNavigationController: UINavigationController) {
        Log.debug("SearchTabFlow init")
        
        self.windowNavigationController = windowNavigationController
        
    }
    
    deinit {
        Log.debug("SearchTabFlow deinit")

    }
    
    func navigate(to step: Step) -> FlowContributors {
        
        guard let step = step as? AppStep else { return . none }
        
        Log.flow("excuting SearchTabFlow navigate")
        
        switch step {
            
        case .searchTabIsRequired:
            return self.navigateToSearchTab()
            
//        case .logoutIsRequired:
//            return logout()
            
        default:
            return .none
        }
    }
    
    private func navigateToSearchTab() -> FlowContributors {
        Log.flow("SearchTabFlow navigateToSearchTab")
        
        let searchTabViewReactor = SearchTabViewReactor()
        let searchTabViewController = SearchTabViewController(reactor: searchTabViewReactor)
        searchTabViewController.windowNavigationController = windowNavigationController
        self.rootViewController.navigationBar.isHidden = true
        self.rootViewController.pushViewController(searchTabViewController, animated: false)

        return .one(flowContributor: .contribute(withNextPresentable: searchTabViewController, withNextStepper: searchTabViewReactor))
    }
    
    
//    private func logout() -> FlowContributors {
//        
//        self.rootViewController.popViewController(animated: true)
//        return .none
//        
//    }
}
