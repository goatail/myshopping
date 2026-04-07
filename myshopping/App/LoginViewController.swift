//
//  LoginViewController.swift
//  myshopping
//
//  对应 Android LoginFragment
//

import UIKit

final class LoginViewController: UIViewController {

    private let titleLabel = UILabel()
    private let usernameField = UITextField()
    private let passwordField = UITextField()
    private let loginButton = UIButton(type: .system)
    private let registerButton = UIButton(type: .system)

    private let usernameBox = UIView()
    private let passwordBox = UIView()

    override func viewDidLoad() {
        super.viewDidLoad()
        title = "登录"
        view.backgroundColor = Theme.pageBackground
        setupFields()
    }

    private func setupFields() {
        titleLabel.text = "登录"
        titleLabel.font = UIFont.boldSystemFont(ofSize: 36)
        titleLabel.textColor = Theme.textPrimary
        titleLabel.textAlignment = .center
        titleLabel.translatesAutoresizingMaskIntoConstraints = false

        configureOutlined(box: usernameBox, field: usernameField, placeholder: "用户名", secure: false, keyboard: .default)
        usernameField.autocapitalizationType = .none
        usernameField.returnKeyType = .next
        usernameField.addTarget(self, action: #selector(onUsernameReturn), for: .editingDidEndOnExit)

        configureOutlined(box: passwordBox, field: passwordField, placeholder: "密码", secure: true, keyboard: .default)
        passwordField.returnKeyType = .done
        passwordField.addTarget(self, action: #selector(onLogin), for: .editingDidEndOnExit)

        loginButton.setTitle("登录", for: .normal)
        loginButton.backgroundColor = Theme.primary
        loginButton.setTitleColor(.white, for: .normal)
        loginButton.titleLabel?.font = UIFont.boldSystemFont(ofSize: 18)
        loginButton.layer.cornerRadius = 12
        loginButton.addTarget(self, action: #selector(onLogin), for: .touchUpInside)
        loginButton.translatesAutoresizingMaskIntoConstraints = false
        loginButton.heightAnchor.constraint(equalToConstant: 56).isActive = true

        registerButton.setTitle("还没有账号？点击注册", for: .normal)
        registerButton.setTitleColor(Theme.textSecondary, for: .normal)
        registerButton.titleLabel?.font = UIFont.systemFont(ofSize: 14)
        registerButton.addTarget(self, action: #selector(onRegister), for: .touchUpInside)
        registerButton.translatesAutoresizingMaskIntoConstraints = false

        let stack = UIStackView(arrangedSubviews: [titleLabel, usernameBox, passwordBox, loginButton, registerButton])
        stack.axis = .vertical
        stack.spacing = 20
        stack.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(stack)

        let guide = view.safeAreaLayoutGuide
        NSLayoutConstraint.activate([
            stack.leadingAnchor.constraint(equalTo: guide.leadingAnchor, constant: 24),
            stack.trailingAnchor.constraint(equalTo: guide.trailingAnchor, constant: -24),
            stack.centerYAnchor.constraint(equalTo: guide.centerYAnchor)
        ])
    }

    private func configureOutlined(box: UIView, field: UITextField, placeholder: String, secure: Bool, keyboard: UIKeyboardType) {
        box.layer.cornerRadius = 12
        box.layer.borderWidth = 1 / UIScreen.main.scale
        box.layer.borderColor = Theme.border.cgColor
        box.translatesAutoresizingMaskIntoConstraints = false
        box.heightAnchor.constraint(equalToConstant: 56).isActive = true

        field.placeholder = placeholder
        field.isSecureTextEntry = secure
        field.keyboardType = keyboard
        field.borderStyle = .none
        field.font = UIFont.systemFont(ofSize: 16)
        field.clearButtonMode = .whileEditing
        field.autocapitalizationType = .none
        field.translatesAutoresizingMaskIntoConstraints = false
        field.addTarget(self, action: #selector(onFieldBegin(_:)), for: .editingDidBegin)
        field.addTarget(self, action: #selector(onFieldEnd(_:)), for: .editingDidEnd)

        box.addSubview(field)
        NSLayoutConstraint.activate([
            field.leadingAnchor.constraint(equalTo: box.leadingAnchor, constant: 16),
            field.trailingAnchor.constraint(equalTo: box.trailingAnchor, constant: -16),
            field.centerYAnchor.constraint(equalTo: box.centerYAnchor)
        ])
    }

    @objc private func onUsernameReturn() {
        passwordField.becomeFirstResponder()
    }

    @objc private func onFieldBegin(_ t: UITextField) {
        (t.superview)?.layer.borderColor = Theme.primary.cgColor
        (t.superview)?.layer.borderWidth = 2 / UIScreen.main.scale
    }

    @objc private func onFieldEnd(_ t: UITextField) {
        (t.superview)?.layer.borderColor = Theme.border.cgColor
        (t.superview)?.layer.borderWidth = 1 / UIScreen.main.scale
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
