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


final class NaverRepository: NSObject, NaverThirdPartyLoginConnectionDelegate, NaverRepositoryProtocol {

    var disposeBag = DisposeBag()
    
    let loginInstance = NaverThirdPartyLoginConnection.getSharedInstance()
    
    private let loginSubject = PublishSubject<Bool>()
    private let logoutSubject = PublishSubject<Bool>()
    
    override init() {
        super.init()
        Log.debug("NaverRepository init")
    }
    
    deinit {
        disposeBag = DisposeBag()
        Log.debug("NaverRepository deinit")
    }
    
    // 서드파티 로그인 및 회원가입 진행
    func setLogin() -> Observable<Bool> {
        Log.network("NaverRepository setLogin")
        
        loginInstance?.delegate = self
        loginInstance?.requestThirdPartyLogin()
        
        return loginSubject.asObservable().distinctUntilChanged()
    }
    
    // 로그아웃
    func setLogout() -> Observable<Bool> {
        Log.network("NaverRepository setLogout")
        
        loginInstance?.resetToken()
        
        return Observable.just(true)
    }
    
    // 서드파티 로그정보 삭제
    func setUnlink() {
        loginInstance?.requestDeleteToken()
    }
    
    // 유저 정보 요청
    func getUserInfo() -> Observable<Result<NaverUserData, Error>> {
        Log.network("NaverRepository getUserInfo")
        
        guard let isValidAccessToken = loginInstance?.isValidAccessTokenExpireTimeNow() else { return .never() }
        
        if !isValidAccessToken {
            Log.error("Naver Token 정보 만료됨.")
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
                    Log.network("[NAVER LOGIN USERDATA GET SUCCESSFULLY]")
                    let naverUserData = loginData.response
                    
                    observer.onNext(.success(naverUserData))
                    
                    observer.onCompleted()
                    
                case .failure(let error):
                    Log.error("[NAVER ERROR] : \(error.localizedDescription)")
                    
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
        Log.network("[SUCCESS] : Success Naver Login")

        loginSubject.onNext(true)
    }
    
    func oauth20ConnectionDidFinishRequestACTokenWithRefreshToken() {
        Log.network("[SUCCESS] : Success Naver Token Refresh")

        loginSubject.onNext(true)
    }
    
    func oauth20ConnectionDidFinishDeleteToken() {
        Log.network("[SUCCESS] : Success Naver Token Delete")

        loginInstance?.requestDeleteToken()
    }
    
    func oauth20Connection(_ oauthConnection: NaverThirdPartyLoginConnection!, didFailWithError error: Error!) {
        Log.error("[ERROR] : ", error.localizedDescription)
        
        loginSubject.onError(error)
    }
    
}
    
