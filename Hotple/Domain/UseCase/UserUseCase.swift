//
//  UserUseCase.swift
//  Hotple
//
//  Created by SeongHoon Kim on 2023/02/28.
//

import Foundation

import RxSwift
import RxCocoa


protocol UserUseCaseProtocol {
    func getUserInfo() -> Observable<UserData?>
}

final class UserUseCase: UserUseCaseProtocol {
    private let localRepository: LocalRepository
    private let firebaseRepository: FirebaseRepository
    
    let disposeBag = DisposeBag()
    

    
    init(localRepository: LocalRepository, firebaseRepository: FirebaseRepository) {
        self.localRepository = localRepository
        self.firebaseRepository = firebaseRepository
    }
    
    deinit {
        print("UserUseCase deinit")
    }
    
    func getUserInfo() -> Observable<UserData?> {
        let localRepoSubject = PublishSubject<UserData?>()
        let fbRepoSubject = PublishSubject<UserData?>()
        let resultSubject = PublishSubject<UserData?>()
        
        localRepoSubject.subscribe { userData in
            if let userData = userData {
                fbRepoSubject.onNext(userData)
            } else {
                resultSubject.onNext(nil)
            }
        } onError: { error in
            resultSubject.onError(error)
            print(error.localizedDescription)
        } onCompleted: {
            print("userUseCase getUserInfo localRepo completed")
        } onDisposed: {
            print("userUseCase getUserInfo localRepo onDisposed")
        }
        .disposed(by: self.disposeBag)
        
        fbRepoSubject.subscribe { userData in
            if let userData = userData {
                self.firebaseRepository.getUserData(userData: userData)
                    .bind(to: resultSubject)
                    .disposed(by: self.disposeBag)
            } else {
                resultSubject.onNext(nil)
            }
        } onError: { error in
            resultSubject.onError(error)
            print(error.localizedDescription)
        } onCompleted: {
            print("userUseCase getUserInfo fbRepo completed")
        } onDisposed: {
            print("userUseCase getUserInfo fbRepo onDisposed")
        }
        .disposed(by: self.disposeBag)

        
        localRepository.readUser()
            .bind(to: localRepoSubject)
            .disposed(by: self.disposeBag)
        
        return resultSubject
        
    }
    
}
