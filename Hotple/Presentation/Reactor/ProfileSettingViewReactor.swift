//
//  ProfileSettingViewReactor.swift
//  Hotple
//
//  Created by SeongHoon Kim on 2023/02/20.
//


import ReactorKit
import RxFlow
import RxCocoa

// ExampleViewController의 VM 과 같음
class ProfileSettingViewReactor: Reactor, Stepper {
    
    let disposeBag = DisposeBag()
    
    var steps = PublishRelay<Step>()
    
    let initialState: State

    var normalMenu = [
        ProfileSettingMenuData(title: "메뉴0")
//        ,ProfileSettingMenuData(title: "로그아웃")
    ]
    
    let userUseCase: UserUseCase
    let kakaoUseCase: KakaoUseCase
    let naverUseCase: NaverUseCase
    
    init(userUseCase: UserUseCase, kakaoUseCase: KakaoUseCase, naverUseCase: NaverUseCase) {
        Log.debug("ProfileSettingViewReactor init")
        
        self.initialState = State()
        self.userUseCase = userUseCase
        self.kakaoUseCase = kakaoUseCase
        self.naverUseCase = naverUseCase
    }
    
    deinit {
        Log.debug("ProfileSettingViewReactor deinit")
    }
    
    enum Action {
        case loadView
        case clickCell(IndexPath)
        case clickToBack
    }
    
    enum Mutation {
        case setNormalCell(Bool)
        
    }
    
    struct State {
        
        var normalSection = ProfileSettingSection.Model(
            model: .normal,
            items: []
        )

    }

    
    func mutate(action: Action) -> Observable<Mutation> {
        switch action {
        case .loadView:
            Log.action("ProfileSettingViewReactor loadView action excuting")
            return Observable.concat([
                
                userUseCase.getUserInfo()
                    .map { userData in
                        if userData != nil {
                            return Mutation.setNormalCell(true)
                        } else {
                            return Mutation.setNormalCell(false)
                        }
                        
                    }
                    .catchAndReturn(Mutation.setNormalCell(false))
                
            ])
            
            
        case .clickCell(let indexPath):
            Log.action("ProfileSettingViewReactor clickCell action excuting / indexpath: \(indexPath.row) / title: \(normalMenu[indexPath.row].title)")
            
            let settingName = normalMenu[indexPath.row].title
            
            switch settingName {
            case "로그아웃":
                logout()
                
            case "로그인":
                self.steps.accept(AppStep.logoutIsRequired)
                
            default:
                break
            }
            
            return .never()
            
        case .clickToBack:
            Log.action("ProfileSettingViewReactor clickToBack action excuting")
            self.steps.accept(AppStep.popFromProfileSetting)
            return Observable.never()
        
        }
    }
    
    func reduce(state: State, mutation: Mutation) -> State {
        var newState = state
        
        
        switch mutation {
        case .setNormalCell(let isLogin):
            Log.action("ProfileTabViewReactor setNormalCell state excuting")
            
            if isLogin {
                normalMenu.append(ProfileSettingMenuData(title: "로그아웃"))
            } else {
//                normalMenu.append(ProfileSettingMenuData(title: "로그인"))
            }
            
            let items = normalMenu.map { menuData in
                return ProfileSettingSection.ItemType.info(menuData)
            }
            
            let dataSource = ProfileSettingSection.Model(model: .normal, items: items)
            newState.normalSection = dataSource

        }
        
        return newState
    }
    
    
    func logout() {
        
        if let loginType = UserDefaults.standard.string(forKey: UserDefaultKeys.LOGIN_TYPE) {
            Log.network("ProfileSettingViewReactor logout func / loginType : \(loginType)")
            
            switch loginType {
            case "naver":
                naverUseCase.logout()
                    .subscribe(
                        onNext: { [weak self] isLogout in
                            if isLogout {
                                Log.network("Naver 3rd party logout success")
                                self?.steps.accept(AppStep.logoutIsRequired)
                            }
                        }, onError: { error in
                            Log.error("Naver 3rd party logout error")
                            Log.error("error:\(error)")
                            
                        }, onCompleted: {
                            Log.debug("Naver 3rd party logout onCompleted")
                        }, onDisposed: {
                            Log.debug("Naver 3rd party logout onDisposed")
                        })
                    .disposed(by: self.disposeBag)
                
            case "kakao":
                kakaoUseCase.logout()
                    .subscribe(
                        onNext: { [weak self] isLogout in
                            if isLogout {
                                Log.network("Kakao 3rd party logout success")
                                self?.steps.accept(AppStep.logoutIsRequired)
                            }
                        }, onError: { error in
                            Log.error("Kakao 3rd party logout error")
                            Log.error("error:\(error)")
                        }, onCompleted: {
                            Log.debug("Kakao 3rd party logout onCompleted")
                        }, onDisposed: {
                            Log.debug("Kakao 3rd party logout onDisposed")
                        })
                    .disposed(by: disposeBag)
                    
            default:
                break
            }
        } else {
            Log.debug("isn't login now")
        }
    }
    
    
}
