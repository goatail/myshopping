//
//  RegisterViewController.swift
//  myshopping
//
//  对应 Android RegisterFragment：验证码各位数字之和为 20
//

import UIKit

final class RegisterViewController: UIViewController, UITextFieldDelegate {

    private let phoneField = UITextField()
    private let usernameField = UITextField()
    private let passwordField = UITextField()
    private let confirmField = UITextField()
    private let codeField = UITextField()
    private let sendCodeButton = UIButton(type: .system)
    private let registerButton = UIButton(type: .system)
    private let titleLabel = UILabel()

    private let phoneBox = UIView()
    private let usernameBox = UIView()
    private let passwordBox = UIView()
    private let confirmBox = UIView()
    private let codeBox = UIView()

    private var countdownTimer: Timer?
    private var countdownLeft = 0
    /// 与常见短信重发间隔一致（若 Android 工程为其他秒数，改此常量即可）
    private let verificationResendInterval = 60

    override func viewDidLoad() {
        super.viewDidLoad()
        title = "注册"
        view.backgroundColor = Theme.pageBackground
        setupForm()
        setupKeyboardDismiss()
    }

    deinit {
        countdownTimer?.invalidate()
    }

    private func setupForm() {
        titleLabel.text = "注册"
        titleLabel.font = UIFont.boldSystemFont(ofSize: 36)
        titleLabel.textColor = Theme.textPrimary
        titleLabel.textAlignment = .center

        configureOutlined(box: phoneBox, field: phoneField, placeholder: "手机号", secure: false, keyboard: .phonePad)
        configureOutlined(box: usernameBox, field: usernameField, placeholder: "用户名", secure: false, keyboard: .default)
        configureOutlined(box: passwordBox, field: passwordField, placeholder: "密码", secure: true, keyboard: .default)
        configureOutlined(box: confirmBox, field: confirmField, placeholder: "确认密码", secure: true, keyboard: .default)
        configureOutlined(box: codeBox, field: codeField, placeholder: "验证码（4位数字之和为20）", secure: false, keyboard: .numberPad)

        sendCodeButton.setTitle("发送验证码", for: .normal)
        sendCodeButton.setTitleColor(Theme.primary, for: .normal)
        sendCodeButton.addTarget(self, action: #selector(sendCode), for: .touchUpInside)

        registerButton.setTitle("注册", for: .normal)
        registerButton.backgroundColor = Theme.primary
        registerButton.setTitleColor(.white, for: .normal)
        registerButton.titleLabel?.font = UIFont.boldSystemFont(ofSize: 18)
        registerButton.layer.cornerRadius = 12
        registerButton.heightAnchor.constraint(equalToConstant: 56).isActive = true
        registerButton.addTarget(self, action: #selector(registerTap), for: .touchUpInside)

        let codeRow = UIStackView(arrangedSubviews: [codeBox, sendCodeButton])
        codeRow.axis = .horizontal
        codeRow.spacing = 8
        codeRow.alignment = .center
        codeRow.distribution = .fill
        sendCodeButton.setContentHuggingPriority(.required, for: .horizontal)

        let stack = UIStackView(arrangedSubviews: [
            titleLabel, phoneBox, usernameBox, passwordBox, confirmBox, codeRow, registerButton
        ])
        stack.axis = .vertical
        stack.spacing = 20
        stack.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(stack)

        let guide = view.safeAreaLayoutGuide
        NSLayoutConstraint.activate([
            stack.leadingAnchor.constraint(equalTo: guide.leadingAnchor, constant: 20),
            stack.trailingAnchor.constraint(equalTo: guide.trailingAnchor, constant: -20),
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
        field.delegate = self
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

    private func setupKeyboardDismiss() {
        phoneField.returnKeyType = .next
        usernameField.returnKeyType = .next
        passwordField.returnKeyType = .next
        confirmField.returnKeyType = .next
        codeField.returnKeyType = .done

        let doneBar = UIToolbar()
        doneBar.sizeToFit()
        let flex = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
        let done = UIBarButtonItem(title: "完成", style: .done, target: self, action: #selector(dismissKeyboard))
        doneBar.items = [flex, done]
        phoneField.inputAccessoryView = doneBar
        codeField.inputAccessoryView = doneBar

        let tap = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        tap.cancelsTouchesInView = false
        view.addGestureRecognizer(tap)
    }

    @objc private func dismissKeyboard() {
        view.endEditing(true)
    }

    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        switch textField {
        case phoneField:
            usernameField.becomeFirstResponder()
        case usernameField:
            passwordField.becomeFirstResponder()
        case passwordField:
            confirmField.becomeFirstResponder()
        case confirmField:
            codeField.becomeFirstResponder()
        default:
            dismissKeyboard()
        }
        return true
    }

    @objc private func onFieldBegin(_ t: UITextField) {
        (t.superview)?.layer.borderColor = Theme.primary.cgColor
        (t.superview)?.layer.borderWidth = 2 / UIScreen.main.scale
    }

    @objc private func onFieldEnd(_ t: UITextField) {
        (t.superview)?.layer.borderColor = Theme.border.cgColor
        (t.superview)?.layer.borderWidth = 1 / UIScreen.main.scale
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
