//
//  AppStep.swift
//  Hotple
//
//  Created by SeongHoon Kim on 2023/02/01.
//


import Foundation
import RxFlow

enum AppStep: Step {
    
    // splash
    case splashIsRequired
    
    // login
    case loginIsRequired
    
    // login
    case kakaoLoginIsRequired
    case naverLoginIsRequired

    // tab dashboard
    case tabDashBoardIsRequired
    
    // Tab
    case homeTabIsRequired
    case searchTabIsRequired
    case mapTabIsRequired
    case feedTabIsRequired
    case profileTabIsRequired
    
    // test
    case testIsRequired
    
    // case expIsRequired(String) // 이런 식으로 step에 정보를 담아 전달할 수 있음.
}
