//
//  ProfileViewController.swift
//  myshopping
//
//  对应 Android ProfileFragment（抽屉简化为弹窗菜单）
//

import UIKit

final class ProfileViewController: UIViewController {

    private let scrollView = UIScrollView()
    private let contentStack = UIStackView()

    private let headerView = UIView()
    private let settingsButton = UIButton(type: .system)
    private let avatarView = UIImageView()
    private let usernameLabel = UILabel()
    private let phoneLabel = UILabel()

    private var cardOrders = UIView()
    private let countPay = UILabel()
    private let countShip = UILabel()
    private let countRecv = UILabel()
    private let countReview = UILabel()
    private let countRefund = UILabel()

    private var cardMenu = UIView()
    private let logoutButton = UIButton(type: .system)

    private var headerGradient: CAGradientLayer?

    override func viewDidLoad() {
        super.viewDidLoad()
        // 导航栏不显示标题；底部 Tab 文案在 viewWillAppear 恢复
        title = ""
        view.backgroundColor = UIColor(white: 0.96, alpha: 1)

        // Android 顶部是设置图标按钮；iOS 用同样入口（同时保留「设置」文案操作表）
        navigationItem.rightBarButtonItem = nil

        scrollView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(scrollView)

        contentStack.axis = .vertical
        contentStack.spacing = 12
        contentStack.translatesAutoresizingMaskIntoConstraints = false
        scrollView.addSubview(contentStack)

        buildHeader()
        buildOrdersCard()
        buildMenuCard()
        buildLogoutButton()

        contentStack.addArrangedSubview(headerView)
        contentStack.addArrangedSubview(cardOrders)
        contentStack.addArrangedSubview(cardMenu)
        contentStack.addArrangedSubview(logoutButton)

        let guide = view.safeAreaLayoutGuide
        NSLayoutConstraint.activate([
            scrollView.topAnchor.constraint(equalTo: guide.topAnchor),
            scrollView.leadingAnchor.constraint(equalTo: guide.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: guide.trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: guide.bottomAnchor),

            contentStack.topAnchor.constraint(equalTo: scrollView.contentLayoutGuide.topAnchor),
            contentStack.leadingAnchor.constraint(equalTo: scrollView.frameLayoutGuide.leadingAnchor),
            contentStack.trailingAnchor.constraint(equalTo: scrollView.frameLayoutGuide.trailingAnchor),
            contentStack.bottomAnchor.constraint(equalTo: scrollView.contentLayoutGuide.bottomAnchor, constant: -16),
            contentStack.widthAnchor.constraint(equalTo: scrollView.frameLayoutGuide.widthAnchor)
        ])
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        headerGradient?.frame = headerView.bounds
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.tabBarItem?.title = "我的"
        refreshUser()
        refreshCounts()
    }

    private func refreshUser() {
        let u = UserManager.currentUsername()
        let p = UserManager.currentPhone()
        usernameLabel.text = u.isEmpty ? "未登录" : u
        phoneLabel.text = p.isEmpty ? "请登录" : p
    }

    private func refreshCounts() {
        countPay.text = "\(OrderManager.getPendingPaymentCount())"
        countShip.text = "\(OrderManager.getPendingShipmentCount())"
        countRecv.text = "\(OrderManager.getPendingReceiptCount())"
        countReview.text = "\(OrderManager.getPendingReviewCount())"
        countRefund.text = "\(OrderManager.getRefundCount())"
    }

    private func buildHeader() {
        headerView.translatesAutoresizingMaskIntoConstraints = false
        headerView.heightAnchor.constraint(greaterThanOrEqualToConstant: 170).isActive = true

        // Android: profile_header_background (渐变 #FF6B6B -> #FF5722 -> #E91E63)
        let g = CAGradientLayer()
        g.colors = [UIColor(hex: 0xFF6B6B).cgColor, UIColor(hex: 0xFF5722).cgColor, UIColor(hex: 0xE91E63).cgColor]
        g.startPoint = CGPoint(x: 1, y: 0)
        g.endPoint = CGPoint(x: 0, y: 1)
        headerView.layer.insertSublayer(g, at: 0)
        headerGradient = g

        let topRow = UIView()
        topRow.translatesAutoresizingMaskIntoConstraints = false

        settingsButton.translatesAutoresizingMaskIntoConstraints = false
        settingsButton.tintColor = .white
        if #available(iOS 13.0, *) {
            settingsButton.setImage(UIImage(systemName: "gearshape"), for: .normal)
        } else {
            settingsButton.setTitle("设置", for: .normal)
            settingsButton.setTitleColor(.white, for: .normal)
        }
        settingsButton.backgroundColor = UIColor(white: 1, alpha: 0.18)
        settingsButton.layer.cornerRadius = 20
        settingsButton.addTarget(self, action: #selector(openSettings), for: .touchUpInside)

        topRow.addSubview(settingsButton)
        NSLayoutConstraint.activate([
            settingsButton.widthAnchor.constraint(equalToConstant: 40),
            settingsButton.heightAnchor.constraint(equalToConstant: 40),
            settingsButton.trailingAnchor.constraint(equalTo: topRow.trailingAnchor, constant: -16),
            settingsButton.topAnchor.constraint(equalTo: topRow.topAnchor)
        ])

        avatarView.translatesAutoresizingMaskIntoConstraints = false
        avatarView.contentMode = .center
        avatarView.backgroundColor = UIColor(white: 0.88, alpha: 1)
        avatarView.layer.cornerRadius = 32
        avatarView.clipsToBounds = true
        if #available(iOS 13.0, *) {
            avatarView.image = UIImage(systemName: "person.fill")
            avatarView.tintColor = UIColor(white: 0.55, alpha: 1)
        }

        usernameLabel.font = UIFont.boldSystemFont(ofSize: 20)
        usernameLabel.textColor = .white
        phoneLabel.font = UIFont.systemFont(ofSize: 14)
        phoneLabel.textColor = UIColor(white: 1, alpha: 0.88)

        let nameStack = UIStackView(arrangedSubviews: [usernameLabel, phoneLabel])
        nameStack.axis = .vertical
        nameStack.spacing = 4
        nameStack.translatesAutoresizingMaskIntoConstraints = false

        let chevron = UIImageView()
        chevron.translatesAutoresizingMaskIntoConstraints = false
        if #available(iOS 13.0, *) {
            chevron.image = UIImage(systemName: "chevron.right")
            chevron.tintColor = UIColor(white: 1, alpha: 0.9)
        }

        let userRow = UIStackView(arrangedSubviews: [avatarView, nameStack, UIView(), chevron])
        userRow.axis = .horizontal
        userRow.alignment = .center
        userRow.spacing = 12
        userRow.translatesAutoresizingMaskIntoConstraints = false

        headerView.addSubview(topRow)
        headerView.addSubview(userRow)

        NSLayoutConstraint.activate([
            topRow.topAnchor.constraint(equalTo: headerView.topAnchor, constant: 48),
            topRow.leadingAnchor.constraint(equalTo: headerView.leadingAnchor),
            topRow.trailingAnchor.constraint(equalTo: headerView.trailingAnchor),

            avatarView.widthAnchor.constraint(equalToConstant: 64),
            avatarView.heightAnchor.constraint(equalToConstant: 64),

            userRow.topAnchor.constraint(equalTo: topRow.bottomAnchor, constant: 16),
            userRow.leadingAnchor.constraint(equalTo: headerView.leadingAnchor, constant: 16),
            userRow.trailingAnchor.constraint(equalTo: headerView.trailingAnchor, constant: -16),
            userRow.bottomAnchor.constraint(equalTo: headerView.bottomAnchor, constant: -24)
        ])
    }

    private func makeCard() -> UIView {
        let v = UIView()
        v.backgroundColor = .white
        v.layer.cornerRadius = 6
        v.layer.borderWidth = 1 / UIScreen.main.scale
        v.layer.borderColor = UIColor(white: 0.9, alpha: 1).cgColor
        v.translatesAutoresizingMaskIntoConstraints = false
        return v
    }

    private func buildOrdersCard() {
        cardOrders = makeCard()
        cardOrders.layoutMargins = UIEdgeInsets(top: 12, left: 12, bottom: 12, right: 12)

        let title = UILabel()
        title.text = "我的订单"
        title.font = UIFont.boldSystemFont(ofSize: 12)
        title.textColor = .black

        // 小屏避免 5 等分溢出：改为横向可滚动 + 固定最小宽高，点击更容易命中
        let shortcuts = UIStackView(arrangedSubviews: [
            makeOrderShortcut(countLabel: countPay, text: "待付款", action: #selector(goPay)),
            makeOrderShortcut(countLabel: countShip, text: "待发货", action: #selector(goShip)),
            makeOrderShortcut(countLabel: countRecv, text: "待收货", action: #selector(goRecv)),
            makeOrderShortcut(countLabel: countReview, text: "待评价", action: #selector(goReview)),
            makeOrderShortcut(countLabel: countRefund, text: "退款/售后", action: #selector(goRefund))
        ])
        shortcuts.axis = .horizontal
        shortcuts.alignment = .fill
        shortcuts.distribution = .fill
        shortcuts.spacing = 4
        shortcuts.translatesAutoresizingMaskIntoConstraints = false

        let scroll = UIScrollView()
        scroll.translatesAutoresizingMaskIntoConstraints = false
        scroll.showsHorizontalScrollIndicator = false
        scroll.alwaysBounceHorizontal = true
        // 避免 ScrollView 抢占点击导致“点不到/不触发”
        scroll.delaysContentTouches = false
        // 关键：不要在识别到滚动时取消按钮点击（否则轻微手抖就只剩“点边缘”才触发）
        scroll.canCancelContentTouches = false
        scroll.panGestureRecognizer.cancelsTouchesInView = false
        scroll.addSubview(shortcuts)
        NSLayoutConstraint.activate([
            shortcuts.topAnchor.constraint(equalTo: scroll.contentLayoutGuide.topAnchor),
            shortcuts.bottomAnchor.constraint(equalTo: scroll.contentLayoutGuide.bottomAnchor),
            shortcuts.leadingAnchor.constraint(equalTo: scroll.contentLayoutGuide.leadingAnchor),
            shortcuts.trailingAnchor.constraint(equalTo: scroll.contentLayoutGuide.trailingAnchor),
            shortcuts.heightAnchor.constraint(equalTo: scroll.frameLayoutGuide.heightAnchor)
        ])

        let stack = UIStackView(arrangedSubviews: [title, scroll])
        stack.axis = .vertical
        stack.spacing = 12
        stack.translatesAutoresizingMaskIntoConstraints = false

        cardOrders.addSubview(stack)
        NSLayoutConstraint.activate([
            stack.topAnchor.constraint(equalTo: cardOrders.topAnchor, constant: 12),
            stack.leadingAnchor.constraint(equalTo: cardOrders.leadingAnchor, constant: 12),
            stack.trailingAnchor.constraint(equalTo: cardOrders.trailingAnchor, constant: -12),
            stack.bottomAnchor.constraint(equalTo: cardOrders.bottomAnchor, constant: -12),
            // 固定滚动区域高度，保证按钮有稳定命中区域（小屏也不挤压到 0）
            scroll.heightAnchor.constraint(equalToConstant: 84)
        ])
    }

    private func makeOrderShortcut(countLabel: UILabel, text: String, action: Selector) -> UIControl {
        // 用 UIButton（比 UIControl 更符合点击语义，触发更稳定）
        let control = UIButton(type: .system)
        control.addTarget(self, action: action, for: .touchUpInside)
        control.isExclusiveTouch = true
        control.layer.cornerRadius = 8
        control.backgroundColor = UIColor(white: 0.98, alpha: 1)
        control.clipsToBounds = true

        countLabel.text = "0"
        countLabel.font = UIFont.boldSystemFont(ofSize: 18)
        countLabel.textColor = UIColor(hex: 0xFF5722)
        countLabel.textAlignment = .center

        let name = UILabel()
        name.text = text
        name.font = UIFont.systemFont(ofSize: 10)
        name.textColor = UIColor(white: 0.4, alpha: 1)
        name.textAlignment = .center
        name.numberOfLines = 2

        let stack = UIStackView(arrangedSubviews: [countLabel, name])
        stack.axis = .vertical
        stack.spacing = 4
        stack.alignment = .center
        stack.translatesAutoresizingMaskIntoConstraints = false
        // 关键：让触摸命中落在按钮本体上，而不是被 UIStackView 吃掉
        stack.isUserInteractionEnabled = false
        control.addSubview(stack)
        NSLayoutConstraint.activate([
            // 点击区域与内容都填满，避免“点不到”
            stack.leadingAnchor.constraint(equalTo: control.leadingAnchor, constant: 8),
            stack.trailingAnchor.constraint(equalTo: control.trailingAnchor, constant: -8),
            stack.centerYAnchor.constraint(equalTo: control.centerYAnchor),
            control.heightAnchor.constraint(greaterThanOrEqualToConstant: 72),
            control.widthAnchor.constraint(greaterThanOrEqualToConstant: 72)
        ])
        return control
    }

    private func buildMenuCard() {
        cardMenu = makeCard()

        let v = UIStackView(arrangedSubviews: [
            makeMenuRow(title: "我的订单", action: #selector(goMyOrders)),
            makeDivider(),
            makeMenuRow(title: "收货地址", action: #selector(goAddress)),
            makeDivider(),
            makeMenuRow(title: "我的收藏", action: #selector(goFavoriteTab))
        ])
        v.axis = .vertical
        v.spacing = 0
        v.translatesAutoresizingMaskIntoConstraints = false
        cardMenu.addSubview(v)
        NSLayoutConstraint.activate([
            v.topAnchor.constraint(equalTo: cardMenu.topAnchor, constant: 8),
            v.leadingAnchor.constraint(equalTo: cardMenu.leadingAnchor, constant: 8),
            v.trailingAnchor.constraint(equalTo: cardMenu.trailingAnchor, constant: -8),
            v.bottomAnchor.constraint(equalTo: cardMenu.bottomAnchor, constant: -8)
        ])
    }

    private func makeMenuRow(title: String, action: Selector) -> UIControl {
        let c = UIControl()
        c.addTarget(self, action: action, for: .touchUpInside)
        c.translatesAutoresizingMaskIntoConstraints = false
        c.heightAnchor.constraint(equalToConstant: 48).isActive = true

        let label = UILabel()
        label.text = title
        label.font = UIFont.systemFont(ofSize: 12)
        label.textColor = .black
        label.translatesAutoresizingMaskIntoConstraints = false

        let chevron = UIImageView()
        chevron.translatesAutoresizingMaskIntoConstraints = false
        if #available(iOS 13.0, *) {
            chevron.image = UIImage(systemName: "chevron.right")
            chevron.tintColor = UIColor(white: 0.8, alpha: 1)
        }

        c.addSubview(label)
        c.addSubview(chevron)
        NSLayoutConstraint.activate([
            label.leadingAnchor.constraint(equalTo: c.leadingAnchor, constant: 8),
            label.centerYAnchor.constraint(equalTo: c.centerYAnchor),
            chevron.trailingAnchor.constraint(equalTo: c.trailingAnchor, constant: -8),
            chevron.centerYAnchor.constraint(equalTo: c.centerYAnchor)
        ])
        return c
    }

    private func makeDivider() -> UIView {
        let v = UIView()
        v.backgroundColor = UIColor(white: 0.88, alpha: 1)
        v.heightAnchor.constraint(equalToConstant: 1 / UIScreen.main.scale).isActive = true
        return v
    }

    private func buildLogoutButton() {
        logoutButton.setTitle("退出登录", for: .normal)
        logoutButton.backgroundColor = UIColor(hex: 0xFF5722)
        logoutButton.setTitleColor(.white, for: .normal)
        logoutButton.titleLabel?.font = UIFont.systemFont(ofSize: 16, weight: .semibold)
        logoutButton.layer.cornerRadius = 8
        logoutButton.addTarget(self, action: #selector(logoutTap), for: .touchUpInside)
        logoutButton.translatesAutoresizingMaskIntoConstraints = false
        logoutButton.heightAnchor.constraint(equalToConstant: 56).isActive = true
        logoutButton.contentEdgeInsets = UIEdgeInsets(top: 0, left: 16, bottom: 0, right: 16)
    }

    @objc private func openSettings() {
        let ac = UIAlertController(title: "设置", message: nil, preferredStyle: .actionSheet)
        ac.addAction(UIAlertAction(title: "收货地址", style: .default, handler: { [weak self] _ in
            self?.navigationController?.pushViewController(AddressListViewController(selectMode: false), animated: true)
        }))
        ac.addAction(UIAlertAction(title: "应用设置（占位）", style: .default, handler: { _ in }))
        ac.addAction(UIAlertAction(title: "取消", style: .cancel))
        if let pop = ac.popoverPresentationController {
            pop.sourceView = settingsButton
            pop.sourceRect = settingsButton.bounds
        }
        present(ac, animated: true)
    }

    @objc private func goPay() {
        navigationController?.pushViewController(OrdersListViewController(status: "待付款", screenTitle: "待付款"), animated: true)
    }
    @objc private func goShip() {
        navigationController?.pushViewController(OrdersListViewController(status: "待发货", screenTitle: "待发货"), animated: true)
    }
    @objc private func goRecv() {
        navigationController?.pushViewController(OrdersListViewController(status: "待收货", screenTitle: "待收货"), animated: true)
    }
    @objc private func goReview() {
        navigationController?.pushViewController(OrdersListViewController(status: "待评价", screenTitle: "待评价"), animated: true)
    }
    @objc private func goRefund() {
        navigationController?.pushViewController(OrdersListViewController(status: "退款/售后", screenTitle: "退款/售后"), animated: true)
    }
    @objc private func goMyOrders() {
        navigationController?.pushViewController(MyOrdersViewController(), animated: true)
    }
    @objc private func goAddress() {
        navigationController?.pushViewController(AddressListViewController(selectMode: false), animated: true)
    }
    @objc private func goFavoriteTab() {
        tabBarController?.selectedIndex = 1
    }

    @objc private func logoutTap() {
        UserManager.logout()
        let ac = UIAlertController(title: nil, message: "已退出登录", preferredStyle: .alert)
        ac.addAction(UIAlertAction(title: "确定", style: .default, handler: { [weak self] _ in
            guard let self = self else { return }
            RootSwitcher.replaceRoot(from: self, with: LoginFlow.makeLoginNavigationController(), animated: true)
        }))
        present(ac, animated: true)
    }
}
