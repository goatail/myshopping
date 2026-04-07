//
//  Address.swift
//  myshopping
//

import Foundation

/// 收货地址
struct Address: Equatable, Codable {
    var id: String
    var name: String
    var phone: String
    var province: String
    var city: String
    var district: String
    var detail: String
    var isDefault: Bool

    func fullAddress() -> String {
        return province + city + district + detail
    }

    func displayText() -> String {
        return name + " " + phone + "\n" + fullAddress()
    }
}
