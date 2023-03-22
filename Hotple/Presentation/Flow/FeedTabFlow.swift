//
//  FeedTabFlow.swift
//  Hotple
//
//  Created by SeongHoon Kim on 2023/02/10.
//

import Foundation
import RxFlow

class FeedTabFlow: Flow {
    
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
        
        print("FeedTabFlow init")
        print("windowNavigationController : \(windowNavigationController.viewControllers)")
        
    }
    
    deinit {
        print("FeedTabFlow deinit")
    }
    
    func navigate(to step: Step) -> FlowContributors {
        print("excuting FeedTabFlow navigate")
        guard let step = step as? AppStep else { return . none }
        
        switch step {
            
        case .feedTabIsRequired:
            return self.navigateToFeedTab()
            
        case .logoutIsRequired:
            return logout()
            
        default:
            return .none
        }
    }
    
    private func navigateToFeedTab() -> FlowContributors {
        
        let feedTabViewReactor = FeedTabViewReactor()
        let feedTabViewController = FeedTabViewController(reactor: feedTabViewReactor)
        feedTabViewController.windowNavigationController = windowNavigationController
        self.rootViewController.navigationBar.isHidden = true
        self.rootViewController.pushViewController(feedTabViewController, animated: false)
        

        
        return .one(flowContributor: .contribute(withNextPresentable: feedTabViewController, withNextStepper: feedTabViewReactor))
    }
    
    private func logout() -> FlowContributors {
        
        self.rootViewController.popViewController(animated: true)
        return .none
        
    }
    
}
