//
//  RootSwitcher.swift
//  myshopping
//
//  无 Scene 与多 Scene 差异下切换 window.rootViewController（iOS 11+）
//

import UIKit

enum RootSwitcher {

    /// 从当前界面所在 window 替换根控制器（用于启动页 → 登录/主页）
    static func replaceRoot(from viewController: UIViewController, with newRoot: UIViewController, animated: Bool) {
        guard let window = viewController.view.window else { return }
        if animated {
            UIView.transition(with: window, duration: 0.28, options: .transitionCrossDissolve, animations: {
                window.rootViewController = newRoot
            }, completion: { _ in
                window.makeKeyAndVisible()
            })
        } else {
            window.rootViewController = newRoot
            window.makeKeyAndVisible()
        }
    }
}
