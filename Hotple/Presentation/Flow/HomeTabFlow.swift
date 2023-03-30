//
//  HomeTabFlow.swift
//  Hotple
//
//  Created by SeongHoon Kim on 2023/02/10.
//

import Foundation
import RxFlow

class HomeTabFlow: Flow {
    
    var root: Presentable {
        return self.rootViewController
    }
    
    private let rootViewController = UINavigationController()
    
    private weak var windowNavigationController: UINavigationController?

    
    init(windowNavigationController: UINavigationController) {
        Log.debug("HomeTabFlow init")
        
        self.windowNavigationController = windowNavigationController

        
    }
    
    deinit {
        Log.debug("HomeTabFlow deinit")
    }
    
    func navigate(to step: Step) -> FlowContributors {
        
        guard let step = step as? AppStep else { return . none }
        
        Log.flow("excuting HomeTabFlow navigate")
        
        switch step {
            
        case .homeTabIsRequired:
            return self.navigateToHomeTab()
            
        case .testIsRequired:
            
            return self.test()
            // 바깥 네비게이션에서 푸쉬
//            return .one(flowContributor: .forwardToParentFlow(withStep: AppStep.testIsRequired))
            
            // 안쪽 네비게이션에서 푸쉬
//            return self.navigateToHomeTab()
            
            // 바깥 네비게이션에서 푸쉬하지만 이대로 이 화면은 끝이남
//            return .end(forwardToParentFlowWithStep: AppStep.testIsRequired)
            
//        case .logoutIsRequired:
//            return logout()
            
        default:
            return .none
        }
    }
    
    private func navigateToHomeTab() -> FlowContributors {
        
        Log.flow("HomeTabFlow navigateToHomeTab")
        
        let homeTabViewReactor = HomeTabViewReactor()
        let homeTabViewController = HomeTabViewController(reactor: homeTabViewReactor)
        homeTabViewController.windowNavigationController = windowNavigationController
//        self.rootViewController.navigationBar.isHidden = true
//        self.rootViewController.hidesBottomBarWhenPushed = true
        self.rootViewController.pushViewController(homeTabViewController, animated: false)
        
        return .one(flowContributor: .contribute(withNextPresentable: homeTabViewController, withNextStepper: homeTabViewReactor))
    }
    
    private func test() -> FlowContributors {
        
        let homeTabViewReactor = HomeTabViewReactor()
        let homeTabViewController = HomeTabViewController(reactor: homeTabViewReactor)
        homeTabViewController.windowNavigationController = windowNavigationController
//        self.rootViewController.navigationBar.isHidden = true
//        self.rootViewController.hidesBottomBarWhenPushed = true
        self.windowNavigationController?.pushViewController(homeTabViewController, animated: true)
        

        
        return .one(flowContributor: .contribute(withNextPresentable: homeTabViewController, withNextStepper: homeTabViewReactor))
    }
    
//    private func logout() -> FlowContributors {
//        
//        self.rootViewController.popViewController(animated: true)
//        return .none
//        
//    }
    
}
