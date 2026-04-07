//
//  User.swift
//  myshopping
//

import Foundation

/// 用户模型（内存注册表，与 Android UserManager 行为一致）
struct User: Equatable {
    var username: String
    var password: String
    var phone: String
}
