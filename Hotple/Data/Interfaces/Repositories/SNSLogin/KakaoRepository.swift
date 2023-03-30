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
    var disposeBag = DisposeBag()
    
    deinit {
        disposeBag = DisposeBag()
        Log.debug("KakaoRepository deinit")
    }
    
    func setLoginWithKakaoTalk() -> Observable<Bool> {
        if (UserApi.isKakaoTalkLoginAvailable()) {
            return UserApi.shared.rx.loginWithKakaoTalk()
                .map { (oauthToken) in
                    Log.network("kakaoRepo loginWithKakaoTalk() Success.")
                    Log.network("oauthToken : \(oauthToken)")
                    
                    return true
                }
            
        } else {
            return Observable.just(false)
        }

        
    }
    
    func setLoginWithKakaoAccount() -> Observable<Bool> {
        
        return UserApi.shared.rx.loginWithKakaoAccount()
            .map { (oauthToken) in
                Log.network("kakaoRepo loginWithKakaoTalk() Success.")
                Log.network("oauthToken : \(oauthToken)")
                
                return true
            }
                
    }
    
    // 로그아웃
    func setLogout() -> Observable<Bool> {
        
        return Observable.create { [weak self] observer in
            
            guard let self = self else {
                observer.onCompleted()
                return Disposables.create()
            }
            
            UserApi.shared.rx.logout()
                .subscribe(onCompleted:{
                    Log.network("kakaoRepo logout() success.")
                    
                    observer.onNext(true)
                    observer.onCompleted()
                    
                }, onError: {error in
                    Log.error("kakaoRepo logout() error.")
                    Log.error(error)
                    
                    observer.onError(error)
                })
                .disposed(by: self.disposeBag)
            
            return Disposables.create()
        }
    }
    
    // 회원정보 불러오기
    func getUserInfo() -> Observable<Result<KakaoUserData, Error>> {

        return Observable<Result<KakaoUserData, Error>>.create { [weak self] observer in
            
            guard let self = self else {
                observer.onCompleted()
                return Disposables.create()
            }
            
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
    
    // 토큰 존재 여부 확인
    func checkToken() {
        // Class member property
        let disposeBag = DisposeBag()
                            
        if (AuthApi.hasToken()) {
            UserApi.shared.rx.accessTokenInfo()
                .subscribe(onSuccess:{ (_) in
                    //토큰 유효성 체크 성공(필요 시 토큰 갱신됨)
                }, onFailure: {error in
                    if let sdkError = error as? SdkError, sdkError.isInvalidTokenError() == true  {
                        //로그인 필요
                    }
                    else {
                        //기타 에러
                    }
                })
                .disposed(by: disposeBag)
        }
        else {
            //로그인 필요
        }
    }
    
    // 토큰 정보 불러오기
    func getTokenInfo() {
        // 사용자 액세스 토큰 정보 조회
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
    

    
    
    // 회원탈퇴 (앱과의 연결 해제)
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
