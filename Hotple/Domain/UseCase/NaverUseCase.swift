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
    private let naverRepository: NaverRepository
    
    let disposeBag = DisposeBag()
    
    init(localRepository: LocalRepository, naverRepository: NaverRepository) {
        self.localRepository = localRepository
        self.naverRepository = naverRepository
    }
    
    
    func login() -> Observable<Bool> {
        
        return naverRepository.setLogin()
//        return Observable.create { observer in
//            
//            self.naverRepository.setLogin()
//                .subscribe { isLogin in
//                    observer.onNext(isLogin)
//                    observer.onCompleted()
//                }
//                .disposed(by: self.disposeBag)
//            
//            return Disposables.create()
//        }
    }
    
    func logout() -> Observable<Bool> {
        return naverRepository.setLogout()
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
                        
                        
                        
    //                    debugPrint(naverUserData.id)
    //                    debugPrint(naverUserData.name)
    //                    debugPrint(naverUserData.nickname)
    //                    debugPrint(naverUserData.email)

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
