//
//  AppDelegate.swift
//  myshopping
//
//  Created by wetest on 2026/4/7.
//

import UIKit

@main
class AppDelegate: UIResponder, UIApplicationDelegate {

    /// iOS 11–12 传统窗口；iOS 13+ 由 Scene 管理（此处仍保留以兼容旧系统）
    var window: UIWindow?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        if #available(iOS 13.0, *) {
            // 窗口由 SceneDelegate + Storyboard 生命周期管理
        } else {
            window = UIWindow(frame: UIScreen.main.bounds)
            window?.rootViewController = UIStoryboard(name: "Main", bundle: nil).instantiateInitialViewController()
            window?.makeKeyAndVisible()
        }
        return true
    }

    // MARK: UISceneSession Lifecycle（仅 iOS 13+）

    @available(iOS 13.0, *)
    func application(_ application: UIApplication, configurationForConnecting connectingSceneSession: UISceneSession, options: UIScene.ConnectionOptions) -> UISceneConfiguration {
        return UISceneConfiguration(name: "Default Configuration", sessionRole: connectingSceneSession.role)
    }

    @available(iOS 13.0, *)
    func application(_ application: UIApplication, didDiscardSceneSessions sceneSessions: Set<UISceneSession>) {
    }
}
