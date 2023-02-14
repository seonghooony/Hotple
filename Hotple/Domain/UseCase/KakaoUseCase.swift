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
    private let kakaoRepository: KakaoRepository
    
    let disposeBag = DisposeBag()
    
//    var userDataSubject = PublishSubject<KakaoUserData>()
    
    
    var localLoginSubject = PublishSubject<UserData>()
    var completedLoginSubject = PublishSubject<Bool>()
    
    init(localRepository: LocalRepository, kakaoRepository: KakaoRepository) {
        self.localRepository = localRepository
        self.kakaoRepository = kakaoRepository
    }
    
    
    func login() -> Observable<Bool> {
        localLoginSubject
            .subscribe { userData in
                self.localRepository.createUser(userData)
                    .subscribe { isCompleted in
                        print("완료 여부 : \(isCompleted)")
                        print("로컬 로그인 성공, 완료 이벤트 방출")
                        self.completedLoginSubject.onNext(isCompleted)
                    }
                    .disposed(by: self.disposeBag)
            }
            .disposed(by: disposeBag)
        
        if (UserApi.isKakaoTalkLoginAvailable()) {

            kakaoRepository.setLoginWithKakaoTalk()
                .subscribe { isLogin in
                    if isLogin {
                        self.getUserInfo()
                            .subscribe { userData in
                                print("카카오 서드파티 로그인 성공, 로컬 로그인 진행")
                                self.localLoginSubject.onNext(userData)
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
                                self.localLoginSubject.onNext(userData)
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
        return kakaoRepository.setLogout()
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
