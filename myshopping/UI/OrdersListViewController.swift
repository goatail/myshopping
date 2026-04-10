//
//  OrdersListViewController.swift
//  myshopping
//
//  对应各 Pending*Activity：单状态列表
//

import UIKit

final class OrdersListViewController: UIViewController, UITableViewDataSource {

    private let status: String
    private let screenTitle: String
    private let tableView = UITableView(frame: .zero, style: .plain)
    private let emptyStack: UIStackView
    private var orders: [Order] = []

    init(status: String, screenTitle: String) {
        self.status = status
        self.screenTitle = screenTitle
        self.emptyStack = EmptyStateStack.make(
            title: "暂无相关订单",
            subtitle: "您还没有该类订单，去首页逛逛吧~"
        )
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        self.status = ""
        self.screenTitle = ""
        self.emptyStack = EmptyStateStack.make(title: "", subtitle: "")
        super.init(coder: coder)
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        title = screenTitle
        view.backgroundColor = UIColor(white: 0.96, alpha: 1)
        tableView.backgroundColor = view.backgroundColor
        tableView.dataSource = self
        tableView.register(OrderCardTableViewCell.self, forCellReuseIdentifier: OrderCardTableViewCell.reuseId)
        tableView.rowHeight = UITableView.automaticDimension
        tableView.estimatedRowHeight = 220
        tableView.separatorStyle = .none
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
        orders = OrderManager.getOrdersByStatus(status).sorted { $0.createTime > $1.createTime }
        tableView.reloadData()
        let empty = orders.isEmpty
        emptyStack.isHidden = !empty
        tableView.isHidden = empty
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return orders.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: OrderCardTableViewCell.reuseId, for: indexPath) as! OrderCardTableViewCell
        cell.configure(order: orders[indexPath.row])
        return cell
    }
}
