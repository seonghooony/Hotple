//
//  ProfileTabFlow.swift
//  Hotple
//
//  Created by SeongHoon Kim on 2023/02/10.
//

import Foundation
import RxFlow

class ProfileTabFlow: Flow {
    
    var root: Presentable {
        return self.rootViewController
    }
    
    private let rootViewController = UINavigationController()
    
    private weak var windowNavigationController: UINavigationController?
    

    let userUseCase: UserUseCase
    
    init(windowNavigationController: UINavigationController) {
        Log.debug("ProfileTabFlow init")
        
        self.windowNavigationController = windowNavigationController
        
        let localRepository = LocalRepository()
        let firebaseRepository = FirebaseRepository()
        self.userUseCase = UserUseCase(localRepository: localRepository, firebaseRepository: firebaseRepository)

    }
    
    deinit {
        Log.debug("ProfileTabFlow deinit")
    }
    
    func navigate(to step: Step) -> FlowContributors {
        
        guard let step = step as? AppStep else { return . none }
        
        Log.flow("excuting ProfileTabFlow navigate")
        
        switch step {
            
        case .profileTabIsRequired:
            return self.navigateToProfileTab()
            
        case .profileSettingIsRequired:
            // 안쪽 네비게이션에서 푸쉬
            return flowToProfileSetting()
            
//        case .logoutIsRequired:
//            return logout()
            // 바깥 네비게이션에서 푸쉬
//            return .one(flowContributor: .forwardToParentFlow(withStep: AppStep.profileSettingIsRequired))
            
        default:
            return .none
        }
    }
    
    private func navigateToProfileTab() -> FlowContributors {
        Log.flow("ProfileTabFlow navigateToProfileTab")
        
        let profileTabViewReactor = ProfileTabViewReactor(userUseCase: self.userUseCase)
        let profileTabViewController = ProfileTabViewController(reactor: profileTabViewReactor)
        profileTabViewController.windowNavigationController = windowNavigationController
        self.rootViewController.navigationBar.isHidden = true
        self.rootViewController.pushViewController(profileTabViewController, animated: false)
    
        return .one(flowContributor: .contribute(withNextPresentable: profileTabViewController, withNextStepper: profileTabViewReactor))
    }
    
    private func flowToProfileSetting() -> FlowContributors {
        
        Log.flow("ProfileTabFlow flowToProfileSetting")
        
        let profileSettingFlow = ProfileSettingFlow(windowNavigationController: windowNavigationController)

        let nextStep = OneStepper(withSingleStep: AppStep.profileSettingIsRequired)

        return .one(flowContributor: .contribute(withNextPresentable: profileSettingFlow, withNextStepper: nextStep))
    }
    
//    private func logout() -> FlowContributors {
//        print("profiletabflow logout")
////        self.windowNavigationController?.popViewController(animated: true)
////        self.rootViewController.popViewController(animated: true)
//        
//        return .end(forwardToParentFlowWithStep: AppStep.logoutIsRequired)
//        
//    }
    
}
