//
//  KakaoLoginUseCase.swift
//  Hotple
//
//  Created by SeongHoon Kim on 2023/02/03.
//

import Foundation

import RxKakaoSDKCommon
import KakaoSDKCommon
import RxKakaoSDKAuth
import KakaoSDKAuth
import RxKakaoSDKUser
import KakaoSDKUser

import RxSwift
import RxCocoa

protocol KakaoUseCaseProtocol {
    func login() -> Observable<Bool>
    func logout() -> Observable<Bool>
    func getUserInfo() -> Observable<UserData>
}

final class KakaoUseCase: KakaoUseCaseProtocol {
    private let localRepository: LocalRepository
    private let firebaseRepository: FirebaseRepository
    private let kakaoRepository: KakaoRepository
    
    let disposeBag = DisposeBag()
    
//    var userDataSubject = PublishSubject<KakaoUserData>()
    

    
    init(localRepository: LocalRepository, firebaseRepository: FirebaseRepository, kakaoRepository: KakaoRepository) {
        self.localRepository = localRepository
        self.firebaseRepository = firebaseRepository
        self.kakaoRepository = kakaoRepository
    }
    
    // 회원가입 + 로그인 (카카오)
    func login() -> Observable<Bool> {
        
        var checkUserSubject = PublishSubject<UserData>()
        var pushUserSubject = PublishSubject<UserData>()
        var localLoginSubject = PublishSubject<UserData>()
        var completedLoginSubject = PublishSubject<Bool>()
        
        // 로컬 단에 유저데이터 넣기
        localLoginSubject
            .subscribe { userData in
                self.localRepository.createUser(userData)
                    .subscribe { isCompleted in
                        print("완료 여부 : \(isCompleted)")
                        print("로컬 로그인 성공, 완료 이벤트 방출")
                        completedLoginSubject.onNext(isCompleted)
                    }
                    .disposed(by: self.disposeBag)
            }
            .disposed(by: disposeBag)
        
        // 회원가입 진행
        pushUserSubject
            .subscribe { userData in
                self.firebaseRepository.setUserData(userData: userData)
                    .subscribe { result in
                        if result {
                            print("푸쉬 진행 성공")
                            localLoginSubject.onNext(userData)
                        }
                    }
                    .disposed(by: self.disposeBag)
            }
            .disposed(by: disposeBag)
        
        // 회원 여부 확인
        checkUserSubject
            .subscribe { userData in
                self.firebaseRepository.getUserData(userData: userData)
                    .subscribe { userDataF in
                        if let userDataF = userDataF {
                            print("유저 존재함")
                            localLoginSubject.onNext(userDataF)
                        } else {
                            print("유저 존재하지 않음, 푸쉬 진행")
                            pushUserSubject.onNext(userData)
                        }
                        
                    }
                    .disposed(by: self.disposeBag)

            }
            .disposed(by: disposeBag)
        
        // 카카오 로그인 진행 후 id 얻기
        if (UserApi.isKakaoTalkLoginAvailable()) {

            kakaoRepository.setLoginWithKakaoTalk()
                .subscribe { isLogin in
                    if isLogin {
                        self.getUserInfo()
                            .subscribe { userData in
                                print("카카오 서드파티 로그인 성공, 로컬 로그인 진행")
                                checkUserSubject.onNext(userData)
                            }
                            .disposed(by: self.disposeBag)
                    }
                    
                } onError: { error in
                    print("kakaoRepository setLoginWithKakaoTalk onError: \(error)")
                } onCompleted: {
                    print("kakaoRepository setLoginWithKakaoTalk onCompleted")
                }
                .disposed(by: disposeBag)

            
            
//            return kakaoRepository.setLoginWithKakaoTalk()
                
        } else {
            kakaoRepository.setLoginWithKakaoAccount()
                .subscribe { isLogin in
                    if isLogin {
                        self.getUserInfo()
                            .subscribe { userData in
                                print("카카오 서드파티 로그인 성공, 로컬 로그인 진행")
                                checkUserSubject.onNext(userData)
                            }
                            .disposed(by: self.disposeBag)
                    }
                    
                } onError: { error in
                    print("kakaoRepository setLoginWithKakaoAccount onError: \(error)")
                } onCompleted: {
                    print("kakaoRepository setLoginWithKakaoAccount onCompleted")
                }
                .disposed(by: disposeBag)
        }

        return completedLoginSubject.asObservable()
    }
    
    func logout() -> Observable<Bool> {
        return Observable.combineLatest(localRepository.deleteUser(), kakaoRepository.setLogout())
            .map { (local, kakao) in
                if local && kakao {
                    return true
                } else {
                    return false
                }
            }
        
    }
    
    func getUserInfo() -> Observable<UserData> {
        return Observable.create { observer in
            
            self.kakaoRepository.getUserInfo()
                .subscribe {  result in
                    switch result {
                    case .success(let kakaoUserData):
                        
                        var userData = UserData(id: String(kakaoUserData.id))
                        userData.nickname = kakaoUserData.nickname
                        userData.email = kakaoUserData.email
                        userData.name = kakaoUserData.name
                        userData.birth = kakaoUserData.birth
                        if let birthyear = kakaoUserData.birthyear,
                           let birthday = kakaoUserData.birthday {
                            userData.birth = birthyear + birthday
                        }
                        userData.gender = kakaoUserData.gender
                        userData.profileImgUrl = kakaoUserData.profileImgUrl
                        userData.phone = kakaoUserData.phone
                        userData.snsType = "kakao"
                        
                        observer.onNext(userData)
                        observer.onCompleted()
//                        self?.userDataSubject.onNext(kakaoUserData)
//                        print(kakaoUserData.id)
    //                    print(kakaoUserData.name)
    //                    print(kakaoUserData.nickname)
    //                    print(kakaoUserData.email)

                    case .failure(let error):
                        debugPrint(error.localizedDescription)
                        observer.onError(error)

                    }
                } onError: { error in
                    debugPrint("@@@@")
                    debugPrint(error.localizedDescription)
                    observer.onError(error)
                } onCompleted: {
                    debugPrint("kakao getUserInfo onCompleted")
                } onDisposed: {
                    debugPrint("kakao getUserInfo onDisposed")
                }
                .disposed(by: self.disposeBag)
            
            return Disposables.create()
        }
        
    }
    
}
