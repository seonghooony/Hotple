//
//  MapTabViewReator.swift
//  Hotple
//
//  Created by SeongHoon Kim on 2023/02/10.
//


import ReactorKit
import RxFlow
import RxCocoa
import NMapsMap

// ExampleViewController의 VM 과 같음
class MapTabViewReactor: Reactor, Stepper {
    
    let disposeBag = DisposeBag()
    
    var steps = PublishRelay<Step>()
    
    let initialState: State
    let mapUseCase: MapUseCase
    
    
    init(mapUseCase: MapUseCase) {
        Log.debug("MapTabViewReactor init")
        self.initialState = State()
        self.mapUseCase = mapUseCase
    }
    
    deinit {
        Log.debug("MapTabViewReactor deinit")
    }
    
    enum Action {
        case loadView
        case scrollMap
    }
    
    enum Mutation {
        case resetMarkers([NMFMarker])
        
    }
    
    struct State {
        var allMarkers: [NMFMarker] = []
    }

    
    func mutate(action: Action) -> Observable<Mutation> {
        switch action {
        case .loadView:
            Log.action("MapTabViewReactor loadView action excuting")
            let markers = mapUseCase.generateRandomMarker(size: 1000)
            return Observable.just(Mutation.resetMarkers(markers))
            
        case .scrollMap:
            Log.action("MapTabViewReactor scrollMap action excuting")
            let markers = mapUseCase.generateRandomMarker(size: 1000)
            return Observable.just(Mutation.resetMarkers(markers))
            
        }
    }
    
    func reduce(state: State, mutation: Mutation) -> State {
        var newState = state
        
        
        switch mutation {
        case .resetMarkers(let markers):
            Log.action("MapTabViewReactor resetMarkers state excuting(allMarkers: \(markers.count)개)")
            newState.allMarkers = markers

        }
        
        return newState
    }
    
    
    
}
