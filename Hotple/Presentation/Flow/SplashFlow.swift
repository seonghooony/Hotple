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
    
    let kakaoUseCase: KakaoUseCase
    let naverUseCase: NaverUseCase
    
    init() {
        let localRepository = LocalRepository()
        let firebaseRepository = FirebaseRepository()
        
        self.kakaoUseCase = KakaoUseCase(localRepository: localRepository, firebaseRepository: firebaseRepository, kakaoRepository: KakaoRepository())
        
        self.naverUseCase = NaverUseCase(localRepository: localRepository, firebaseRepository: firebaseRepository, naverRepository: NaverRepository())
    }
    
    deinit {
        print("SplashFlow deinit")
    }
    
    func navigate(to step: RxFlow.Step) -> RxFlow.FlowContributors {
        print("excuting SplashFlow navigate")
        guard let step = step as? AppStep else { return .none }
        
        
        switch step {
            
        // 자신이 실행 될 경우
        case .splashIsRequired:
            return self.navigateToSplash()
            
        // 자기 자신이 실행 될 경우
        case .loginIsRequired:
            return self.navigateToLogin()
            
        case .tabDashBoardIsRequired:
            return self.navigateToTabDashBoard()
            
            
        
            
        default:
            return .none
        }

        
    }
    
    private func navigateToSplash() -> FlowContributors {
        
        let splashViewReactor = SplashViewReactor(kakaoUseCase: kakaoUseCase, naverUseCase: naverUseCase)
        let splashViewController = SplashViewController(reactor: splashViewReactor)
        self.rootViewController.pushViewController(splashViewController, animated: true)
        
        print("navigateToSplash")
        print(self.rootViewController.viewControllers)
        
        return .one(flowContributor: .contribute(withNextPresentable: splashViewController, withNextStepper: splashViewReactor))
        
    }
    
    private func navigateToLogin() -> FlowContributors {
        
        let loginViewReactor = LoginViewReactor(kakaoUseCase: kakaoUseCase, naverUseCase: naverUseCase)
        let loginViewController = LoginViewController(reactor: loginViewReactor)
        self.rootViewController.pushViewController(loginViewController, animated: true)
        
        print("navigateToMain")
        print(self.rootViewController.viewControllers)
        
        return .one(flowContributor: .contribute(withNextPresentable: loginViewController, withNextStepper: loginViewReactor))
        
//        return .one(flowContributor: .contribute(withNext: viewController))
    }
    

    private func navigateToTabDashBoard() -> FlowContributors {
        let tabDashBoardFlow = TabDashBoardFlow(rootViewController: self.rootViewController)

        
        return .one(flowContributor: .contribute(withNextPresentable: tabDashBoardFlow, withNextStepper: OneStepper(withSingleStep: AppStep.tabDashBoardIsRequired)))
    }
    
}
