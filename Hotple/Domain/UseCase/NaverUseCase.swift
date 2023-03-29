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
    
    let disposeBag = DisposeBag()
    

    
    init(localRepository: LocalRepository, firebaseRepository: FirebaseRepository, naverRepository: NaverRepository) {
        self.localRepository = localRepository
        self.firebaseRepository = firebaseRepository
        self.naverRepository = naverRepository
    }
    
    deinit {
        print("NaverUseCase deinit")
    }
    
    func login() -> Observable<Bool> {
        let checkUserSubject = PublishSubject<UserData>()
        let pushUserSubject = PublishSubject<UserData>()
        let localLoginSubject = PublishSubject<UserData>()
        let completedLoginSubject = PublishSubject<Bool>()
        
        // 로컬 단에 유저데이터 넣기
        localLoginSubject
            .subscribe { userData in
                self.localRepository.createUser(userData)
                    .subscribe { isCompleted in
                        print("완료 여부 : \(isCompleted)")
                        print("로컬 로그인 성공, 완료 이벤트 방출 (Local)")
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
                            print("푸쉬 진행 성공 (Firestore)")
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
                            print("유저 존재함 (Firestore)")
                            localLoginSubject.onNext(userDataF)
                        } else {
                            print("유저 존재하지 않음, 푸쉬 진행 (Firestore)")
                            pushUserSubject.onNext(userData)
                        }
                        
                    }
                    .disposed(by: self.disposeBag)

            }
            .disposed(by: disposeBag)
        
        naverRepository.setLogin()
            .subscribe { isLogin in
                if isLogin {
                    self.getUserInfo()
                        .subscribe { userData in
                            print("네이버 서드파티 로그인 성공")
                            checkUserSubject.onNext(userData)
                        }
                        .disposed(by: self.disposeBag)
                }
                
            } onError: { error in
                print("naverRepository setLogin onError: \(error)")
            } onCompleted: {
                print("naverRepository setLogin onCompleted")
            }
            .disposed(by: disposeBag)
        
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
        return Observable.create { observer in
            self.naverRepository.getUserInfo()
                .subscribe { result in
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
                        
                        observer.onNext(userData)
                        observer.onCompleted()


                    case .failure(let error):
                        debugPrint(error.localizedDescription)
                        observer.onError(error)
                    }
                } onError: { error in
                    debugPrint(error.localizedDescription)
                    observer.onError(error)
                } onCompleted: {
                    debugPrint("onCompleted")
                } onDisposed: {
                    debugPrint("onDisposed")
                }
                .disposed(by: self.disposeBag)
            
            return Disposables.create()
        }

    }
    
}
