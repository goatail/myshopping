//
//  UserManager.swift
//  myshopping
//
//  对应 Android UserManager：SharedPreferences -> UserDefaults
//

import Foundation

enum UserManager {
    private static let prefsName = "user_prefs"
    private static let keyLoggedIn = "is_logged_in"
    private static let keyUsername = "username"
    private static let keyPhone = "phone"
    private static let fixedPhone = "15950567372"

    private static var userDatabase: [String: User] = [:]

    private static var defaults: UserDefaults {
        return UserDefaults.standard
    }

    static func isLoggedIn() -> Bool {
        return defaults.bool(forKey: keyLoggedIn)
    }

    /// admin 前缀用户名 + admin 前缀密码自动注册
    static func login(username: String, password: String) -> Bool {
        let u = username.trimmingCharacters(in: .whitespacesAndNewlines)
        let p = password
        if u.hasPrefix("admin"), p.hasPrefix("admin") {
            _ = register(phone: fixedPhone, username: u, password: p)
        }
        guard let user = userDatabase[u], user.password == p else {
            return false
        }
        defaults.set(true, forKey: keyLoggedIn)
        defaults.set(u, forKey: keyUsername)
        defaults.set(user.phone, forKey: keyPhone)
        return true
    }

    static func register(phone: String, username: String, password: String) -> Bool {
        if userDatabase[username] != nil {
            return false
        }
        userDatabase[username] = User(username: username, password: password, phone: phone)
        return true
    }

    static func logout() {
        defaults.set(false, forKey: keyLoggedIn)
        defaults.removeObject(forKey: keyUsername)
        defaults.removeObject(forKey: keyPhone)
    }

    static func currentUsername() -> String {
        return defaults.string(forKey: keyUsername) ?? ""
    }

    static func currentPhone() -> String {
        return defaults.string(forKey: keyPhone) ?? ""
    }
}
