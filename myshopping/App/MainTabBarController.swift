//
//  MainTabBarController.swift
//  myshopping
//
//  对应 Android MainContainerFragment + bottomNavigation（四 Tab）
//

import UIKit

final class MainTabBarController: UITabBarController {

    override func viewDidLoad() {
        super.viewDidLoad()
        delegate = self
        let homeNav = UINavigationController(rootViewController: HomeViewController())
        homeNav.tabBarItem = makeTabItem(title: "首页", systemName: "house", tag: 0)

        let favNav = UINavigationController(rootViewController: FavoriteViewController())
        favNav.tabBarItem = makeTabItem(title: "收藏", systemName: "heart", tag: 1)

        let cartNav = UINavigationController(rootViewController: CartViewController())
        cartNav.tabBarItem = makeTabItem(title: "购物车", systemName: "cart", tag: 2)

        let profileNav = UINavigationController(rootViewController: ProfileViewController())
        profileNav.tabBarItem = makeTabItem(title: "我的", systemName: "person", tag: 3)

        viewControllers = [homeNav, favNav, cartNav, profileNav]
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
