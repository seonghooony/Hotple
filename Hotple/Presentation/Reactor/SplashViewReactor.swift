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
        Log.debug("SplashViewReactor init")
        self.initialState = State()
        self.userUseCase = userUseCase
    }
    
    
    deinit {
        disposeBag = DisposeBag()
        Log.debug("SplashViewReactor deinit")
        
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
            Log.action("SplashViewReactor checkToLogin action excuting")
            
            userUseCase.getUserInfo()
                .subscribe { [weak self] (userData) in
                    Log.network("SplashViewReactor userUseCase.getUserInfo() Success")
                    
                    guard let self = self else { return }
                    
                    if userData != nil {
                        self.steps.accept(AppStep.tabDashBoardIsRequired)
                    } else {
                        print("loginIsRequired action 실행")
                        self.steps.accept(AppStep.loginIsRequired)
                    }
                    
                } onError: { error in
                    Log.error("SplashViewReactor userUseCase.getUserInfo() Error")
                    Log.error(error.localizedDescription)
                    
                } onCompleted: {
                    Log.debug("SplashViewReactor userUseCase.getUserInfo() Completed")
                    
                } onDisposed: {
                    Log.debug("SplashViewReactor userUseCase.getUserInfo() Disposed")
                    
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
