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

    
    private weak var windowNavigationController: UINavigationController?
    
    let userUseCase: UserUseCase
    let kakaoUseCase: KakaoUseCase
    let naverUseCase: NaverUseCase
    

    init(windowNavigationController: UINavigationController?) {
        Log.debug("ProfileSettingFlow init")
        
        self.windowNavigationController = windowNavigationController
        
        self.root = windowNavigationController!

        let localRepository = LocalRepository()
        let firebaseRepository = FirebaseRepository()
        let kakaoRepository = KakaoRepository()
        let naverRepository = NaverRepository()
        
        self.userUseCase = UserUseCase(localRepository: localRepository, firebaseRepository: firebaseRepository)
        self.kakaoUseCase = KakaoUseCase(localRepository: localRepository, firebaseRepository: firebaseRepository, kakaoRepository: kakaoRepository)
        self.naverUseCase = NaverUseCase(localRepository: localRepository, firebaseRepository: firebaseRepository, naverRepository: naverRepository)

    }
    
    deinit {
        Log.debug("ProfileSettingFlow deinit")
    }
    
    func navigate(to step: Step) -> FlowContributors {
        
        guard let step = step as? AppStep else { return . none }
        
        Log.flow("excuting ProfileSettingFlow navigate")
        
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
        
        Log.flow("ProfileSettingFlow navigateToProfileSetting")
       
        let profileSettingViewReactor = ProfileSettingViewReactor(userUseCase: userUseCase, kakaoUseCase: kakaoUseCase, naverUseCase: naverUseCase)
        let profileSettingViewController = ProfileSettingViewController(reactor: profileSettingViewReactor)
        
        profileSettingViewController.windowNavigationController = self.windowNavigationController
//        self.windowViewController.navigationBar.isHidden = false
        
        self.windowNavigationController?.pushViewController(profileSettingViewController, animated: true)
        

        
        return .one(flowContributor: .contribute(withNextPresentable: profileSettingViewController, withNextStepper: profileSettingViewReactor))
    }
    
    private func popFromProfileSetting() -> FlowContributors {
        
        Log.flow("ProfileSettingFlow popFromProfileSetting")
        
        self.windowNavigationController?.popViewController(animated: true)
        
        return .end(forwardToParentFlowWithStep: AppStep.popFromProfileSetting)
    }
    
    private func logout() -> FlowContributors {
        
        Log.flow("ProfileSettingFlow logout")
        
        self.windowNavigationController?.popViewController(animated: true)
        
        return .end(forwardToParentFlowWithStep: AppStep.none)
        
//        return .end(forwardToParentFlowWithStep: AppStep.logoutIsRequired)
        
//        let loginFlow = LoginFlow(rootViewController: self.windowNavigationController)
//
//        let nextStep = OneStepper(withSingleStep: AppStep.loginIsRequired)
//
//        return .one(flowContributor: .contribute(withNextPresentable: loginFlow, withNextStepper: nextStep))
    }
    
}
