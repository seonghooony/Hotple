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
    
//    var root: Presentable
//
//    var rootViewController: UINavigationController
//
//    init(rootViewController: UINavigationController) {
//        self.root = rootViewController
//        self.rootViewController = rootViewController
//    }
    
    deinit {
        print("FeedTabFlow deinit")
    }
    
    func navigate(to step: Step) -> FlowContributors {
        guard let step = step as? AppStep else { return . none }
        
        switch step {
            
        case .feedTabIsRequired:
            return self.navigateToFeedTab()
            
        default:
            return .none
        }
    }
    
    private func navigateToFeedTab() -> FlowContributors {
        
        let feedTabViewReactor = FeedTabViewReactor()
        let feedTabViewController = FeedTabViewController(reactor: feedTabViewReactor)
        self.rootViewController.pushViewController(feedTabViewController, animated: false)
        

        
        return .one(flowContributor: .contribute(withNextPresentable: feedTabViewController, withNextStepper: feedTabViewReactor))
    }
    
}
