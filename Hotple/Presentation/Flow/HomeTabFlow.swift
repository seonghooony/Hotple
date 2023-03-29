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
    
//    var root: Presentable
    
//    var rootViewController: UINavigationController
//
    init(windowNavigationController: UINavigationController) {
        
        self.windowNavigationController = windowNavigationController
        
        print("HomeTabFlow init")
        print("windowNavigationController : \(windowNavigationController.viewControllers)")
        
    }
    
    deinit {
        print("HomeTabFlow deinit")
    }
    
    func navigate(to step: Step) -> FlowContributors {
        print("excuting HomeTabFlow navigate")
        guard let step = step as? AppStep else { return . none }
        
        switch step {
            
        case .homeTabIsRequired:
            return self.navigateToHomeTab()
            
        case .testIsRequired:
            
            // 바깥 네비게이션에서 푸쉬
            return .one(flowContributor: .forwardToParentFlow(withStep: AppStep.testIsRequired))
            
            // 안쪽 네비게이션에서 푸쉬
//            return self.navigateToHomeTab()
            
            // 바깥 네비게이션에서 푸쉬하지만 이대로 이 화면은 끝이남
//            return .end(forwardToParentFlowWithStep: AppStep.testIsRequired)
            
        case .logoutIsRequired:
            return logout()
            
        default:
            return .none
        }
    }
    
    private func navigateToHomeTab() -> FlowContributors {
        
        let homeTabViewReactor = HomeTabViewReactor()
        let homeTabViewController = HomeTabViewController(reactor: homeTabViewReactor)
        homeTabViewController.windowNavigationController = windowNavigationController
        self.rootViewController.navigationBar.isHidden = true
        self.rootViewController.hidesBottomBarWhenPushed = true
        self.rootViewController.pushViewController(homeTabViewController, animated: false)
        

        
        return .one(flowContributor: .contribute(withNextPresentable: homeTabViewController, withNextStepper: homeTabViewReactor))
    }
    
    private func logout() -> FlowContributors {
        
        self.rootViewController.popViewController(animated: true)
        return .none
        
    }
    
}
