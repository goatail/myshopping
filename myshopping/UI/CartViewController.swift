//
//  CartViewController.swift
//  myshopping
//
//  对应 Android CartFragment
//

import UIKit

final class CartViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {

    private let tableView = UITableView(frame: .zero, style: .plain)
    private let totalLabel = UILabel()
    private let checkoutButton = UIButton(type: .system)
    private let bottomBar = UIStackView()
    private let emptyStack = UIStackView()

    override func viewDidLoad() {
        super.viewDidLoad()
        title = "购物车"
        view.backgroundColor = .white

        totalLabel.font = UIFont.boldSystemFont(ofSize: 16)
        totalLabel.translatesAutoresizingMaskIntoConstraints = false

        checkoutButton.setTitle("结算", for: .normal)
        checkoutButton.backgroundColor = UIColor(red: 1, green: 0.42, blue: 0.2, alpha: 1)
        checkoutButton.setTitleColor(.white, for: .normal)
        checkoutButton.layer.cornerRadius = 8
        checkoutButton.addTarget(self, action: #selector(checkout), for: .touchUpInside)
        checkoutButton.translatesAutoresizingMaskIntoConstraints = false

        bottomBar.arrangedSubviews.forEach { $0.removeFromSuperview() }
        bottomBar.addArrangedSubview(totalLabel)
        bottomBar.addArrangedSubview(checkoutButton)
        bottomBar.axis = .horizontal
        bottomBar.spacing = 16
        bottomBar.distribution = .fillEqually
        bottomBar.translatesAutoresizingMaskIntoConstraints = false

        tableView.dataSource = self
        tableView.delegate = self
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "c")
        tableView.translatesAutoresizingMaskIntoConstraints = false

        let emptyTitle = UILabel()
        emptyTitle.text = "购物车是空的"
        emptyTitle.textAlignment = .center
        let emptySub = UILabel()
        emptySub.text = "去首页逛逛吧"
        emptySub.textAlignment = .center
        emptySub.textColor = .gray
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

            bottomBar.leadingAnchor.constraint(equalTo: guide.leadingAnchor, constant: 16),
            bottomBar.trailingAnchor.constraint(equalTo: guide.trailingAnchor, constant: -16),
            bottomBar.bottomAnchor.constraint(equalTo: guide.bottomAnchor, constant: -12),
            checkoutButton.heightAnchor.constraint(equalToConstant: 44),

            emptyStack.centerXAnchor.constraint(equalTo: guide.centerXAnchor),
            emptyStack.centerYAnchor.constraint(equalTo: guide.centerYAnchor)
        ])
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
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
        let cell = tableView.dequeueReusableCell(withIdentifier: "c", for: indexPath)
        let item = CartManager.getCartItems()[indexPath.row]
        cell.textLabel?.numberOfLines = 2
        cell.textLabel?.text = "\(item.product.name) ×\(item.quantity)    " + String(format: "¥%.2f", item.totalPrice)
        cell.accessoryType = .none
        return cell
    }

    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        if #available(iOS 11.0, *) {
            let del = UIContextualAction(style: .destructive, title: "删除") { _, _, done in
                let id = CartManager.getCartItems()[indexPath.row].product.id
                CartManager.removeFromCart(productId: id)
                self.refresh()
                done(true)
            }
            return UISwipeActionsConfiguration(actions: [del])
        }
        return nil
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
