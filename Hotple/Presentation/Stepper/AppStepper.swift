//
//  AppStepper.swift
//  Hotple
//
//  Created by SeongHoon Kim on 2023/02/01.
//

import Foundation
import RxFlow
import RxCocoa
import RxSwift
class AppStepper: Stepper {
    
    var steps = PublishRelay<Step>()
    private let disposeBag = DisposeBag()
    
    init() {
        
    }
    
    var initialStep: Step {
//        return AppStep.splashIsRequired
        return AppStep.loginIsRequired
    }
    
}
