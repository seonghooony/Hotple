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
        case clickToLogin

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
                    .delay(.milliseconds(300), scheduler: MainScheduler.instance)
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
            
        case .clickToLogin:
            Log.action("ProfileTabViewReactor clickToLogin action excuting")
            userUseCase.getUserInfo()
                .subscribe { [weak self] (userData) in
                    Log.network("ProfileTabViewReactor userUseCase.getUserInfo() Success")
                    
                    guard let self = self else { return }
                    
                    if userData == nil {
                        Log.action("ProfileTabViewReactor action excuting")
                        self.steps.accept(AppStep.loginIsRequired)
                    }
                    
                } onError: { error in
                    Log.error("ProfileTabViewReactor userUseCase.getUserInfo() Error")
                    Log.error(error.localizedDescription)
                    
                } onCompleted: {
                    Log.debug("ProfileTabViewReactor userUseCase.getUserInfo() Completed")
                    
                } onDisposed: {
                    Log.debug("ProfileTabViewReactor userUseCase.getUserInfo() Disposed")
                    
                }
                .disposed(by: self.disposeBag)

            return Observable.never()
        
        }
    }
    
    func reduce(state: State, mutation: Mutation) -> State {
        var newState = state
        
        
        switch mutation {
        case .setUserData(let userData):
            Log.action("ProfileTabViewReactor setUserData state excuting")
            
            if let userData = userData {
                newState.userData = userData
                newState.showNeedLogin = false
            } else {
                newState.userData = UserData(id: "")
                newState.showNeedLogin = true
            }
            
        case .setLoading(let isLoading):
            newState.isLoading = isLoading
        }
        
        return newState
    }
    
    
    
}
