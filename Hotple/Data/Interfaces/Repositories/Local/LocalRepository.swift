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
    func addItem(key: Any, pwd: Any) -> Bool
    func getItem(key: Any) -> Any?
    func updateItem(value: Any, key: Any) -> Bool
    func deleteItem(key: String) -> Bool
}

final class LocalRepository: LocalRepositoryProtocol {
    
    init() {
        Log.debug("LocalRepository init")
    }

    deinit {
        Log.debug("LocalRepository deinit")
    }
    
    func createUser(_ user: UserData) -> Observable<Bool> {
        Log.info("LocalRepository createUser")
        
        guard let data = try? JSONEncoder().encode(user) else { return Observable.just(false) }
        UserDefaults.standard.setValue(user.id, forKey: UserDefaultKeys.USER_ID)
        UserDefaults.standard.setValue(user.snsType, forKey: UserDefaultKeys.LOGIN_TYPE)
        let query: [CFString: Any] = [
            kSecClass : kSecClassGenericPassword,
            kSecAttrService : "com.github.seonghooony.Hotple",
            kSecAttrAccount : user.id,
            kSecAttrGeneric : data
        ]
        
        let status = SecItemAdd(query as CFDictionary, nil)
        if status == errSecSuccess {
            Log.debug("LocalRepository createUser : 해당 사용자 정보 없음, 새로 생성")
            return Observable.just(true)
            
        } else if status == errSecDuplicateItem {
            Log.debug("LocalRepository createUser : 해당 사용자 정보 있음, 덮어쓰기")
            return updateUser(user)
            
        } else {
            Log.debug("LocalRepository createUser : 생성 할 수 없음")
            return Observable.just(false)
        }
        
        
//        return Observable.just(SecItemAdd(query as CFDictionary, nil) == errSecSuccess)
    }
    
    func readUser() -> Observable<UserData?> {
        Log.info("LocalRepository readUser")
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
        Log.info("LocalRepository updateUser")
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
        Log.debug(SecItemUpdate(query as CFDictionary, attribute as CFDictionary) == errSecSuccess)
        return Observable.just(SecItemUpdate(query as CFDictionary, attribute as CFDictionary) == errSecSuccess)
    }
    
    func deleteUser() -> Observable<Bool> {
        Log.info("LocalRepository deleteUser")
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
    
    
    func addItem(key: Any, pwd: Any) -> Bool {
        let addQuery: [CFString: Any] = [kSecClass: kSecClassGenericPassword,
                                         kSecAttrAccount: key,
                                         kSecValueData: (pwd as AnyObject).data(using: String.Encoding.utf8.rawValue) as Any]
        
        let result: Bool = {
            let status = SecItemAdd(addQuery as CFDictionary, nil)
            if status == errSecSuccess {
                return true
            } else if status == errSecDuplicateItem {
                return updateItem(value: pwd, key: key)
            }
            
            print("addItem Error : \(status.description))")
            return false
        }()
        
        return result
    }
    
    
    func getItem(key: Any) -> Any? {
        let getQuery: [CFString: Any] = [kSecClass: kSecClassGenericPassword,
                                      kSecAttrAccount: key,
                                      kSecReturnAttributes: true,
                                      kSecReturnData: true]
        var item: CFTypeRef?
        let result = SecItemCopyMatching(getQuery as CFDictionary, &item)
        
        if result == errSecSuccess {
            if let existingItem = item as? [String: Any],
               let data = existingItem[kSecValueData as String] as? Data,
               let password = String(data: data, encoding: .utf8) {
                return password
            }
        }
        
        print("getItem Error : \(result.description)")
        return nil
    }
    
    func updateItem(value: Any, key: Any) -> Bool {
        let prevQuery: [CFString: Any] = [kSecClass: kSecClassGenericPassword,
                                              kSecAttrAccount: key]
        let updateQuery: [CFString: Any] = [kSecValueData: (value as AnyObject).data(using: String.Encoding.utf8.rawValue) as Any]
        
        let result: Bool = {
            let status = SecItemUpdate(prevQuery as CFDictionary, updateQuery as CFDictionary)
            if status == errSecSuccess { return true }
            
            print("updateItem Error : \(status.description)")
            return false
        }()
        
        return result
    }
    
    func deleteItem(key: String) -> Bool {
        let deleteQuery: [CFString: Any] = [kSecClass: kSecClassGenericPassword,
                                            kSecAttrAccount: key]
        let status = SecItemDelete(deleteQuery as CFDictionary)
        if status == errSecSuccess { return true }
        
        print("deleteItem Error : \(status.description)")
        return false
    }
}
