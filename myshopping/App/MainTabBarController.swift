//
//  MainTabBarController.swift
//  myshopping
//
//  对应 Android MainContainerFragment + bottomNavigation（四 Tab）
//

import UIKit

final class MainTabBarController: UITabBarController {

    private var cartObserver: NSObjectProtocol?

    override func viewDidLoad() {
        super.viewDidLoad()
        delegate = self

        // 底部导航激活色统一：#92bfa6
        tabBar.tintColor = Theme.primary
        if #available(iOS 10.0, *) {
            tabBar.unselectedItemTintColor = UIColor(white: 0.35, alpha: 1)
        }
        let homeNav = UINavigationController(rootViewController: HomeViewController())
        homeNav.tabBarItem = makeTabItem(title: "首页", systemName: "house", tag: 0)

        let favNav = UINavigationController(rootViewController: FavoriteViewController())
        favNav.tabBarItem = makeTabItem(title: "收藏", systemName: "heart", tag: 1)

        let cartNav = UINavigationController(rootViewController: CartViewController())
        cartNav.tabBarItem = makeTabItem(title: "购物车", systemName: "cart", tag: 2)

        let profileNav = UINavigationController(rootViewController: ProfileViewController())
        profileNav.tabBarItem = makeTabItem(title: "我的", systemName: "person", tag: 3)

        // 避免大标题模式 + 空 title 造成导航栏下方大块空白；各 Tab 根页已用 safeArea 约束，勿再叠加大标题区
        for nav in [homeNav, favNav, cartNav, profileNav] {
            nav.navigationBar.prefersLargeTitles = false
            nav.viewControllers.first?.navigationItem.largeTitleDisplayMode = .never
        }

        viewControllers = [homeNav, favNav, cartNav, profileNav]

        cartObserver = NotificationCenter.default.addObserver(
            forName: CartManager.cartDidChangeNotification,
            object: nil,
            queue: .main
        ) { [weak self] _ in
            self?.updateCartTabBadge()
        }
        updateCartTabBadge()
    }

    deinit {
        if let o = cartObserver {
            NotificationCenter.default.removeObserver(o)
        }
    }

    /// 购物车 Tab 显示种类数量角标（与常见电商一致）
    private func updateCartTabBadge() {
        let n = CartManager.cartLineCount()
        guard let items = tabBar.items, items.count > 2 else { return }
        items[2].badgeValue = n > 0 ? "\(n)" : nil
    }

    private func makeTabItem(title: String, systemName: String, tag: Int) -> UITabBarItem {
        if #available(iOS 13.0, *) {
            let img = UIImage(systemName: systemName)
            return UITabBarItem(title: title, image: img, tag: tag)
        } else {
            let fallbackName: String
            switch tag {
            case 0: fallbackName = "tab_home"
            case 1: fallbackName = "tab_favorite"
            case 2: fallbackName = "tab_cart"
            case 3: fallbackName = "tab_profile"
            default: fallbackName = "tab_home"
            }
            let img = normalizedTabImage(named: fallbackName)?.withRenderingMode(.alwaysTemplate)
            return UITabBarItem(title: title, image: img, tag: tag)
        }
    }

    /// iOS 11/12 兼容：将资源图标统一缩放到 TabBar 常用尺寸，避免源图过大导致显示异常
    private func normalizedTabImage(named name: String) -> UIImage? {
        guard let source = UIImage(named: name) else { return nil }
        let targetSide: CGFloat = 25
        let targetSize = CGSize(width: targetSide, height: targetSide)
        let renderer = UIGraphicsImageRenderer(size: targetSize)
        return renderer.image { _ in
            source.draw(in: CGRect(origin: .zero, size: targetSize))
        }
    }
}

extension MainTabBarController: UITabBarControllerDelegate {
    func tabBarController(_ tabBarController: UITabBarController, shouldSelect viewController: UIViewController) -> Bool {
        return true
    }
}
