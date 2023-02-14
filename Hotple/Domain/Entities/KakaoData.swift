//
//  KakaoData.swift
//  Hotple
//
//  Created by SeongHoon Kim on 2023/02/08.
//

import Foundation

struct KakaoUserData: Decodable {
    
    let id: Int64
    var email: String?
    var name: String?
    var nickname: String?
    var birth: String?
    var birthyear: String?
    var birthday: String?
    var gender: String?
    var phone: String?
    var profileImgUrl: String?
    
    
}
