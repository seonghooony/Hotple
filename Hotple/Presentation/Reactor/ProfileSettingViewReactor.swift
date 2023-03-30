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
        self.initialState = State()
        self.userUseCase = userUseCase
        self.kakaoUseCase = kakaoUseCase
        self.naverUseCase = naverUseCase
    }
    
    deinit {
        print("ProfileSettingViewReactor deinit")
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
            print("indexpath: \(indexPath.row)")
            print("title: \(normalMenu[indexPath.row].title)")
            
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
            self.steps.accept(AppStep.popFromProfileSetting)
            return Observable.never()
        
        }
    }
    
    func reduce(state: State, mutation: Mutation) -> State {
        var newState = state
        
        
        switch mutation {
        case .setNormalCell(let isLogin):

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
            print(loginType)
            switch loginType {
            case "naver":
                print("naver 진행")
                naverUseCase.logout()
                    .subscribe(
                        onNext: { [weak self] isLogout in
                            print("isLogout naver: \(isLogout)")
                            if isLogout {
                                self?.steps.accept(AppStep.logoutIsRequired)
                            }
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
                        onNext: { [weak self] isLogout in
                            print("isLogout Kakao: \(isLogout)")
                            if isLogout {
                                self?.steps.accept(AppStep.logoutIsRequired)
                            }
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
    }
    
    
}
