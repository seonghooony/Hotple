//
//  LoginViewReactor.swift
//  Hotple
//
//  Created by SeongHoon Kim on 2023/02/01.
//

import ReactorKit
import RxFlow
import RxCocoa

// ExampleViewController의 VM 과 같음
class LoginViewReactor: Reactor, Stepper {
    
    let disposeBag = DisposeBag()
    
    var steps = PublishRelay<Step>()
    
    let initialState: State
    let kakaoUseCase: KakaoUseCase
    let naverUseCase: NaverUseCase
    
    init(kakaoUseCase: KakaoUseCase, naverUseCase: NaverUseCase) {
        self.initialState = State(userData: UserData(id: ""))
        self.kakaoUseCase = kakaoUseCase
        self.naverUseCase = naverUseCase
        
    }
    
    enum Action {
        case clickToKakao
        case clickToNaver
        case clickToTest
    }
    
    enum Mutation {
        case loginKakao(Bool)
        case loginNaver(Bool)
        
        case setUserInfo(UserData)
//        case setNaver
        
    }
    
    struct State {
        var userData: UserData
    }

    
    func mutate(action: Action) -> Observable<Mutation> {
        switch action {
        case .clickToKakao:
            
            
            
            return kakaoUseCase.login()
                .map { isLogin in
                    return Mutation.loginKakao(isLogin)
                }
                .catchAndReturn(Mutation.loginKakao(false))
            
//            return Observable.never()
            
        case .clickToNaver:
            print("로그인 여부")
            return naverUseCase.login()
                .map { isLogin in
                    return Mutation.loginNaver(isLogin)
                }
                .catchAndReturn( Mutation.loginNaver(false))
            
            
//            return Observable.never()
            
        case .clickToTest:
//            print(naverUseCase.logout())
            self.steps.accept(AppStep.tabDashBoardIsRequired)
            return .never()
            
            
//            return kakaoUseCase.getUserInfo()
//                            .map { userData in
//                                return Mutation.setUserInfo(userData)
//                            }
//                            .catchAndReturn(Mutation.setUserInfo(UserData(id: "")))
                    
            

        }
    }
    
    func reduce(state: State, mutation: Mutation) -> State {
        var newState = state
        
        
        switch mutation {
        case .loginKakao(let isLogin):
            if isLogin {
                self.steps.accept(AppStep.tabDashBoardIsRequired)
            } else {
                print("로그인 실패 알람?")
            }
            
        case .loginNaver(let isLogin):
            if isLogin {
                self.steps.accept(AppStep.tabDashBoardIsRequired)
            } else {
                print("로그인 실패 알람?")
            }
            
        case .setUserInfo(let userData):
            newState.userData = userData
                

        }
        
        return newState
    }
    
    
    deinit {
        print("LoginViewReactor deinit")
    }
}
