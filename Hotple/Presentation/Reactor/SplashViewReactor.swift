//
//  SplashViewReactor.swift
//  Hotple
//
//  Created by SeongHoon Kim on 2023/02/13.
//


import ReactorKit
import RxFlow
import RxCocoa

// ExampleViewController의 VM 과 같음
class SplashViewReactor: Reactor, Stepper {
    
    let disposeBag = DisposeBag()
    
    var steps = PublishRelay<Step>()
    
    let initialState: State
    let kakaoUseCase: KakaoUseCase
    let naverUseCase: NaverUseCase
    
    init(kakaoUseCase: KakaoUseCase, naverUseCase: NaverUseCase) {
        self.initialState = State()
        self.kakaoUseCase = kakaoUseCase
        self.naverUseCase = naverUseCase
        
    }
    
    deinit {
        print("SplashViewReactor deinit")
    }
    
    enum Action {
        case checkToLogin

    }
    
    enum Mutation {
        

        
    }
    
    struct State {

    }

    
    func mutate(action: Action) -> Observable<Mutation> {
        switch action {
        case .checkToLogin:
            if let userId = UserDefaults.standard.string(forKey: UserDefaultKeys.USER_ID),
               let loginType = UserDefaults.standard.string(forKey: UserDefaultKeys.LOGIN_TYPE) {
                self.steps.accept(AppStep.tabDashBoardIsRequired)
                
            } else {
                self.steps.accept(AppStep.loginIsRequired)
            }
            return .never()
            
        

        }
    }
    
    func reduce(state: State, mutation: Mutation) -> State {
        var newState = state
        
        
        switch mutation {
        

        }
        
        return newState
    }
    
    

}
