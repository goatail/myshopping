//
//  CartViewController.swift
//  myshopping
//
//  对应 Android CartFragment + CartAdapter + fragment_cart
//

import UIKit

final class CartViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {

    /// 与 Android colors.xml 中主色一致
    private static let accentOrange = UIColor(red: 1, green: 0.34, blue: 0.13, alpha: 1)

    private let tableView = UITableView(frame: .zero, style: .plain)
    private let totalLabel = UILabel()
    private let checkoutButton = UIButton(type: .system)
    private let bottomBar = UIView()
    private let bottomInner = UIStackView()
    private let emptyStack = UIStackView()

    override func viewDidLoad() {
        super.viewDidLoad()
        // 导航栏不显示标题；底部 Tab 文案在 viewWillAppear 恢复
        title = ""
        view.backgroundColor = UIColor(white: 0.96, alpha: 1)

        totalLabel.font = UIFont.boldSystemFont(ofSize: 18)
        totalLabel.textColor = CartViewController.accentOrange
        totalLabel.translatesAutoresizingMaskIntoConstraints = false

        checkoutButton.setTitle("结算", for: .normal)
        checkoutButton.backgroundColor = CartViewController.accentOrange
        checkoutButton.setTitleColor(.white, for: .normal)
        checkoutButton.titleLabel?.font = UIFont.boldSystemFont(ofSize: 16)
        checkoutButton.layer.cornerRadius = 8
        checkoutButton.contentEdgeInsets = UIEdgeInsets(top: 0, left: 24, bottom: 0, right: 24)
        checkoutButton.addTarget(self, action: #selector(checkout), for: .touchUpInside)
        checkoutButton.translatesAutoresizingMaskIntoConstraints = false
        checkoutButton.setContentHuggingPriority(.required, for: .horizontal)

        bottomInner.axis = .horizontal
        bottomInner.spacing = 16
        bottomInner.alignment = .center
        bottomInner.distribution = .fill
        bottomInner.addArrangedSubview(totalLabel)
        bottomInner.addArrangedSubview(checkoutButton)
        bottomInner.translatesAutoresizingMaskIntoConstraints = false

        bottomBar.backgroundColor = .white
        bottomBar.layer.shadowColor = UIColor.black.cgColor
        bottomBar.layer.shadowOpacity = 0.08
        bottomBar.layer.shadowOffset = CGSize(width: 0, height: -1)
        bottomBar.layer.shadowRadius = 4
        bottomBar.translatesAutoresizingMaskIntoConstraints = false
        bottomBar.addSubview(bottomInner)

        tableView.dataSource = self
        tableView.delegate = self
        tableView.backgroundColor = view.backgroundColor
        tableView.separatorInset = UIEdgeInsets(top: 0, left: 16, bottom: 0, right: 16)
        tableView.register(CartItemTableViewCell.self, forCellReuseIdentifier: CartItemTableViewCell.reuseId)
        tableView.rowHeight = UITableView.automaticDimension
        tableView.estimatedRowHeight = 120
        tableView.tableFooterView = UIView()
        tableView.translatesAutoresizingMaskIntoConstraints = false

        let emptyTitle = UILabel()
        emptyTitle.text = "购物车是空的"
        emptyTitle.textAlignment = .center
        emptyTitle.textColor = UIColor(white: 0.6, alpha: 1)
        emptyTitle.font = UIFont.systemFont(ofSize: 16)
        let emptySub = UILabel()
        emptySub.text = "快去选购心仪的商品吧~"
        emptySub.textAlignment = .center
        emptySub.textColor = UIColor(white: 0.8, alpha: 1)
        emptySub.font = UIFont.systemFont(ofSize: 14)
        emptyStack.axis = .vertical
        emptyStack.spacing = 8
        emptyStack.addArrangedSubview(emptyTitle)
        emptyStack.addArrangedSubview(emptySub)
        emptyStack.isHidden = true
        emptyStack.translatesAutoresizingMaskIntoConstraints = false

        view.addSubview(tableView)
        view.addSubview(bottomBar)
        view.addSubview(emptyStack)

        let guide = view.safeAreaLayoutGuide
        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: guide.topAnchor),
            tableView.leadingAnchor.constraint(equalTo: guide.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: guide.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: bottomBar.topAnchor),

            bottomBar.leadingAnchor.constraint(equalTo: guide.leadingAnchor),
            bottomBar.trailingAnchor.constraint(equalTo: guide.trailingAnchor),
            bottomBar.bottomAnchor.constraint(equalTo: guide.bottomAnchor),

            bottomInner.leadingAnchor.constraint(equalTo: bottomBar.leadingAnchor, constant: 16),
            bottomInner.trailingAnchor.constraint(equalTo: bottomBar.trailingAnchor, constant: -16),
            bottomInner.topAnchor.constraint(equalTo: bottomBar.topAnchor, constant: 16),
            bottomInner.bottomAnchor.constraint(equalTo: bottomBar.bottomAnchor, constant: -16),

            checkoutButton.heightAnchor.constraint(equalToConstant: 56),
            checkoutButton.widthAnchor.constraint(greaterThanOrEqualToConstant: 120),

            emptyStack.centerXAnchor.constraint(equalTo: guide.centerXAnchor),
            emptyStack.centerYAnchor.constraint(equalTo: guide.centerYAnchor)
        ])
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.tabBarItem?.title = "购物车"
        refresh()
    }

    private func refresh() {
        tableView.reloadData()
        let items = CartManager.getCartItems()
        let total = CartManager.getTotalPrice()
        totalLabel.text = String(format: "总计：¥%.2f", total)
        let empty = items.isEmpty
        emptyStack.isHidden = !empty
        tableView.isHidden = empty
        bottomBar.isHidden = empty
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return CartManager.getCartItems().count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: CartItemTableViewCell.reuseId, for: indexPath) as! CartItemTableViewCell
        let item = CartManager.getCartItems()[indexPath.row]
        cell.configure(item: item) { [weak self] in
            self?.refresh()
        }
        return cell
    }

    @objc private func checkout() {
        let items = CartManager.getCartItems()
        if items.isEmpty {
            let ac = UIAlertController(title: nil, message: "购物车为空", preferredStyle: .alert)
            ac.addAction(UIAlertAction(title: "确定", style: .default))
            present(ac, animated: true)
            return
        }
        navigationController?.pushViewController(CheckoutViewController(), animated: true)
    }
}
