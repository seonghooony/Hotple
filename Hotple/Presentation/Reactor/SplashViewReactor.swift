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
    
    var disposeBag = DisposeBag()
    
    var steps = PublishRelay<Step>()
    
    let initialState: State
    
    let userUseCase: UserUseCase
    
    init(userUseCase: UserUseCase) {
        self.initialState = State()
        self.userUseCase = userUseCase
    }
    
    
    deinit {
        disposeBag = DisposeBag()
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
            print("checkToLogin action 실행")
            
            userUseCase.getUserInfo()
                .subscribe { userData in
                    
                    if userData != nil {
                        print("tabDashBoardIsRequired action 실행")
                        self.steps.accept(AppStep.tabDashBoardIsRequired)
                    } else {
                        print("loginIsRequired action 실행")
                        self.steps.accept(AppStep.loginIsRequired)
                    }
                } onError: { error in
                    print("SplashViewReactor checkLogin userUseCase Error")
                    print(error.localizedDescription)
                } onCompleted: {
                    print("SplashViewReactor checkLogin userUseCase Completed")
                } onDisposed: {
                    print("SplashViewReactor checkLogin userUseCase Disposed")
                }
                .disposed(by: self.disposeBag)

            
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
