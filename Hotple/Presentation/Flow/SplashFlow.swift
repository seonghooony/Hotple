//
//  SplashFlow.swift
//  Hotple
//
//  Created by SeongHoon Kim on 2023/02/13.
//


import Foundation
import RxFlow

class SplashFlow: Flow {
    
    private lazy var rootViewController: UINavigationController = {
        let viewController = UINavigationController()
        return viewController
    }()
    
    var root: Presentable {
        return self.rootViewController
    }
    
    let userUseCase: UserUseCase

    
    init() {
        Log.debug("SplashFlow init")
        let localRepository = LocalRepository()
        let firebaseRepository = FirebaseRepository()
        
        self.userUseCase = UserUseCase(localRepository: localRepository, firebaseRepository: firebaseRepository)

    }
    
    deinit {
        Log.debug("SplashFlow deinit")
    }
    
    func navigate(to step: RxFlow.Step) -> RxFlow.FlowContributors {
        
        guard let step = step as? AppStep else { return .none }
        
        Log.flow("excuting SplashFlow navigate")
        
        switch step {
            
        // 자신이 실행 될 경우
        case .splashIsRequired:
            return self.navigateToSplash()
            
        // 자기 자신이 실행 될 경우
        case .loginIsRequired:
            return self.flowToLogin()
            
        case .tabDashBoardIsRequired:
            return self.flowToTabDashBoard()
            
        default:
            return .none
        }

        
    }
    
    private func navigateToSplash() -> FlowContributors {
        Log.flow("SplashFlow navigateToSplash")
        
        let splashViewReactor = SplashViewReactor(userUseCase: userUseCase)
        let splashViewController = SplashViewController(reactor: splashViewReactor)
        self.rootViewController.pushViewController(splashViewController, animated: true)
        
        return .one(flowContributor: .contribute(withNextPresentable: splashViewController, withNextStepper: splashViewReactor))
        
    }
    
    private func flowToLogin() -> FlowContributors {
        Log.flow("SplashFlow flowToLogin")
        
        let loginFlow = LoginFlow(rootViewController: self.rootViewController)
        let nextStep = OneStepper(withSingleStep: AppStep.loginIsRequired)

        return .one(flowContributor: .contribute(withNextPresentable: loginFlow, withNextStepper: nextStep))
    }
    

    private func flowToTabDashBoard() -> FlowContributors {
        Log.flow("SplashFlow flowToTabDashBoard")
        
        let tabDashBoardFlow = TabDashBoardFlow(rootViewController: self.rootViewController)

        return .one(flowContributor: .contribute(withNextPresentable: tabDashBoardFlow, withNextStepper: OneStepper(withSingleStep: AppStep.tabDashBoardIsRequired)))
    }
    
}
