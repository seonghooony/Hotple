//
//  TabDashBoardViewReactor.swift
//  Hotple
//
//  Created by SeongHoon Kim on 2023/03/29.
//

import ReactorKit
import RxFlow
import RxCocoa

// ExampleViewController의 VM 과 같음
class TabDashBoardViewReactor: Reactor, Stepper {
    
    let disposeBag = DisposeBag()
    
    var steps = PublishRelay<Step>()
    
    let initialState: State

    init() {
        self.initialState = State()
    }
    
    deinit {
        print("TabDashBoardViewReactor deinit")
    }
    
    enum Action {

    }
    
    enum Mutation {

        
    }
    
    struct State {

    }

    
    func mutate(action: Action) -> Observable<Mutation> {
        switch action {
        
        default:
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
