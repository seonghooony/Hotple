//
//  NaverRepository.swift
//  Hotple
//
//  Created by SeongHoon Kim on 2023/02/07.
//

import Foundation

import NaverThirdPartyLogin

import RxSwift
import RxCocoa

import Alamofire
import RxAlamofire

protocol NaverRepositoryProtocol {
    func setLogin() -> Observable<Bool>
    func setLogout() -> Observable<Bool>
    func getUserInfo() -> Observable<Result<NaverUserData, Error>>
    func setUnlink()
}


class NaverRepository: NSObject, NaverThirdPartyLoginConnectionDelegate, NaverRepositoryProtocol {

    let disposeBag = DisposeBag()
    
    let loginInstance = NaverThirdPartyLoginConnection.getSharedInstance()
    
    private let loginSubject = PublishSubject<Bool>()
    private let logoutSubject = PublishSubject<Bool>()
    
    // 서드파티 로그인 및 회원가입 진행
    func setLogin() -> Observable<Bool> {
        loginInstance?.delegate = self
        loginInstance?.requestThirdPartyLogin()
        
        return loginSubject.asObservable().distinctUntilChanged()
    }
    
    // 로그아웃
    func setLogout() -> Observable<Bool> {
        loginInstance?.resetToken()
        
        return Observable.just(true)
    }
    
    // 서드파티 로그정보 삭제
    func setUnlink() {
        loginInstance?.requestDeleteToken()
    }
    
    // 유저 정보 요청
    func getUserInfo() -> Observable<Result<NaverUserData, Error>> {
        guard let isValidAccessToken = loginInstance?.isValidAccessTokenExpireTimeNow() else { return .never() }
        
        if !isValidAccessToken {
            debugPrint("Naver Token 정보 만료됨.")
            return .never()
        }

        guard let tokenType = loginInstance?.tokenType else { return .never() }
        guard let accessToken = loginInstance?.accessToken else { return .never() }
        let urlStr = "https://openapi.naver.com/v1/nid/me"
        let url = URL(string: urlStr)!
        
        let authorization = "\(tokenType) \(accessToken)"
        
        return Observable<Result<NaverUserData, Error>>.create { observer in
            
            let req = AF.request(url, method: .get, parameters: nil, encoding: JSONEncoding.default, headers: ["Authorization": authorization]).cacheResponse(using: ResponseCacher.doNotCache)
            
            req.responseDecodable(of: NaverLoginData.self) { response in
    
                switch response.result {
                case .success(let loginData):
                    let naverUserData = loginData.response
                    
                    observer.onNext(.success(naverUserData))
                    
                    observer.onCompleted()
                    
                case .failure(let error):
                    print("[NAVER ERROR] : \(error.localizedDescription)")
                    
                    observer.onError(error)
                }
                
    
    //            self.setLogout()
//                self.setUnlink()
            }
            
            return Disposables.create {
                req.cancel()
            }
        }
        
    }
    
    
    
    /* --------------------------Delegate Protocol Func--------------------------- */
    func oauth20ConnectionDidFinishRequestACTokenWithAuthCode() {
        print("[SUCCESS] : Success Naver Login")
//        getUserInfo().subscribe()
        loginSubject.onNext(true)
//        loginSubject.onCompleted()
    }
    
    func oauth20ConnectionDidFinishRequestACTokenWithRefreshToken() {
        print("[SUCCESS] : Success Naver Token Refresh")
//        getUserInfo().subscribe()
        loginSubject.onNext(true)
//        loginSubject.onCompleted()
    }
    
    func oauth20ConnectionDidFinishDeleteToken() {
        print("[SUCCESS] : Success Naver Token Delete")
        loginInstance?.requestDeleteToken()
    }
    
    func oauth20Connection(_ oauthConnection: NaverThirdPartyLoginConnection!, didFailWithError error: Error!) {
        print("[ERROR] : ", error.localizedDescription)
        
        loginSubject.onError(error)
//        loginSubject.onCompleted()
    }
    

    
}
    
