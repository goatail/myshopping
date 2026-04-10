//
//  MyOrdersViewController.swift
//  myshopping
//
//  对应 Android MyOrdersActivity：类型勾选 + 关键字
//

import UIKit

final class MyOrdersViewController: UIViewController, UITableViewDataSource {

    private let tableView = UITableView(frame: .zero, style: .plain)
    private let keywordField = UITextField()
    private var chipPay = true
    private var chipShip = true
    private var chipRecv = true
    private var chipDone = true

    private var chipPayButton: UIButton!
    private var chipShipButton: UIButton!
    private var chipRecvButton: UIButton!
    private var chipDoneButton: UIButton!

    private var display: [Order] = []

    private let emptyStack = EmptyStateStack.make(
        title: "暂无订单",
        subtitle: "试试调整筛选条件或去首页选购商品~"
    )

    override func viewDidLoad() {
        super.viewDidLoad()
        title = "我的订单"
        view.backgroundColor = UIColor(white: 0.96, alpha: 1)

        keywordField.placeholder = "订单号/商品名"
        keywordField.borderStyle = .roundedRect
        keywordField.returnKeyType = .search
        keywordField.addTarget(self, action: #selector(query), for: .editingDidEndOnExit)

        let searchBtn = UIButton(type: .system)
        searchBtn.setTitle("搜索", for: .normal)
        searchBtn.addTarget(self, action: #selector(query), for: .touchUpInside)

        let row = UIStackView(arrangedSubviews: [keywordField, searchBtn])
        row.spacing = 8
        row.translatesAutoresizingMaskIntoConstraints = false

        chipPayButton = makeChip(title: "待付款", action: #selector(togglePay))
        chipShipButton = makeChip(title: "待发货", action: #selector(toggleShip))
        chipRecvButton = makeChip(title: "待收货", action: #selector(toggleRecv))
        chipDoneButton = makeChip(title: "待评价", action: #selector(toggleDone))

        let chips = UIStackView(arrangedSubviews: [chipPayButton, chipShipButton, chipRecvButton, chipDoneButton])
        chips.axis = .horizontal
        chips.spacing = 8
        chips.distribution = .fillEqually
        chips.translatesAutoresizingMaskIntoConstraints = false

        let stack = UIStackView(arrangedSubviews: [row, chips])
        stack.axis = .vertical
        stack.spacing = 8
        stack.translatesAutoresizingMaskIntoConstraints = false

        view.addSubview(stack)
        tableView.dataSource = self
        tableView.register(OrderCardTableViewCell.self, forCellReuseIdentifier: OrderCardTableViewCell.reuseId)
        tableView.rowHeight = UITableView.automaticDimension
        tableView.estimatedRowHeight = 220
        tableView.separatorStyle = .none
        tableView.backgroundColor = view.backgroundColor
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.contentInsetAdjustmentBehavior = .never
        view.addSubview(tableView)
        view.addSubview(emptyStack)

        let guide = view.safeAreaLayoutGuide
        NSLayoutConstraint.activate([
            stack.topAnchor.constraint(equalTo: guide.topAnchor, constant: 8),
            stack.leadingAnchor.constraint(equalTo: guide.leadingAnchor, constant: 12),
            stack.trailingAnchor.constraint(equalTo: guide.trailingAnchor, constant: -12),

            tableView.topAnchor.constraint(equalTo: stack.bottomAnchor, constant: 8),
            tableView.leadingAnchor.constraint(equalTo: guide.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: guide.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: guide.bottomAnchor),

            emptyStack.centerXAnchor.constraint(equalTo: guide.centerXAnchor),
            emptyStack.centerYAnchor.constraint(equalTo: guide.centerYAnchor, constant: 40)
        ])

        refreshChipStyles()
        query()
    }

    private func makeChip(title: String, action: Selector) -> UIButton {
        let b = UIButton(type: .system)
        b.setTitle(title, for: .normal)
        b.layer.cornerRadius = 6
        b.layer.borderWidth = 1
        b.layer.borderColor = UIColor.lightGray.cgColor
        b.addTarget(self, action: action, for: .touchUpInside)
        return b
    }

    private func refreshChipStyles() {
        styleChip(chipPayButton, on: chipPay)
        styleChip(chipShipButton, on: chipShip)
        styleChip(chipRecvButton, on: chipRecv)
        styleChip(chipDoneButton, on: chipDone)
    }

    private func styleChip(_ b: UIButton, on: Bool) {
        b.backgroundColor = on ? UIColor(red: 0.9, green: 0.95, blue: 1, alpha: 1) : .white
    }

    @objc private func togglePay() {
        chipPay.toggle()
        refreshChipStyles()
        query()
    }
    @objc private func toggleShip() {
        chipShip.toggle()
        refreshChipStyles()
        query()
    }
    @objc private func toggleRecv() {
        chipRecv.toggle()
        refreshChipStyles()
        query()
    }
    @objc private func toggleDone() {
        chipDone.toggle()
        refreshChipStyles()
        query()
    }

    @objc private func query() {
        var statuses: [String] = []
        if chipPay { statuses.append("待付款") }
        if chipShip { statuses.append("待发货") }
        if chipRecv { statuses.append("待收货") }
        if chipDone { statuses.append("待评价") }
        if statuses.isEmpty {
            statuses = ["待付款", "待发货", "待收货", "待评价"]
        }
        var list: [Order] = []
        for s in statuses {
            list.append(contentsOf: OrderManager.getOrdersByStatus(s))
        }
        list.sort { $0.createTime > $1.createTime }

        let kw = keywordField.text?.trimmingCharacters(in: .whitespacesAndNewlines).lowercased() ?? ""
        if !kw.isEmpty {
            list = list.filter { o in
                if o.id.lowercased().contains(kw) { return true }
                return o.items.contains { $0.product.name.lowercased().contains(kw) }
            }
        }
        display = list
        tableView.reloadData()
        let empty = display.isEmpty
        emptyStack.isHidden = !empty
        tableView.isHidden = empty
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return display.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: OrderCardTableViewCell.reuseId, for: indexPath) as! OrderCardTableViewCell
        cell.configure(order: display[indexPath.row])
        return cell
    }
}
