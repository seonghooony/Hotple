//
//  ProfileTabViewReactor.swift
//  Hotple
//
//  Created by SeongHoon Kim on 2023/02/10.
//


import ReactorKit
import RxFlow
import RxCocoa

// ExampleViewController의 VM 과 같음
class ProfileTabViewReactor: Reactor, Stepper {
    
    let disposeBag = DisposeBag()
    
    var steps = PublishRelay<Step>()
    
    let initialState: State
    let userUseCase: UserUseCase

    init(userUseCase: UserUseCase) {
        Log.debug("ProfileTabViewReactor init")
        self.initialState = State(userData: UserData(id: ""))
        self.userUseCase = userUseCase
    }
    
    deinit {
        Log.debug("ProfileTabViewReactor deinit")
    }
    
    enum Action {
        case loadView
        case clickToProfileSetting

    }
    
    enum Mutation {
        case setUserData(UserData?)
        case setLoading(Bool)
    }
    
    struct State {
        var userData: UserData
        var isLoading: Bool = false
        var showNeedLogin: Bool = false
    }

    
    func mutate(action: Action) -> Observable<Mutation> {
        switch action {
        case .loadView:
            Log.action("ProfileTabViewReactor loadView action excuting")
            
            return Observable.concat([
                Observable.just(Mutation.setLoading(true)),
                userUseCase.getUserInfo()
                    .delay(.seconds(1), scheduler: MainScheduler.instance)
                    .map { userData in
                        return Mutation.setUserData(userData)
                    }
                    .catchAndReturn(Mutation.setUserData(nil)),
                Observable.just(Mutation.setLoading(false))
            ])

        case .clickToProfileSetting:
            Log.action("ProfileTabViewReactor clickToProfileSetting action excuting")
            self.steps.accept(AppStep.profileSettingIsRequired)
            return Observable.never()
        
        }
    }
    
    func reduce(state: State, mutation: Mutation) -> State {
        var newState = state
        
        
        switch mutation {
        case .setUserData(let userData):
            Log.action("ProfileTabViewReactor setUserData state excuting")
            
            if userData == nil {
                newState.showNeedLogin = true
            } else {
                newState.userData = userData ?? UserData(id: "")
                newState.showNeedLogin = false
            }
            
        
        case .setLoading(let isLoading):
            newState.isLoading = isLoading
        }
        
        return newState
    }
    
    
    
}
