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
    
//    var root: Presentable 
//    
//    var rootViewController: UINavigationController
//    
//    init(rootViewController: UINavigationController) {
//        self.root = rootViewController
//        self.rootViewController = rootViewController
//    }
    
    deinit {
        print("SearchTabFlow deinit")
    }
    
    func navigate(to step: Step) -> FlowContributors {
        guard let step = step as? AppStep else { return . none }
        
        switch step {
            
        case .searchTabIsRequired:
            return self.navigateToSearchTab()
            
        default:
            return .none
        }
    }
    
    private func navigateToSearchTab() -> FlowContributors {
        
        let searchTabViewReactor = SearchTabViewReactor()
        let searchTabViewController = SearchTabViewController(reactor: searchTabViewReactor)
        self.rootViewController.pushViewController(searchTabViewController, animated: false)
        

        
        return .one(flowContributor: .contribute(withNextPresentable: searchTabViewController, withNextStepper: searchTabViewReactor))
    }
    
}
