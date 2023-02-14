//
//  TestFlow.swift
//  Hotple
//
//  Created by SeongHoon Kim on 2023/02/10.
//

import Foundation
import RxFlow

class TestFlow: Flow {
    
//    var root: Presentable {
//        return self.rootViewController
//    }
//
//    private let rootViewController = UINavigationController()
    
    var root: Presentable

    var rootViewController: UINavigationController

    init(rootViewController: UINavigationController) {
        self.root = rootViewController
        self.rootViewController = rootViewController
    }
    
    deinit {
        print("TestFlow deinit")
    }
    
    func navigate(to step: Step) -> FlowContributors {
        guard let step = step as? AppStep else { return . none }
        
        switch step {
            
        case .profileTabIsRequired:
            return self.navigateToTest()
            
        default:
            return .none
        }
    }
    
    private func navigateToTest() -> FlowContributors {
        
        let testViewReactor = TestViewReactor()
        let testViewController = TestViewController(reactor: testViewReactor)
        self.rootViewController.pushViewController(testViewController, animated: false)
        
        return .one(flowContributor: .contribute(withNextPresentable: testViewController, withNextStepper: testViewReactor))
    }
    
}
