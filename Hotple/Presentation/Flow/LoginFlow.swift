//
//  LoginFlow.swift
//  Hotple
//
//  Created by SeongHoon Kim on 2023/02/01.
//

import Foundation
import RxFlow

class LoginFlow: Flow {
    
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
        print("LoginFlow deinit")
    }
    
    func navigate(to step: RxFlow.Step) -> RxFlow.FlowContributors {
        print("excuting LoginFlow navigate")
        guard let step = step as? AppStep else { return .none }
        
        
        switch step {
        // 자기 자신이 실행 될 경우
        case .loginIsRequired:
            return self.navigateToLogin()
            
        case .kakaoLoginIsRequired:
            return self.navigateToKakao()
            
        case .tabDashBoardIsRequired:
            return self.navigateToTabDashBoard()
            
//        case .mainDetailIsRequired:
//            return self.navigateToMainDetail()
//
//        // 홈 버튼 누를 경우
//        case .homeIsRequired:
//            // 자기자신의 flow를 끝낸 후 부모 flow로 돌아가 해당 step을 전달해줌
//            return .end(forwardToParentFlowWithStep: DemoStep.homeIsRequired)
            
        
            
        default:
            return .none
        }

        
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
    
    private func navigateToKakao() -> FlowContributors {
        return .none
    }
    
    
    private func navigateToTabDashBoard() -> FlowContributors {
        let tabDashBoardFlow = TabDashBoardFlow(rootViewController: self.rootViewController)

        
        return .one(flowContributor: .contribute(withNextPresentable: tabDashBoardFlow, withNextStepper: OneStepper(withSingleStep: AppStep.tabDashBoardIsRequired)))
    }
    
}
