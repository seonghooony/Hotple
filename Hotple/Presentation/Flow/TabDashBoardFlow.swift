//
//  TabDashBoardFlow.swift
//  Hotple
//
//  Created by SeongHoon Kim on 2023/02/10.
//

import Foundation
import UIKit
import RxFlow

class TabDashBoardFlow: Flow {
    
    var rootViewController: UINavigationController
        
    var root: Presentable
    
    let tabDashBoardViewController: UITabBarController
    
    let homeTabFlow: HomeTabFlow
    let searchTabFlow: SearchTabFlow
    let mapTabFlow: MapTabFlow
    let feedTabFlow: FeedTabFlow
    let profileTabFlow: ProfileTabFlow
    
    init(rootViewController: UINavigationController) {
        
        print("TabDashBoardFlow init")
        print("windowNavigationController : \(rootViewController.viewControllers)")
        
        self.root = rootViewController
        self.rootViewController = rootViewController
        
        tabDashBoardViewController = UITabBarController()
        
        homeTabFlow = HomeTabFlow(windowNavigationController: rootViewController)
        searchTabFlow = SearchTabFlow(windowNavigationController: rootViewController)
        mapTabFlow = MapTabFlow(windowNavigationController: rootViewController)
        feedTabFlow = FeedTabFlow(windowNavigationController: rootViewController)
        profileTabFlow = ProfileTabFlow(windowNavigationController: rootViewController)
    }
        
    
    
    
    deinit {
        print("TabDashBoardFlow deinit")
        
    }
    
    func navigate(to step: Step) -> FlowContributors {
        print("excuting TabDashBoardFlow navigate")
        guard let step = step as? AppStep else { return .none }
        
        switch step {
        case .tabDashBoardIsRequired:
            return navigateToTabDashBoard()
            
        case .testIsRequired:
            return navigateToTest()
            
        case .logoutIsRequired:
            return logout()
            
        default:
            return .none
        }
    }
    
    
    private func navigateToTabDashBoard() -> FlowContributors {
        
        
        Flows.use(homeTabFlow, searchTabFlow, mapTabFlow, feedTabFlow, profileTabFlow,
                  when: .created) { [unowned self] flow1Root, flow2Root, flow3Root, flow4Root, flow5Root in
            let tabBarItem1 = UITabBarItem(title: "홈", image: UIImage(), selectedImage: UIImage())
            let tabBarItem2 = UITabBarItem(title: "검색", image: UIImage(), selectedImage: UIImage())
            let tabBarItem3 = UITabBarItem(title: "지도", image: UIImage(), selectedImage: UIImage())
            let tabBarItem4 = UITabBarItem(title: "피드", image: UIImage(), selectedImage: UIImage())
            let tabBarItem5 = UITabBarItem(title: "마이페이지", image: UIImage(), selectedImage: UIImage())
            
            flow1Root.tabBarItem = tabBarItem1
            flow2Root.tabBarItem = tabBarItem2
            flow3Root.tabBarItem = tabBarItem3
            flow4Root.tabBarItem = tabBarItem4
            flow5Root.tabBarItem = tabBarItem5

            
            tabDashBoardViewController.tabBar.backgroundColor = .white
            
            tabDashBoardViewController.setViewControllers([flow1Root, flow2Root, flow3Root, flow4Root, flow5Root], animated: false)
            
            
//            self.rootViewController.navigationBar.isHidden = true
            DispatchQueue.main.async {
//                self.rootViewController.pushViewController(tabDashBoardViewController, animated: false)
                self.rootViewController.navigationBar.isHidden = false
                self.rootViewController.navigationBar.backgroundColor = .clear
                self.rootViewController.setViewControllers([self.tabDashBoardViewController], animated: false)
            }

        }
        
        return .multiple(
            flowContributors: [
                .contribute(withNextPresentable: homeTabFlow, withNextStepper: OneStepper(withSingleStep: AppStep.homeTabIsRequired)),
                .contribute(withNextPresentable: searchTabFlow, withNextStepper: OneStepper(withSingleStep: AppStep.searchTabIsRequired)),
                .contribute(withNextPresentable: mapTabFlow, withNextStepper: OneStepper(withSingleStep: AppStep.mapTabIsRequired)),
                .contribute(withNextPresentable: feedTabFlow, withNextStepper: OneStepper(withSingleStep: AppStep.feedTabIsRequired)),
                .contribute(withNextPresentable: profileTabFlow, withNextStepper: OneStepper(withSingleStep: AppStep.profileTabIsRequired))
            ])
    }
    
    
    private func logout() -> FlowContributors {
        print("navigateToLogout")
        
        return .end(forwardToParentFlowWithStep: AppStep.loginIsRequired)

    }
    
    private func navigateToTest() -> FlowContributors {
        let testViewReactor = TestViewReactor()
                let viewController = TestViewController(reactor: testViewReactor)
                self.rootViewController.pushViewController(viewController, animated: true)

                return .one(flowContributor: .contribute(withNextPresentable: viewController, withNextStepper: testViewReactor))
    }
    
}
