//
//  LoginFlow.swift
//  myshopping
//
//  登录/注册导航栈构建
//

import UIKit

enum LoginFlow {
    static func makeLoginNavigationController() -> UINavigationController {
        let login = LoginViewController()
        let nav = UINavigationController(rootViewController: login)
        nav.navigationBar.prefersLargeTitles = false
        return nav
    }
}
