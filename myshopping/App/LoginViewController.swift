//
//  LoginViewController.swift
//  myshopping
//
//  对应 Android LoginFragment
//

import UIKit

final class LoginViewController: UIViewController {

    private let usernameField = UITextField()
    private let passwordField = UITextField()
    private let loginButton = UIButton(type: .system)
    private let registerButton = UIButton(type: .system)

    override func viewDidLoad() {
        super.viewDidLoad()
        title = "登录"
        view.backgroundColor = .white
        setupFields()
    }

    private func setupFields() {
        usernameField.placeholder = "用户名"
        usernameField.borderStyle = .roundedRect
        usernameField.autocapitalizationType = .none
        usernameField.translatesAutoresizingMaskIntoConstraints = false

        passwordField.placeholder = "密码"
        passwordField.isSecureTextEntry = true
        passwordField.borderStyle = .roundedRect
        passwordField.translatesAutoresizingMaskIntoConstraints = false

        loginButton.setTitle("登录", for: .normal)
        loginButton.addTarget(self, action: #selector(onLogin), for: .touchUpInside)
        loginButton.translatesAutoresizingMaskIntoConstraints = false

        registerButton.setTitle("注册", for: .normal)
        registerButton.addTarget(self, action: #selector(onRegister), for: .touchUpInside)
        registerButton.translatesAutoresizingMaskIntoConstraints = false

        let stack = UIStackView(arrangedSubviews: [usernameField, passwordField, loginButton, registerButton])
        stack.axis = .vertical
        stack.spacing = 16
        stack.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(stack)

        let guide = view.safeAreaLayoutGuide
        NSLayoutConstraint.activate([
            stack.leadingAnchor.constraint(equalTo: guide.leadingAnchor, constant: 24),
            stack.trailingAnchor.constraint(equalTo: guide.trailingAnchor, constant: -24),
            stack.centerYAnchor.constraint(equalTo: guide.centerYAnchor)
        ])
    }

    @objc private func onLogin() {
        let u = usernameField.text?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
        let p = passwordField.text ?? ""
        if u.isEmpty {
            presentAlert("请输入用户名")
            return
        }
        if p.isEmpty {
            presentAlert("请输入密码")
            return
        }
        if UserManager.login(username: u, password: p) {
            presentAlert("登录成功") { [weak self] in
                guard let self = self else { return }
                RootSwitcher.replaceRoot(from: self, with: MainTabBarController(), animated: true)
            }
        } else {
            presentAlert("用户名或密码错误")
        }
    }

    @objc private func onRegister() {
        navigationController?.pushViewController(RegisterViewController(), animated: true)
    }

    private func presentAlert(_ msg: String, completion: (() -> Void)? = nil) {
        let ac = UIAlertController(title: nil, message: msg, preferredStyle: .alert)
        ac.addAction(UIAlertAction(title: "确定", style: .default, handler: { _ in completion?() }))
        present(ac, animated: true)
    }
}
