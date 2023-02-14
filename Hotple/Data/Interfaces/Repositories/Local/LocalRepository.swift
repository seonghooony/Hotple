//
//  LocalRepository.swift
//  Hotple
//
//  Created by SeongHoon Kim on 2023/02/13.
//

import Foundation
import Security
import RxSwift
import RxCocoa
import UIKit

protocol LocalRepositoryProtocol {
    func createUser(_ user: UserData) -> Observable<Bool>
}

final class LocalRepository: LocalRepositoryProtocol {
    
    func createUser(_ user: UserData) -> Observable<Bool> {
        print("LocalRepository createUser")
        guard let data = try? JSONEncoder().encode(user) else { return Observable.just(false) }
        UserDefaults.standard.setValue(user.id, forKey: UserDefaultKeys.USER_ID)
        UserDefaults.standard.setValue(user.snsType, forKey: UserDefaultKeys.LOGIN_TYPE)
        let query: [CFString: Any] = [
            kSecClass : kSecClassGenericPassword,
            kSecAttrService : "com.github.seonghooony.Hotple",
            kSecAttrAccount : user.id,
            kSecAttrGeneric : data
        ]
        
        return Observable.just(SecItemAdd(query as CFDictionary, nil) == errSecSuccess)
    }
    
    func readUser() -> Observable<UserData?> {
        guard let id = UserDefaults.standard.string(forKey: UserDefaultKeys.USER_ID) else { return Observable.just(nil) }
        let query: [CFString: Any] = [
            kSecClass : kSecClassGenericPassword,
            kSecAttrService : "com.github.seonghooony.Hotple",
            kSecAttrAccount : id,
            kSecMatchLimit : kSecMatchLimitOne,
            kSecReturnAttributes : true,
            kSecReturnData : true
        ]
        
        var item: CFTypeRef?
        
        if SecItemCopyMatching(query as CFDictionary, &item) != errSecSuccess { return Observable.just(nil) }
        
        guard let existingItem = item as? [CFString : Any],
              let data = existingItem[kSecAttrGeneric] as? Data,
              let userData = try? JSONDecoder().decode(UserData.self, from: data) else { return Observable.just(nil) }
        
        return Observable.just(userData)
    }
    
    func updateUser(_ user: UserData) -> Observable<Bool> {
        guard let data = try? JSONEncoder().encode(user) else { return Observable.just(false) }
        guard let userId = UserDefaults.standard.string(forKey: UserDefaultKeys.USER_ID) else { return Observable.just(false) }
        
        UserDefaults.standard.setValue(user.id, forKey: UserDefaultKeys.USER_ID)
        UserDefaults.standard.setValue(user.snsType, forKey: UserDefaultKeys.LOGIN_TYPE)
        
        let query: [CFString: Any] = [
            kSecClass : kSecClassGenericPassword,
            kSecAttrService : "com.github.seonghooony.Hotple",
            kSecAttrAccount : userId
        ]
        
        let attribute: [CFString: Any] = [
            kSecAttrAccount : user.id,
            kSecAttrGeneric : data
        ]
        
        return Observable.just(SecItemUpdate(query as CFDictionary, attribute as CFDictionary) == errSecSuccess)
    }
    
    func deleteUser() -> Observable<Bool> {
        guard let userId = UserDefaults.standard.string(forKey: UserDefaultKeys.USER_ID) else { return Observable.just(false) }
        
        let query: [CFString: Any] = [
            kSecClass : kSecClassGenericPassword,
            kSecAttrService : "com.github.seonghooony.Hotple",
            kSecAttrAccount : userId
        ]
        
        UserDefaults.standard.removeObject(forKey: UserDefaultKeys.USER_ID)
        UserDefaults.standard.removeObject(forKey: UserDefaultKeys.LOGIN_TYPE)
        
        return Observable.just(SecItemDelete(query as CFDictionary) == errSecSuccess)
    }
}
