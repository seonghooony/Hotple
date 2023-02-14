//
//  HomeTabViewReactor.swift
//  Hotple
//
//  Created by SeongHoon Kim on 2023/02/10.
//


import ReactorKit
import RxFlow
import RxCocoa

// ExampleViewController의 VM 과 같음
class HomeTabViewReactor: Reactor, Stepper {
    
    let disposeBag = DisposeBag()
    
    var steps = PublishRelay<Step>()
    
    let initialState: State

    init() {
        self.initialState = State()
    }
    
    deinit {
        print("HomeTabViewReactor deinit")
    }
    
    enum Action {
        case clickToTest
    }
    
    enum Mutation {

        
    }
    
    struct State {

    }

    
    func mutate(action: Action) -> Observable<Mutation> {
        switch action {
        case .clickToTest:
            self.steps.accept(AppStep.testIsRequired)
            return Observable.never()
        
        }
    }
    
    func reduce(state: State, mutation: Mutation) -> State {
        var newState = state
        
        
        switch mutation {
       

        }
        
        return newState
    }
    
    
    
}
