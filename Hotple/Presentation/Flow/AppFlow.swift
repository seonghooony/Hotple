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
        Log.debug("AppFlow init")
        self.window = window
    }
    
    deinit {
        Log.debug("AppFlow deinit")
    }
    
    func navigate(to step: RxFlow.Step) -> RxFlow.FlowContributors {
        
        guard let step = step as? AppStep else { return .none }
        
        Log.flow("excuting AppFlow navigate")
        
        switch step {
        // 스플래시 화면 이동
        case .splashIsRequired:
            return self.flowToSplash()
            
        default:
            return .none
            
        }
        
    }
    
    private func flowToSplash() -> FlowContributors {
        Log.flow("AppFlow flowToSplash")
        
        let splashFlow = SplashFlow()

        // mainFlow 생성 시 root 를 window에 연결함.
        Flows.use(splashFlow, when: .created) { (root) in
            self.window.rootViewController = root
        }

        let nextStep = OneStepper(withSingleStep: AppStep.splashIsRequired)

        return .one(flowContributor: .contribute(withNextPresentable: splashFlow, withNextStepper: nextStep))
    }
        
}
