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
    private var orders: [Order] = []

    init(status: String, screenTitle: String) {
        self.status = status
        self.screenTitle = screenTitle
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        self.status = ""
        self.screenTitle = ""
        super.init(coder: coder)
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        title = screenTitle
        view.backgroundColor = .white
        tableView.dataSource = self
        tableView.register(OrderCardTableViewCell.self, forCellReuseIdentifier: OrderCardTableViewCell.reuseId)
        tableView.rowHeight = UITableView.automaticDimension
        tableView.estimatedRowHeight = 220
        tableView.separatorStyle = .none
        tableView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(tableView)
        let guide = view.safeAreaLayoutGuide
        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: guide.topAnchor),
            tableView.leadingAnchor.constraint(equalTo: guide.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: guide.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: guide.bottomAnchor)
        ])
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        orders = OrderManager.getOrdersByStatus(status).sorted { $0.createTime > $1.createTime }
        tableView.reloadData()
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
