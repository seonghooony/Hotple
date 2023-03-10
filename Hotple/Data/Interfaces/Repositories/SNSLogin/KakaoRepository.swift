//
//  KakaoRepository.swift
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

protocol KakaoRepositoryProtocol {
    func setLoginWithKakaoTalk() -> Observable<Bool>
    func setLoginWithKakaoAccount() -> Observable<Bool>
    func getUserInfo() -> Observable<Result<KakaoUserData, Error>>
    func setLogout() -> Observable<Bool>
    func setUnlink()
    
    func checkToken()
    func getTokenInfo()
    
}

final class KakaoRepository: KakaoRepositoryProtocol {
    let disposeBag = DisposeBag()
    
    func setLoginWithKakaoTalk() -> Observable<Bool> {
        return Observable.create { observer in
            if (UserApi.isKakaoTalkLoginAvailable()) {
                UserApi.shared.rx.loginWithKakaoTalk()
                    .subscribe(
                        onNext: { (oauthToken) in
                            print("loginWithKakaoTalk() Success.")
                            
                            print("oauthToken : \(oauthToken)")
                            
                            observer.onNext(true)
                            observer.onCompleted()
    
                        },
                        onError: { error in
                            print(error)
                            observer.onError(error)
                        }
                    )
                    .disposed(by: self.disposeBag)
            }
            
            return Disposables.create()
        }
        
    }
    
    func setLoginWithKakaoAccount() -> Observable<Bool> {
        return Observable.create { observer in
            UserApi.shared.rx.loginWithKakaoAccount()
                .subscribe(
                    onNext: { (oauthToken) in
                        print("loginWithKakaoAccount() Success.")
                        
                        print("oauthToken : \(oauthToken)")
                        
                        observer.onNext(true)
                        observer.onCompleted()
                        
                        
                    },
                    onError: { error in
                        print(error)
                        observer.onError(error)
                    }
                )
                .disposed(by: self.disposeBag)
            
            return Disposables.create()
        }
    }
    
    // ????????????
    func setLogout() -> Observable<Bool> {
        return Observable.create { observer in
            UserApi.shared.rx.logout()
                .subscribe(onCompleted:{
                    print("logout() success.")
                    
                    observer.onNext(true)
                    observer.onCompleted()
                    
                }, onError: {error in
                    print("logout() error.")
                    print(error)
                    observer.onError(error)
                })
                .disposed(by: self.disposeBag)
            
            return Disposables.create()
        }
    }
    
    // ???????????? ????????????
    func getUserInfo() -> Observable<Result<KakaoUserData, Error>> {

        return Observable<Result<KakaoUserData, Error>>.create { observer in
            UserApi.shared.rx.me()
                .subscribe(onSuccess:{ ( user ) in
                    print("me() success.")
//                    print(user)

                    var kakaoUserData = KakaoUserData(id: user.id ?? 1)
                    kakaoUserData.email = user.kakaoAccount?.email
                    kakaoUserData.name = user.kakaoAccount?.name
                    kakaoUserData.nickname = user.kakaoAccount?.profile?.nickname
                    kakaoUserData.birthday = user.kakaoAccount?.birthday
                    kakaoUserData.birthyear = user.kakaoAccount?.birthyear
                    if let birthyear = user.kakaoAccount?.birthyear,
                       let birthday = user.kakaoAccount?.birthday {
                        kakaoUserData.birth = birthyear + birthday
                    }
                    kakaoUserData.gender = user.kakaoAccount?.gender?.rawValue
                    kakaoUserData.phone = user.kakaoAccount?.phoneNumber
                    kakaoUserData.profileImgUrl = user.kakaoAccount?.profile?.profileImageUrl?.absoluteString

                    observer.onNext(.success(kakaoUserData))
                    
                    observer.onCompleted()

                }, onFailure: {error in
                    print("me() error.")
                    print(error)
                    observer.onError(error)

                })
                .disposed(by: self.disposeBag)



            return Disposables.create()
        }
        
    }
    
    // ?????? ?????? ?????? ??????
    func checkToken() {
        // Class member property
        let disposeBag = DisposeBag()
                            
        if (AuthApi.hasToken()) {
            UserApi.shared.rx.accessTokenInfo()
                .subscribe(onSuccess:{ (_) in
                    //?????? ????????? ?????? ??????(?????? ??? ?????? ?????????)
                }, onFailure: {error in
                    if let sdkError = error as? SdkError, sdkError.isInvalidTokenError() == true  {
                        //????????? ??????
                    }
                    else {
                        //?????? ??????
                    }
                })
                .disposed(by: disposeBag)
        }
        else {
            //????????? ??????
        }
    }
    
    // ?????? ?????? ????????????
    func getTokenInfo() {
        // ????????? ????????? ?????? ?????? ??????
        UserApi.shared.rx.accessTokenInfo()
            .subscribe(onSuccess:{ (accessTokenInfo) in
                print("accessTokenInfo() success.")

                //do something
                _ = accessTokenInfo
                
            }, onFailure: {error in
                print(error)
            })
            .disposed(by: disposeBag)
    }
    

    
    
    // ???????????? (????????? ?????? ??????)
    func setUnlink() {
        UserApi.shared.rx.unlink()
            .subscribe(onCompleted:{
                print("unlink() success.")
            }, onError: {error in
                print("unlink() error.")
                print(error)
            })
            .disposed(by: disposeBag)
    }
}
