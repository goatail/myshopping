//
//  ProfileViewController.swift
//  myshopping
//
//  对应 Android ProfileFragment（抽屉简化为弹窗菜单）
//

import UIKit

final class ProfileViewController: UIViewController {

    private let scrollView = UIScrollView()
    private let usernameLabel = UILabel()
    private let phoneLabel = UILabel()
    private let countsStack = UIStackView()

    override func viewDidLoad() {
        super.viewDidLoad()
        title = "我的"
        view.backgroundColor = UIColor(white: 0.96, alpha: 1)

        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "设置", style: .plain, target: self, action: #selector(openSettings))

        scrollView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(scrollView)

        let content = UIStackView()
        content.axis = .vertical
        content.spacing = 16
        content.translatesAutoresizingMaskIntoConstraints = false

        let header = UIView()
        header.backgroundColor = UIColor(red: 0.35, green: 0.55, blue: 0.95, alpha: 1)
        header.layer.cornerRadius = 12
        header.translatesAutoresizingMaskIntoConstraints = false

        usernameLabel.font = UIFont.boldSystemFont(ofSize: 20)
        usernameLabel.textColor = .white
        phoneLabel.font = UIFont.systemFont(ofSize: 14)
        phoneLabel.textColor = UIColor(white: 1, alpha: 0.85)

        let headerStack = UIStackView(arrangedSubviews: [usernameLabel, phoneLabel])
        headerStack.axis = .vertical
        headerStack.spacing = 6
        headerStack.translatesAutoresizingMaskIntoConstraints = false
        header.addSubview(headerStack)

        NSLayoutConstraint.activate([
            header.heightAnchor.constraint(greaterThanOrEqualToConstant: 100),
            headerStack.leadingAnchor.constraint(equalTo: header.leadingAnchor, constant: 16),
            headerStack.trailingAnchor.constraint(equalTo: header.trailingAnchor, constant: -16),
            headerStack.centerYAnchor.constraint(equalTo: header.centerYAnchor)
        ])

        countsStack.axis = .vertical
        countsStack.spacing = 8
        countsStack.translatesAutoresizingMaskIntoConstraints = false
        buildOrderShortcuts()

        let logout = UIButton(type: .system)
        logout.setTitle("退出登录", for: .normal)
        logout.backgroundColor = .white
        logout.layer.cornerRadius = 8
        logout.addTarget(self, action: #selector(logoutTap), for: .touchUpInside)
        logout.translatesAutoresizingMaskIntoConstraints = false

        content.addArrangedSubview(header)
        content.addArrangedSubview(countsStack)
        content.addArrangedSubview(logout)

        scrollView.addSubview(content)
        let guide = view.safeAreaLayoutGuide
        NSLayoutConstraint.activate([
            scrollView.topAnchor.constraint(equalTo: guide.topAnchor),
            scrollView.leadingAnchor.constraint(equalTo: guide.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: guide.trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: guide.bottomAnchor),

            content.topAnchor.constraint(equalTo: scrollView.contentLayoutGuide.topAnchor, constant: 12),
            content.leadingAnchor.constraint(equalTo: scrollView.frameLayoutGuide.leadingAnchor, constant: 12),
            content.trailingAnchor.constraint(equalTo: scrollView.frameLayoutGuide.trailingAnchor, constant: -12),
            content.bottomAnchor.constraint(equalTo: scrollView.contentLayoutGuide.bottomAnchor, constant: -12),
            content.widthAnchor.constraint(equalTo: scrollView.frameLayoutGuide.widthAnchor, constant: -24)
        ])
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        refreshUser()
        buildOrderShortcuts()
    }

    private func refreshUser() {
        let u = UserManager.currentUsername()
        let p = UserManager.currentPhone()
        usernameLabel.text = u.isEmpty ? "未登录" : u
        phoneLabel.text = p.isEmpty ? "请登录" : p
    }

    private func buildOrderShortcuts() {
        countsStack.arrangedSubviews.forEach { $0.removeFromSuperview() }

        func row(title: String, count: Int, action: Selector) -> UIButton {
            let b = UIButton(type: .system)
            b.contentHorizontalAlignment = .left
            b.setTitle("\(title)  (\(count))", for: .normal)
            b.backgroundColor = .white
            b.layer.cornerRadius = 8
            b.contentEdgeInsets = UIEdgeInsets(top: 12, left: 12, bottom: 12, right: 12)
            b.addTarget(self, action: action, for: .touchUpInside)
            return b
        }

        countsStack.addArrangedSubview(row(title: "待付款", count: OrderManager.getPendingPaymentCount(), action: #selector(goPay)))
        countsStack.addArrangedSubview(row(title: "待发货", count: OrderManager.getPendingShipmentCount(), action: #selector(goShip)))
        countsStack.addArrangedSubview(row(title: "待收货", count: OrderManager.getPendingReceiptCount(), action: #selector(goRecv)))
        countsStack.addArrangedSubview(row(title: "待评价", count: OrderManager.getPendingReviewCount(), action: #selector(goReview)))
        countsStack.addArrangedSubview(row(title: "退款/售后", count: OrderManager.getRefundCount(), action: #selector(goRefund)))

        let myOrders = UIButton(type: .system)
        myOrders.contentHorizontalAlignment = .left
        myOrders.setTitle("我的订单", for: .normal)
        myOrders.backgroundColor = .white
        myOrders.layer.cornerRadius = 8
        myOrders.contentEdgeInsets = UIEdgeInsets(top: 12, left: 12, bottom: 12, right: 12)
        myOrders.addTarget(self, action: #selector(goMyOrders), for: .touchUpInside)

        let addr = UIButton(type: .system)
        addr.contentHorizontalAlignment = .left
        addr.setTitle("收货地址", for: .normal)
        addr.backgroundColor = .white
        addr.layer.cornerRadius = 8
        addr.contentEdgeInsets = UIEdgeInsets(top: 12, left: 12, bottom: 12, right: 12)
        addr.addTarget(self, action: #selector(goAddress), for: .touchUpInside)

        let fav = UIButton(type: .system)
        fav.contentHorizontalAlignment = .left
        fav.setTitle("我的收藏", for: .normal)
        fav.backgroundColor = .white
        fav.layer.cornerRadius = 8
        fav.contentEdgeInsets = UIEdgeInsets(top: 12, left: 12, bottom: 12, right: 12)
        fav.addTarget(self, action: #selector(goFavoriteTab), for: .touchUpInside)

        countsStack.addArrangedSubview(myOrders)
        countsStack.addArrangedSubview(addr)
        countsStack.addArrangedSubview(fav)
    }

    @objc private func openSettings() {
        let ac = UIAlertController(title: "设置", message: nil, preferredStyle: .actionSheet)
        ac.addAction(UIAlertAction(title: "收货地址", style: .default, handler: { [weak self] _ in
            self?.navigationController?.pushViewController(AddressListViewController(selectMode: false), animated: true)
        }))
        ac.addAction(UIAlertAction(title: "应用设置（占位）", style: .default, handler: { _ in }))
        ac.addAction(UIAlertAction(title: "取消", style: .cancel))
        if let pop = ac.popoverPresentationController {
            pop.barButtonItem = navigationItem.rightBarButtonItem
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
