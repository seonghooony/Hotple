//
//  UserData.swift
//  Hotple
//
//  Created by SeongHoon Kim on 2023/02/09.
//

import Foundation

struct UserData: Codable {
    var id: String
    var email: String?
    var name: String?
    var nickname: String?
    var birth: String?
    var gender: String?
    var phone: String?
    var profileImgUrl: String?
    var snsType: String?
}
