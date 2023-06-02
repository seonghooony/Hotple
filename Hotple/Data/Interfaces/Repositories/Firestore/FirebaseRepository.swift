//
//  FirestoreRepository.swift
//  Hotple
//
//  Created by SeongHoon Kim on 2023/02/14.
//

import Foundation

import RxSwift
import RxCocoa

import FirebaseCore
import FirebaseFirestore
import FirebaseFirestoreSwift

protocol FirebaseRepositoryProtocol {
    func setUserData(userData: UserData) -> Observable<Bool>
    func getUserData(userData: UserData) -> Observable<UserData?>
}

final class FirebaseRepository: FirebaseRepositoryProtocol {
    
    let db = Firestore.firestore()
    
    init() {
        Log.debug("FirebaseRepository init")
    }
    
    deinit {
        Log.debug("FirebaseRepository deinit")
    }
    
    func setUserData(userData: UserData) -> Observable<Bool> {
        Log.info("FirebaseRepository setUserData")
        
        return Observable<Bool>.create { observer in
            do {
                try self.db.collection("Users").document(userData.id).setData(from: userData) { error in
                    if let error = error {
                        observer.onError(error)
                    } else {
                        observer.onNext(true)
                        observer.onCompleted()
                    }
                }
            } catch let error {
                observer.onError(error)
            }
            
            return Disposables.create()
        }
    }
    
    func getUserData(userData: UserData) -> Observable<UserData?> {
        Log.network("FirebaseRepository getUserData")
        
        return Observable.create { observer in
            self.db.collection("Users").document(userData.id).getDocument { document, error in
                
                if let error = error {
                    observer.onError(error)
                }
                
                guard let document = document else {
                    observer.onNext(nil)
                    observer.onCompleted()
                    return
                }
                
                if let userData = try? document.data(as: UserData.self) {
                    observer.onNext(userData)
                    observer.onCompleted()
                } else {
                    observer.onNext(nil)
                    observer.onCompleted()
                }
            }

            return Disposables.create()
        }
    }
}
