//
//  AppFlow.swift
//  Hotple
//
//  Created by SeongHoon Kim on 2023/02/01.
//


import Foundation
import RxFlow

class AppFlow: Flow {
    
    var window: UIWindow
    
    var root: Presentable {
        return self.window
    }
    
    init(window: UIWindow) {
        self.window = window
    }
    
    deinit {
        print("AppFlow deinit")
    }
    
    func navigate(to step: RxFlow.Step) -> RxFlow.FlowContributors {
        guard let step = step as? AppStep else { return .none }
        print("현재 appflow")
        switch step {
            
        case .splashIsRequired:
            return self.navigateToSplash()
            
        case .loginIsRequired:
            return self.navigateToLogin()
//        case .homeIsRequired:
//            return self.navigateToHome()
            
        default:
            return .none
            
        }
        
    }
    
    private func navigateToSplash() -> FlowContributors {
        let splashFlow = SplashFlow()

        // mainFlow 생성 시 root 를 window에 연결함.
        Flows.use(splashFlow, when: .created) { (root) in
            self.window.rootViewController = root
        }

        let nextStep = OneStepper(withSingleStep: AppStep.splashIsRequired)

        return .one(flowContributor: .contribute(withNextPresentable: splashFlow, withNextStepper: nextStep))
    }
    
    private func navigateToLogin() -> FlowContributors {
        let loginFlow = LoginFlow()

        // mainFlow 생성 시 root 를 window에 연결함.
        Flows.use(loginFlow, when: .created) { (root) in
            self.window.rootViewController = root
        }

        let nextStep = OneStepper(withSingleStep: AppStep.loginIsRequired)

        return .one(flowContributor: .contribute(withNextPresentable: loginFlow, withNextStepper: nextStep))
    }

    

    
    
}
