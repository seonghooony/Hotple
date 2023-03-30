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
    
    var disposeBag = DisposeBag()
    
//    var userDataSubject = PublishSubject<KakaoUserData>()
    

    
    init(localRepository: LocalRepository, firebaseRepository: FirebaseRepository, kakaoRepository: KakaoRepository) {
        print("KakaoUseCase init")
        
        self.localRepository = localRepository
        self.firebaseRepository = firebaseRepository
        self.kakaoRepository = kakaoRepository
    }
    
    deinit {
        disposeBag = DisposeBag()
        print("KakaoUseCase deinit")
    }
    
    // 회원가입 + 로그인 (카카오)
    func login() -> Observable<Bool> {
        
        let checkUserSubject = PublishSubject<UserData>()
        let pushUserSubject = PublishSubject<UserData>()
        let localLoginSubject = PublishSubject<UserData>()
        let completedLoginSubject = PublishSubject<Bool>()
        
        var kakaoAccountUserData: UserData?
        
        // firebase 에 등록된 유저인지 체크
        checkUserSubject
            .flatMapLatest { [weak self] userData -> Observable<UserData?> in
                guard let self = self else { return Observable.never() }
                
                return self.firebaseRepository.getUserData(userData: userData)
            }
            .subscribe { userData in
                // firebase 내 유저데이터가 있을 경우
                if let userData = userData {
                    print("유저 데이터 존재함")
                    localLoginSubject.onNext(userData)
                    localLoginSubject.onCompleted()
                    
                // firebase 내 유저데이터가 없을 경우
                } else {
                    if let kakaoAccountUserData = kakaoAccountUserData {
                        print("유저 데이터 존재하지 않음, 푸쉬 진행")
                        pushUserSubject.onNext(kakaoAccountUserData)
                        pushUserSubject.onCompleted()
                    } else {
                        print("카카오 데이트 존재 하지 않음, 푸쉬 불가능")
                        pushUserSubject.onCompleted()
                    }
                }
            } onError: { error in
                print(error.localizedDescription)
            } onCompleted: {
                print("")
            } onDisposed: {
                print("")
            }
            .disposed(by: self.disposeBag)
        
        // 내부 로컬 데이터에 유저정보 저장
        localLoginSubject
            .flatMapLatest { [weak self] userData -> Observable<Bool> in
                guard let self = self else { return Observable.never() }
                
                return self.localRepository.createUser(userData)
            }
            .subscribe { isCompleted in
                print("완료 여부 : \(isCompleted)")
                print("로컬 로그인 성공, 완료 이벤트 방출")
                completedLoginSubject.onNext(isCompleted)
                completedLoginSubject.onCompleted()
            } onError: { error in
                print(error.localizedDescription)
            } onCompleted: {
                print("")
            } onDisposed: {
                print("")
            }
            .disposed(by: self.disposeBag)

        // firebase에 유저 데이터 저장 (회원가입 진행)
        pushUserSubject
            .flatMapLatest { [weak self] userData -> Observable<Bool> in
                guard let self = self else { return Observable.never() }
                
                return self.firebaseRepository.setUserData(userData: userData)
            }
            .subscribe { isCompleted in
                if isCompleted {
                    if let kakaoAccountUserData = kakaoAccountUserData {
                        print("유저 데이터 푸쉬 진행 성공")
                        localLoginSubject.onNext(kakaoAccountUserData)
                        localLoginSubject.onCompleted()
                    }
                    
                }
            } onError: { error in
                print(error.localizedDescription)
            } onCompleted: {
                print("")
            } onDisposed: {
                print("")
            }
            .disposed(by: self.disposeBag)

        /* 이벤트 발생 부분 */
        // 카카오톡 앱과 연동 가능 여부 -> 카카오 로그인 진행 후 id 얻기
        if (UserApi.isKakaoTalkLoginAvailable()) {

            kakaoRepository.setLoginWithKakaoAccount()
                .filter { $0 == true }
                .flatMapLatest { [weak self] _ -> Observable<UserData> in
                    guard let self = self else { return Observable.never() }
                    
                    return self.getUserInfo()
                }
                .subscribe { userData in
                    print("카카오 서드파티 로그인 성공, 로컬 로그인 진행")
                    kakaoAccountUserData = userData
                    checkUserSubject.onNext(userData)
                    checkUserSubject.onCompleted()
                }
                .disposed(by: self.disposeBag)
            

        } else {
            kakaoRepository.setLoginWithKakaoAccount()
                .filter { $0 == true }
                .flatMapLatest { [weak self] _ -> Observable<UserData> in
                    guard let self = self else { return Observable.never() }
                    
                    return self.getUserInfo()
                }
                .subscribe { userData in
                    print("카카오 서드파티 로그인 성공, 로컬 로그인 진행")
                    kakaoAccountUserData = userData
                    checkUserSubject.onNext(userData)
                    checkUserSubject.onCompleted()
                }
                .disposed(by: self.disposeBag)
            
        }

        return completedLoginSubject.asObservable()
    }
    
    func logout() -> Observable<Bool> {
        return Observable.zip(localRepository.deleteUser(), kakaoRepository.setLogout())
            .map { (local, kakao) in
                if local && kakao {
                    return true
                } else {
                    return false
                }
            }

        
    }
    
    func getUserInfo() -> Observable<UserData> {
        
        return self.kakaoRepository.getUserInfo()
            .flatMapLatest { result -> Observable<UserData> in
                
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
                    
                    return Observable.just(userData)
                    
                    //                    print(kakaoUserData.id)
                    //                    print(kakaoUserData.name)
                    //                    print(kakaoUserData.nickname)
                    //                    print(kakaoUserData.email)
                    
                case .failure(let error):
                    debugPrint(error.localizedDescription)
                    return Observable.error(error)
                }
            }
    }
    
}
