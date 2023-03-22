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
        return Observable.create { observer in
            
            if let userId = UserDefaults.standard.string(forKey: UserDefaultKeys.USER_ID) {
                let localUserData = UserData(
                    id: userId
                )
                
                self.firebaseRepository.getUserData(userData: localUserData)
                    .subscribe { userData in
                        
                        observer.onNext(userData)
                        observer.onCompleted()
                        
                    } onError: { error in
                        debugPrint(error.localizedDescription)
                        observer.onError(error)
                    } onCompleted: {
                        debugPrint("onCompleted")
                    } onDisposed: {
                        debugPrint("onDisposed")
                    }
                    .disposed(by: self.disposeBag)
                
                
            } else {
                observer.onNext(nil)
                observer.onCompleted()
            }
            
            return Disposables.create()
            
        }
        
    }
    
}
