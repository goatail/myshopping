//
//  SplashViewController.swift
//  myshopping
//
//  对应 Android SplashFragment：延时后进入登录或主导航
//

import UIKit

final class SplashViewController: UIViewController {

    private let delaySeconds: TimeInterval = 2

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor(red: 0.95, green: 0.97, blue: 1, alpha: 1)
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = "MyShopping"
        label.font = UIFont.boldSystemFont(ofSize: 28)
        label.textAlignment = .center
        view.addSubview(label)
        NSLayoutConstraint.activate([
            label.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            label.centerYAnchor.constraint(equalTo: view.centerYAnchor)
        ])
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        DispatchQueue.main.asyncAfter(deadline: .now() + delaySeconds) { [weak self] in
            guard let self = self else { return }
            let next: UIViewController
            if UserManager.isLoggedIn() {
                next = MainTabBarController()
            } else {
                next = LoginFlow.makeLoginNavigationController()
            }
            RootSwitcher.replaceRoot(from: self, with: next, animated: true)
        }
    }
}
