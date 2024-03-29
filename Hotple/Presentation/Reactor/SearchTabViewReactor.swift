//
//  SearchTabViewReactor.swift
//  Hotple
//
//  Created by SeongHoon Kim on 2023/02/10.
//


import ReactorKit
import RxFlow
import RxCocoa

// ExampleViewController의 VM 과 같음
class SearchTabViewReactor: Reactor, Stepper {
    
    let disposeBag = DisposeBag()
    
    var steps = PublishRelay<Step>()
    
    let initialState: State

    init() {
        Log.debug("SearchTabViewReactor init")
        self.initialState = State()
    }
    
    deinit {
        Log.debug("SearchTabViewReactor deinit")
    }
    
    enum Action {

    }
    
    enum Mutation {

        
    }
    
    struct State {

    }

    
    func mutate(action: Action) -> Observable<Mutation> {
        switch action {
            
        
        }
    }
    
    func reduce(state: State, mutation: Mutation) -> State {
        var newState = state
        
        
        switch mutation {
       

        }
        
        return newState
    }
    
    
    
}
