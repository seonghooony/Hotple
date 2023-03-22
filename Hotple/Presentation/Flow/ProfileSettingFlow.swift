//
//  ProfileSettingFlow.swift
//  Hotple
//
//  Created by SeongHoon Kim on 2023/02/20.
//

import Foundation
import UIKit
import RxFlow

class ProfileSettingFlow: Flow {
    
//    var root: Presentable {
//        return self.rootViewController
//    }
//
//    private let rootViewController = UINavigationController()
    
    var root: Presentable

    var rootViewController: UINavigationController
    
    private weak var windowNavigationController: UINavigationController?
    
    let userUseCase: UserUseCase
    let kakaoUseCase: KakaoUseCase
    let naverUseCase: NaverUseCase
    

    init(windowNavigationController: UINavigationController?, rootViewController: UINavigationController) {
        
        self.windowNavigationController = windowNavigationController
        
        self.root = rootViewController
        self.rootViewController = rootViewController
        
        let localRepository = LocalRepository()
        let firebaseRepository = FirebaseRepository()
        self.userUseCase = UserUseCase(localRepository: localRepository, firebaseRepository: firebaseRepository)
        self.kakaoUseCase = KakaoUseCase(localRepository: localRepository, firebaseRepository: firebaseRepository, kakaoRepository: KakaoRepository())
        self.naverUseCase = NaverUseCase(localRepository: localRepository, firebaseRepository: firebaseRepository, naverRepository: NaverRepository())
    }
    
    deinit {
        print("ProfileSettingFlow deinit")
    }
    
    func navigate(to step: Step) -> FlowContributors {
        print("excuting ProfileSettingFlow navigate")
        guard let step = step as? AppStep else { return . none }
        
        switch step {
            
        case .profileSettingIsRequired:
            return self.navigateToProfileSetting()
            
        case .popFromProfileSetting:
            return self.popFromProfileSetting()
            
        case .logoutIsRequired:
            return self.logout()
            
        default:
            return .none
        }
    }
    
    private func navigateToProfileSetting() -> FlowContributors {
       
        let profileSettingViewReactor = ProfileSettingViewReactor(userUseCase: userUseCase, kakaoUseCase: kakaoUseCase, naverUseCase: naverUseCase)
        let profileSettingViewController = ProfileSettingViewController(reactor: profileSettingViewReactor)
        
        profileSettingViewController.windowNavigationController = self.windowNavigationController
//        self.windowViewController.navigationBar.isHidden = false
        
        self.windowNavigationController?.pushViewController(profileSettingViewController, animated: true)
        

        
        return .one(flowContributor: .contribute(withNextPresentable: profileSettingViewController, withNextStepper: profileSettingViewReactor))
    }
    
    private func popFromProfileSetting() -> FlowContributors {
        
        self.windowNavigationController?.popViewController(animated: true)
        
        return .end(forwardToParentFlowWithStep: AppStep.popFromProfileSetting)
    }
    
    private func logout() -> FlowContributors {
        
        self.windowNavigationController?.popViewController(animated: true)
        
        return .end(forwardToParentFlowWithStep: AppStep.logoutIsRequired)
        
//        let loginFlow = LoginFlow(rootViewController: self.windowNavigationController)
//
//        let nextStep = OneStepper(withSingleStep: AppStep.loginIsRequired)
//
//        return .one(flowContributor: .contribute(withNextPresentable: loginFlow, withNextStepper: nextStep))
    }
    
}
