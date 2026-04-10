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
        if !selectMode && !a.isDefault {
            let deleteButton = makeDeleteButton(index: indexPath.row)
            cell.accessoryType = .none
            cell.accessoryView = deleteButton
        } else {
            cell.accessoryView = nil
            cell.accessoryType = .disclosureIndicator
        }
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
            self.confirmDelete(address: address, tableView: tableView, completion: done)
        }
        return UISwipeActionsConfiguration(actions: [delete])
    }

    @objc private func deleteButtonTapped(_ sender: UIButton) {
        let idx = sender.tag
        guard idx >= 0, idx < addresses.count else { return }
        confirmDelete(address: addresses[idx], tableView: tableView, completion: nil)
    }

    private func makeDeleteButton(index: Int) -> UIButton {
        let b = UIButton(type: .system)
        // accessoryView 在部分系统下可能不按 intrinsic size 布局，给固定 frame 保证可见
        b.frame = CGRect(x: 0, y: 0, width: 52, height: 30)
        b.setTitle("删除", for: .normal)
        b.setTitleColor(.systemRed, for: .normal)
        b.titleLabel?.font = UIFont.systemFont(ofSize: 14, weight: .semibold)
        b.layer.cornerRadius = 6
        b.layer.borderWidth = 1
        b.layer.borderColor = UIColor.systemRed.cgColor
        b.contentEdgeInsets = UIEdgeInsets(top: 2, left: 8, bottom: 2, right: 8)
        b.tag = index
        b.addTarget(self, action: #selector(deleteButtonTapped(_:)), for: .touchUpInside)
        return b
    }

    private func confirmDelete(address: Address, tableView: UITableView, completion: ((Bool) -> Void)?) {
        if address.isDefault {
            let ac = UIAlertController(title: "提示", message: "默认地址不能删除", preferredStyle: .alert)
            ac.addAction(UIAlertAction(title: "确定", style: .default) { _ in completion?(true) })
            present(ac, animated: true)
            return
        }
        let confirm = UIAlertController(title: "删除地址", message: "确定要删除该收货地址吗？", preferredStyle: .alert)
        confirm.addAction(UIAlertAction(title: "取消", style: .cancel) { _ in completion?(true) })
        confirm.addAction(UIAlertAction(title: "删除", style: .destructive) { _ in
            AddressManager.removeAddress(address.id)
            self.addresses = AddressManager.getAllAddresses()
            tableView.reloadData()
            self.emptyStack.isHidden = !self.addresses.isEmpty
            tableView.isHidden = self.addresses.isEmpty
            completion?(true)
        })
        present(confirm, animated: true)
    }

    @objc private func addAddress() {
        navigationController?.pushViewController(AddressEditViewController(address: nil), animated: true)
    }
}
