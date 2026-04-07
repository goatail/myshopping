//
//  SplashViewController.swift
//  myshopping
//
//  对应 Android SplashFragment：splash_logo + 文案，延时后进入登录或主导航
//

import UIKit

final class SplashViewController: UIViewController {

    private let delaySeconds: TimeInterval = 2

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor(red: 0.95, green: 0.97, blue: 1, alpha: 1)

        let logoView = UIImageView()
        logoView.translatesAutoresizingMaskIntoConstraints = false
        logoView.contentMode = .scaleAspectFit
        logoView.image = UIImage(named: "splash_logo")

        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        // 与 fragment_splash.xml 中 appNameTextView 一致
        label.text = "购物 Shopping"
        label.font = UIFont.boldSystemFont(ofSize: 28)
        label.textAlignment = .center
        label.textColor = UIColor(red: 0.2, green: 0.2, blue: 0.2, alpha: 1)

        let stack = UIStackView(arrangedSubviews: [logoView, label])
        stack.translatesAutoresizingMaskIntoConstraints = false
        stack.axis = .vertical
        stack.alignment = .center
        stack.spacing = 24

        view.addSubview(stack)

        NSLayoutConstraint.activate([
            logoView.widthAnchor.constraint(equalToConstant: 120),
            logoView.heightAnchor.constraint(equalToConstant: 120),

            stack.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            stack.centerYAnchor.constraint(equalTo: view.centerYAnchor)
        ])
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        DispatchQueue.main.asyncAfter(deadline: .now() + delaySeconds) { [weak self] in
            guard let self = self else { return }
            // 未登录仅进入登录栈；不开放游客进主页（业务入口仅此一处）
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
