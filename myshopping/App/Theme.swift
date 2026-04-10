//
//  Theme.swift
//  myshopping
//
//  全局主题（对齐产品主色）：#92bfa6
//

import UIKit

enum Theme {
    /// 统一主色：登录按钮、注册按钮、Tabs 激活、底部导航激活
    static let primary = UIColor(hex: 0x369650)

    static let textPrimary = UIColor(white: 0.12, alpha: 1)
    static let textSecondary = UIColor(white: 0.6, alpha: 1)
    static let border = UIColor(white: 0.88, alpha: 1)
    static let pageBackground = UIColor(white: 1, alpha: 1)
}

extension UIColor {
    convenience init(hex: Int, alpha: CGFloat = 1) {
        let r = CGFloat((hex >> 16) & 0xFF) / 255.0
        let g = CGFloat((hex >> 8) & 0xFF) / 255.0
        let b = CGFloat(hex & 0xFF) / 255.0
        self.init(red: r, green: g, blue: b, alpha: alpha)
    }
}

