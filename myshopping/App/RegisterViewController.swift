//
//  RegisterViewController.swift
//  myshopping
//
//  对应 Android RegisterFragment：验证码各位数字之和为 20
//

import UIKit

final class RegisterViewController: UIViewController {

    private let phoneField = UITextField()
    private let usernameField = UITextField()
    private let passwordField = UITextField()
    private let confirmField = UITextField()
    private let codeField = UITextField()
    private let sendCodeButton = UIButton(type: .system)
    private let registerButton = UIButton(type: .system)

    private var countdownTimer: Timer?
    private var countdownLeft = 0
    /// 与常见短信重发间隔一致（若 Android 工程为其他秒数，改此常量即可）
    private let verificationResendInterval = 60

    override func viewDidLoad() {
        super.viewDidLoad()
        title = "注册"
        view.backgroundColor = .white
        setupForm()
    }

    deinit {
        countdownTimer?.invalidate()
    }

    private func setupForm() {
        func field(_ placeholder: String, secure: Bool = false) -> UITextField {
            let t = UITextField()
            t.placeholder = placeholder
            t.borderStyle = .roundedRect
            t.isSecureTextEntry = secure
            t.autocapitalizationType = .none
            t.keyboardType = placeholder.contains("手机") ? .phonePad : .default
            return t
        }
        phoneField.placeholder = "手机号"
        phoneField.borderStyle = .roundedRect
        phoneField.keyboardType = .phonePad
        usernameField.placeholder = "用户名"
        usernameField.borderStyle = .roundedRect
        usernameField.autocapitalizationType = .none
        passwordField.placeholder = "密码"
        passwordField.borderStyle = .roundedRect
        passwordField.isSecureTextEntry = true
        confirmField.placeholder = "确认密码"
        confirmField.borderStyle = .roundedRect
        confirmField.isSecureTextEntry = true
        codeField.placeholder = "验证码（4位数字之和为20）"
        codeField.borderStyle = .roundedRect
        codeField.keyboardType = .numberPad

        sendCodeButton.setTitle("发送验证码", for: .normal)
        sendCodeButton.addTarget(self, action: #selector(sendCode), for: .touchUpInside)

        registerButton.setTitle("注册", for: .normal)
        registerButton.addTarget(self, action: #selector(registerTap), for: .touchUpInside)

        let codeRow = UIStackView(arrangedSubviews: [codeField, sendCodeButton])
        codeRow.axis = .horizontal
        codeRow.spacing = 8
        codeRow.distribution = .fillProportionally

        let stack = UIStackView(arrangedSubviews: [
            phoneField, usernameField, passwordField, confirmField, codeRow, registerButton
        ])
        stack.axis = .vertical
        stack.spacing = 12
        stack.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(stack)

        let guide = view.safeAreaLayoutGuide
        NSLayoutConstraint.activate([
            stack.leadingAnchor.constraint(equalTo: guide.leadingAnchor, constant: 20),
            stack.trailingAnchor.constraint(equalTo: guide.trailingAnchor, constant: -20),
            stack.topAnchor.constraint(equalTo: guide.topAnchor, constant: 24)
        ])
    }

    @objc private func sendCode() {
        let phone = phoneField.text?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
        if phone.isEmpty {
            presentAlert("请输入手机号")
            return
        }
        if phone.count != 11 {
            presentAlert("请输入正确的11位手机号")
            return
        }
        let code = generateVerificationCode()
        presentAlert("验证码已发送：\(code)")
        startCountdown()
    }

    private func generateVerificationCode() -> String {
        var a: Int
        var b: Int
        var c: Int
        var d: Int
        repeat {
            a = Int.random(in: 1...9)
            b = Int.random(in: 0...9)
            c = Int.random(in: 0...9)
            d = 20 - a - b - c
        } while d < 0 || d > 9
        return "\(a)\(b)\(c)\(d)"
    }

    private func startCountdown() {
        countdownTimer?.invalidate()
        countdownLeft = verificationResendInterval
        sendCodeButton.isEnabled = false
        tickCountdown()
        let timer = Timer(timeInterval: 1, repeats: true) { [weak self] t in
            self?.tickCountdown(timer: t)
        }
        RunLoop.main.add(timer, forMode: .common)
        countdownTimer = timer
    }

    private func tickCountdown(timer: Timer? = nil) {
        if countdownLeft <= 0 {
            timer?.invalidate()
            countdownTimer?.invalidate()
            sendCodeButton.isEnabled = true
            sendCodeButton.setTitle("发送验证码", for: .normal)
            return
        }
        sendCodeButton.setTitle("重新发送(\(countdownLeft)s)", for: .normal)
        countdownLeft -= 1
    }

    @objc private func registerTap() {
        let phone = phoneField.text?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
        let username = usernameField.text?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
        let password = passwordField.text ?? ""
        let confirm = confirmField.text ?? ""
        let code = codeField.text?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""

        if phone.isEmpty { presentAlert("请输入手机号"); return }
        if phone.count != 11 { presentAlert("请输入正确的11位手机号"); return }
        if username.isEmpty { presentAlert("请输入用户名"); return }
        if password.isEmpty { presentAlert("请输入密码"); return }
        if password.count < 6 { presentAlert("密码长度至少6位"); return }
        if password != confirm { presentAlert("两次输入的密码不一致"); return }
        if code.isEmpty { presentAlert("请输入验证码"); return }
        if Self.sumDigits(code) != 20 {
            presentAlert("验证码错误")
            return
        }
        if UserManager.register(phone: phone, username: username, password: password) {
            presentAlert("注册成功，请登录") { [weak self] in
                self?.navigationController?.popViewController(animated: true)
            }
        } else {
            presentAlert("用户名已存在")
        }
    }

    private static func sumDigits(_ code: String) -> Int {
        return code.reduce(0) { partial, ch in
            partial + (Int(String(ch)) ?? 0)
        }
    }

    private func presentAlert(_ msg: String, completion: (() -> Void)? = nil) {
        let ac = UIAlertController(title: nil, message: msg, preferredStyle: .alert)
        ac.addAction(UIAlertAction(title: "确定", style: .default, handler: { _ in completion?() }))
        present(ac, animated: true)
    }
}
