//
//  AddressListViewController.swift
//  myshopping
//
//  对应 Android AddressListActivity（简化）
//

import UIKit

final class AddressListViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {

    var onPick: ((String) -> Void)?
    private let selectMode: Bool
    private let tableView = UITableView(frame: .zero, style: .plain)
    private let emptyStack: UIStackView
    private var addresses: [Address] = []

    init(selectMode: Bool) {
        self.selectMode = selectMode
        self.emptyStack = EmptyStateStack.make(
            title: "暂无收货地址",
            subtitle: selectMode
                ? "请先在「我的 → 收货地址」中添加地址"
                : "点击右上角「+」添加新地址"
        )
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        self.selectMode = false
        self.emptyStack = EmptyStateStack.make(title: "", subtitle: "")
        super.init(coder: coder)
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        title = selectMode ? "选择收货地址" : "收货地址"
        view.backgroundColor = UIColor(white: 0.96, alpha: 1)

        // 与 Android AddressListActivity：选择模式下隐藏 FAB（新增）
        if !selectMode {
            navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(addAddress))
        }

        tableView.dataSource = self
        tableView.delegate = self
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "a")
        tableView.backgroundColor = view.backgroundColor
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.contentInsetAdjustmentBehavior = .never
        view.addSubview(tableView)
        view.addSubview(emptyStack)

        let guide = view.safeAreaLayoutGuide
        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: guide.topAnchor),
            tableView.leadingAnchor.constraint(equalTo: guide.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: guide.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: guide.bottomAnchor),

            emptyStack.centerXAnchor.constraint(equalTo: guide.centerXAnchor),
            emptyStack.centerYAnchor.constraint(equalTo: guide.centerYAnchor)
        ])
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        addresses = AddressManager.getAllAddresses()
        tableView.reloadData()
        let empty = addresses.isEmpty
        emptyStack.isHidden = !empty
        tableView.isHidden = empty
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return addresses.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "a", for: indexPath)
        let a = addresses[indexPath.row]
        cell.textLabel?.numberOfLines = 0
        cell.textLabel?.text = a.displayText() + (a.isDefault ? "\n【默认】" : "")
        cell.accessoryType = .disclosureIndicator
        return cell
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let a = addresses[indexPath.row]
        if selectMode {
            onPick?(a.id)
            navigationController?.popViewController(animated: true)
        } else {
            navigationController?.pushViewController(AddressEditViewController(address: a), animated: true)
        }
    }

    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        guard !selectMode else { return nil }
        let address = addresses[indexPath.row]
        let delete = UIContextualAction(style: .destructive, title: "删除") { [weak self] _, _, done in
            guard let self = self else {
                done(false)
                return
            }
            if address.isDefault {
                let ac = UIAlertController(title: "提示", message: "默认地址不能删除", preferredStyle: .alert)
                ac.addAction(UIAlertAction(title: "确定", style: .default) { _ in done(true) })
                self.present(ac, animated: true)
                return
            }
            let confirm = UIAlertController(title: "删除地址", message: "确定要删除该收货地址吗？", preferredStyle: .alert)
            confirm.addAction(UIAlertAction(title: "取消", style: .cancel) { _ in done(true) })
            confirm.addAction(UIAlertAction(title: "删除", style: .destructive) { _ in
                AddressManager.removeAddress(address.id)
                self.addresses = AddressManager.getAllAddresses()
                tableView.reloadData()
                done(true)
            })
            self.present(confirm, animated: true)
        }
        return UISwipeActionsConfiguration(actions: [delete])
    }

    @objc private func addAddress() {
        navigationController?.pushViewController(AddressEditViewController(address: nil), animated: true)
    }
}
