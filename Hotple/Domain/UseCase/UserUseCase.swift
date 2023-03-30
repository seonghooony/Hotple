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
    
    var disposeBag = DisposeBag()
    

    
    init(localRepository: LocalRepository, firebaseRepository: FirebaseRepository) {
        print("UserUseCase init")
        self.localRepository = localRepository
        self.firebaseRepository = firebaseRepository
    }
    
    deinit {
        disposeBag = DisposeBag()
        print("UserUseCase deinit")
    }
    
    func getUserInfo() -> Observable<UserData?> {
        
        // 로컬 내 userdata 읽어오기
        return self.localRepository.readUser()
            .flatMapLatest { userData -> Observable<UserData?> in
                // 로컬 데이터가 있으면 firebase 에 유저정보 있는지 확인
                if let userData = userData {
                    return self.firebaseRepository.getUserData(userData: userData)
                } else {
                    return Observable.just(nil)
                }
            }
        
    }
    
}
