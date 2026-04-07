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
            return UITabBarItem(title: title, image: nil, tag: tag)
        }
    }
}

extension MainTabBarController: UITabBarControllerDelegate {
    func tabBarController(_ tabBarController: UITabBarController, shouldSelect viewController: UIViewController) -> Bool {
        return true
    }
}
