//
//  LoginFlow.swift
//  Hotple
//
//  Created by SeongHoon Kim on 2023/02/01.
//

import Foundation
import RxFlow

class LoginFlow: Flow {
    
    var rootViewController: UINavigationController
        
    var root: Presentable
    
    let kakaoUseCase: KakaoUseCase
    let naverUseCase: NaverUseCase
    
    init(rootViewController: UINavigationController) {
        Log.debug("LoginFlow init")
        
        self.root = rootViewController
        self.rootViewController = rootViewController
        
        let localRepository = LocalRepository()
        let firebaseRepository = FirebaseRepository()
        let kakaoRepository = KakaoRepository()
        let naverRepository = NaverRepository()
        
        self.kakaoUseCase = KakaoUseCase(localRepository: localRepository, firebaseRepository: firebaseRepository, kakaoRepository: kakaoRepository)
        self.naverUseCase = NaverUseCase(localRepository: localRepository, firebaseRepository: firebaseRepository, naverRepository: naverRepository)
    }
    
    deinit {
        Log.debug("LoginFlow deinit")
    }
    
    func navigate(to step: RxFlow.Step) -> RxFlow.FlowContributors {
        
        guard let step = step as? AppStep else { return .none }
        
        Log.flow("excuting LoginFlow navigate")
        
        switch step {
            
        // 자기 자신이 실행 될 경우
        case .loginIsRequired:
            return self.presentToLogin()
            
        case .tabDashBoardIsRequired:
            return self.backAndnavigateToTabDashBoard()

        default:
            return .none
        }

        
    }
    
    private func presentToLogin() -> FlowContributors {
        
        Log.flow("LoginFlow presentToLogin")
        
        let loginViewReactor = LoginViewReactor(kakaoUseCase: kakaoUseCase, naverUseCase: naverUseCase)
        let loginViewController = LoginViewController(reactor: loginViewReactor)

        loginViewController.modalPresentationStyle = .overFullScreen
        
        DispatchQueue.main.async {
            self.rootViewController.present(loginViewController, animated: true)
        }
        
        return .one(flowContributor: .contribute(withNextPresentable: loginViewController, withNextStepper: loginViewReactor))
    }
    

    
    private func backAndnavigateToTabDashBoard() -> FlowContributors {
        
        Log.flow("LoginFlow backAndnavigateToTabDashBoard")
        
        self.rootViewController.presentedViewController?.dismiss(animated: true)
        
        return .end(forwardToParentFlowWithStep: AppStep.tabDashBoardIsRequired)

    }
    
}
