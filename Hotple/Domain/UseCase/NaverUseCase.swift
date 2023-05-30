//
//  NaverLoginUseCase.swift
//  Hotple
//
//  Created by SeongHoon Kim on 2023/02/07.
//

import Foundation

import RxSwift
import RxCocoa

protocol NaverUseCaseProtocol {
    func login() -> Observable<Bool>
    func logout() -> Observable<Bool>
    func getUserInfo() -> Observable<UserData>
}

final class NaverUseCase: NaverUseCaseProtocol {
    private let localRepository: LocalRepository
    private let firebaseRepository: FirebaseRepository
    private let naverRepository: NaverRepository
    
    var disposeBag = DisposeBag()
    

    
    init(localRepository: LocalRepository, firebaseRepository: FirebaseRepository, naverRepository: NaverRepository) {
        Log.debug("NaverUseCase init")
        self.localRepository = localRepository
        self.firebaseRepository = firebaseRepository
        self.naverRepository = naverRepository
    }
    
    deinit {
        disposeBag = DisposeBag()
        Log.debug("NaverUseCase deinit")
    }
    
    func login() -> Observable<Bool> {
        
        let checkUserSubject = PublishSubject<UserData>()
        let pushUserSubject = PublishSubject<UserData>()
        let localLoginSubject = PublishSubject<UserData>()
        let completedLoginSubject = PublishSubject<Bool>()
        
        var naverAccountUserData: UserData?
        
        // firebase 에 등록된 유저인지 체크
        checkUserSubject
            .flatMapLatest { [weak self] userData -> Observable<UserData?> in
                guard let self = self else { return Observable.never() }
                
                return self.firebaseRepository.getUserData(userData: userData)
            }
            .subscribe { userData in
                // firebase 내 유저데이터가 있을 경우
                if let userData = userData {
                    Log.network("NaverUseCase Login : 유저 데이터 존재함")
                    localLoginSubject.onNext(userData)
                    localLoginSubject.onCompleted()
                    
                // firebase 내 유저데이터가 없을 경우
                } else {
                    if let naverAccountUserData = naverAccountUserData {
                        Log.network("NaverUseCase Login : 유저 데이터 존재하지 않음, 푸쉬 진행")
                        pushUserSubject.onNext(naverAccountUserData)
                        pushUserSubject.onCompleted()
                    } else {
                        Log.network("NaverUseCase Login : 카카오 데이트 존재 하지 않음, 푸쉬 불가능")
                        pushUserSubject.onCompleted()
                    }
                }
            } onError: { error in
                Log.network(error.localizedDescription)
            } onCompleted: {
                Log.network("NaverUseCase Login : checkUserSubject onCompleted")
            } onDisposed: {
                Log.network("NaverUseCase Login : checkUserSubject onDisposed")
            }
            .disposed(by: self.disposeBag)
        
        // 내부 로컬 데이터에 유저정보 저장
        localLoginSubject
            .flatMapLatest { [weak self] userData -> Observable<Bool> in
                guard let self = self else { return Observable.never() }
                
                return self.localRepository.createUser(userData)
            }
            .subscribe { isCompleted in
                Log.network("NaverUseCase Login : 완료 여부 : \(isCompleted)")
                Log.network("NaverUseCase Login : 로컬 로그인 성공, 완료 이벤트 방출")
                completedLoginSubject.onNext(isCompleted)
                completedLoginSubject.onCompleted()
            } onError: { error in
                Log.network(error.localizedDescription)
            } onCompleted: {
                Log.network("NaverUseCase Login : localLoginSubject onCompleted")
            } onDisposed: {
                Log.network("NaverUseCase Login : localLoginSubject onDisposed")
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
                    if let naverAccountUserData = naverAccountUserData {
                        Log.network("NaverUseCase Login : 유저 데이터 푸쉬 진행 성공")
                        localLoginSubject.onNext(naverAccountUserData)
                        localLoginSubject.onCompleted()
                    }
                    
                }
            } onError: { error in
                Log.network(error.localizedDescription)
            } onCompleted: {
                Log.network("NaverUseCase Login : pushUserSubject onCompleted")
            } onDisposed: {
                Log.network("NaverUseCase Login : pushUserSubject onDisposed")
            }
            .disposed(by: self.disposeBag)
        
        ///////////
        
//        // 로컬 단에 유저데이터 넣기
//        localLoginSubject
//            .subscribe { userData in
//                self.localRepository.createUser(userData)
//                    .subscribe { isCompleted in
//                        print("완료 여부 : \(isCompleted)")
//                        print("로컬 로그인 성공, 완료 이벤트 방출 (Local)")
//                        completedLoginSubject.onNext(isCompleted)
//                    }
//                    .disposed(by: self.disposeBag)
//            }
//            .disposed(by: disposeBag)
//
//        // 회원가입 진행
//        pushUserSubject
//            .subscribe { userData in
//                self.firebaseRepository.setUserData(userData: userData)
//                    .subscribe { result in
//                        if result {
//                            print("푸쉬 진행 성공 (Firestore)")
//                            localLoginSubject.onNext(userData)
//                        }
//                    }
//                    .disposed(by: self.disposeBag)
//            }
//            .disposed(by: disposeBag)
//
//        // 회원 여부 확인
//        checkUserSubject
//            .subscribe { userData in
//                self.firebaseRepository.getUserData(userData: userData)
//                    .subscribe { userDataF in
//                        if let userDataF = userDataF {
//                            print("유저 존재함 (Firestore)")
//                            localLoginSubject.onNext(userDataF)
//                        } else {
//                            print("유저 존재하지 않음, 푸쉬 진행 (Firestore)")
//                            pushUserSubject.onNext(userData)
//                        }
//
//                    }
//                    .disposed(by: self.disposeBag)
//
//            }
//            .disposed(by: disposeBag)
        
        naverRepository.setLogin()
            .filter { $0 == true }
            .flatMapLatest { [weak self] _ -> Observable<UserData> in
                guard let self = self else { return Observable.never() }
                
                return self.getUserInfo()
            }
            .subscribe { userData in
                Log.network("NaverUseCase Login : 네이버 서드파티 로그인 성공")
                naverAccountUserData = userData
                checkUserSubject.onNext(userData)
                checkUserSubject.onCompleted()
            }
            .disposed(by: self.disposeBag)
        
//        naverRepository.setLogin()
//            .subscribe { isLogin in
//                if isLogin {
//                    self.getUserInfo()
//                        .subscribe { userData in
//                            print("네이버 서드파티 로그인 성공")
//                            naverAccountUserData = userData
//                            checkUserSubject.onNext(userData)
//                        }
//                        .disposed(by: self.disposeBag)
//                }
//
//            } onError: { error in
//                print("naverRepository setLogin onError: \(error)")
//            } onCompleted: {
//                print("naverRepository setLogin onCompleted")
//            }
//            .disposed(by: disposeBag)
        
        return completedLoginSubject.asObservable()

    }
    
    func logout() -> Observable<Bool> {
        return Observable.combineLatest(localRepository.deleteUser(), naverRepository.setLogout())
            .map { (local, kakao) in
                if local && kakao {
                    return true
                } else {
                    return false
                }
            }
    }
    
    func getUserInfo() -> Observable<UserData> {
        
        return self.naverRepository.getUserInfo()
            .flatMapLatest { result -> Observable<UserData> in
                
                switch result {
                case .success(let naverUserData):
                    
                    var userData = UserData(id: String(naverUserData.id))
                    userData.nickname = naverUserData.nickname
                    userData.email = naverUserData.email
                    userData.name = naverUserData.name
                    if let birthyear = naverUserData.birthyear,
                       let birthday = naverUserData.birthday {
                        userData.birth = birthyear + birthday
                    }
                    userData.gender = naverUserData.gender
                    userData.profileImgUrl = naverUserData.profileImgUrl
                    userData.phone = naverUserData.phone
                    userData.snsType = "naver"
                    
                    return Observable.just(userData)
                    
                    //                    print(kakaoUserData.id)
                    //                    print(kakaoUserData.name)
                    //                    print(kakaoUserData.nickname)
                    //                    print(kakaoUserData.email)
                    
                case .failure(let error):
                    Log.network(error.localizedDescription)
                    return Observable.error(error)
                }
            }
        
    

    }
    
}
