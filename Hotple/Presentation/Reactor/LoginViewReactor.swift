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
    
    var disposeBag = DisposeBag()
    
    var steps = PublishRelay<Step>()
    
    let initialState: State
    let kakaoUseCase: KakaoUseCase
    let naverUseCase: NaverUseCase
    
    init(kakaoUseCase: KakaoUseCase, naverUseCase: NaverUseCase) {
        Log.debug("LoginViewReactor init")
        self.initialState = State(userData: UserData(id: ""))
        self.kakaoUseCase = kakaoUseCase
        self.naverUseCase = naverUseCase
        
    }
    
    deinit {
        disposeBag = DisposeBag()
        Log.debug("LoginViewReactor deinit")
    }
    
    enum Action {
        case clickToKakao
        case clickToNaver
        case clickToTest
        case clickToSkip
    }
    
    enum Mutation {
        case loginKakao(Bool)
        case loginNaver(Bool)
        
        case setUserInfo(UserData)
        
        case setLoading(Bool)
//        case setNaver
        
    }
    
    struct State {
        var userData: UserData
        var isLoading: Bool = false
    }

    
    func mutate(action: Action) -> Observable<Mutation> {

        switch action {
        case .clickToKakao:
            Log.action("LoginViewReactor clickToKakao action excuting")
            
            return Observable.concat([
                Observable.just(Mutation.setLoading(true)),
                kakaoUseCase.login()
                    .map { isLogin in
                        return Mutation.loginKakao(isLogin)
                    }
                    .catchAndReturn(Mutation.loginKakao(false)),
                Observable.just(Mutation.setLoading(false))
            ])
            
//            return kakaoUseCase.login()
//                .map { isLogin in
//                    return Mutation.loginKakao(isLogin)
//                }
//                .catchAndReturn(Mutation.loginKakao(false))

            
        case .clickToNaver:
            Log.action("LoginViewReactor clickToNaver action excuting")
            
            return Observable.concat([
                Observable.just(Mutation.setLoading(true)),
                naverUseCase.login()
                    .map { isLogin in
                        return Mutation.loginNaver(isLogin)
                    }
                    .catchAndReturn( Mutation.loginNaver(false)),
                Observable.just(Mutation.setLoading(false))
            ])
            
//            return naverUseCase.login()
//                .map { isLogin in
//                    return Mutation.loginNaver(isLogin)
//                }
//                .catchAndReturn( Mutation.loginNaver(false))

            
        case .clickToSkip:
            Log.action("LoginViewReactor clickToSkip action excuting")
            
            self.steps.accept(AppStep.tabDashBoardIsRequired)
            
            return .never()
            
        case .clickToTest:
            if let loginType = UserDefaults.standard.string(forKey: UserDefaultKeys.LOGIN_TYPE) {
                print(loginType)
                switch loginType {
                case "naver":
                    print("naver 진행")
                    naverUseCase.logout()
                        .subscribe(
                            onNext: { isLogout in
                                print("isLogout naver: \(isLogout)")
                            }, onError: { error in
                                print("error:\(error)")
                            }, onCompleted: {
                                print("onCompleted")
                            }, onDisposed: {
                                print("onDisposed")
                            })
                        .disposed(by: disposeBag)
                case "kakao":
                    print("kakao 진행")
                    kakaoUseCase.logout()
                        .subscribe(
                            onNext: { isLogout in
                                print("isLogout Kakao: \(isLogout)")
                            }, onError: { error in
                                print("error:\(error)")
                            }, onCompleted: {
                                print("onCompleted")
                            }, onDisposed: {
                                print("onDisposed")
                            })
                        .disposed(by: disposeBag)
                        
                default:
                    break
                    
                }
            } else {
                print("로그인 되어있지 않음")
            }

            return .never()
            
            
 //            self.steps.accept(AppStep.tabDashBoardIsRequired)
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
                Log.action("LoginViewReactor loginKakao state fail")
                
            }
            
        case .loginNaver(let isLogin):
            if isLogin {
                Log.debug("확인삼아")
                self.steps.accept(AppStep.tabDashBoardIsRequired)
            } else {
                Log.action("LoginViewReactor loginNaver state fail")
                
            }
            
        case .setUserInfo(let userData):
            newState.userData = userData

        case .setLoading(let isLoading):
            newState.isLoading = isLoading
        }
        
        return newState
    }
    
    

    
}
