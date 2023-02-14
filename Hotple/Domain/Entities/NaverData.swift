//
//  NaverUserData.swift
//  Hotple
//
//  Created by SeongHoon Kim on 2023/02/08.
//

import Foundation
import UIKit
import Alamofire
import RxAlamofire

struct NaverLoginData: Decodable {
    var resultcode: String
    var message: String
    var response: NaverUserData
}

struct NaverUserData: Decodable {
    let id: String
    var name: String?
    var phone: String?
    var gender: String?
    var birthyear: String?
    var birthday: String?
    var profileImgUrl: String?
    var email: String?
    var nickname: String?
    
    enum CodingKeys: String, CodingKey {
        case id
        case name
        case phone = "mobile"
        case gender
        case birthyear
        case birthday
        case profileImgUrl = "profile_image"
        case email
        case nickname
    }
    
}
