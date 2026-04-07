//
//  CheckoutViewController.swift
//  myshopping
//
//  对应 Android CheckoutActivity
//

import UIKit

final class CheckoutViewController: UIViewController {

    private static let shippingFee: Double = 10

    private let scrollView = UIScrollView()
    private let contentStack = UIStackView()
    private let addressLabel = UILabel()
    private let noAddressLabel = UILabel()
    private let addressContainer = UIView()
    private let itemsStack = UIStackView()
    private let submitButton = UIButton(type: .system)

    private var currentAddress: Address?

    override func viewDidLoad() {
        super.viewDidLoad()
        title = "结算"
        view.backgroundColor = .white

        scrollView.translatesAutoresizingMaskIntoConstraints = false
        contentStack.axis = .vertical
        contentStack.spacing = 12
        contentStack.translatesAutoresizingMaskIntoConstraints = false
        scrollView.addSubview(contentStack)
        view.addSubview(scrollView)

        addressLabel.numberOfLines = 0
        addressLabel.font = UIFont.systemFont(ofSize: 14)
        noAddressLabel.text = "暂无收货地址，点击添加"
        noAddressLabel.textColor = .gray
        noAddressLabel.textAlignment = .center

        let tap = UITapGestureRecognizer(target: self, action: #selector(selectAddress))
        addressContainer.addGestureRecognizer(tap)
        addressContainer.backgroundColor = UIColor(white: 0.97, alpha: 1)
        addressContainer.layer.cornerRadius = 8
        addressContainer.translatesAutoresizingMaskIntoConstraints = false
        addressLabel.translatesAutoresizingMaskIntoConstraints = false
        noAddressLabel.translatesAutoresizingMaskIntoConstraints = false
        addressContainer.addSubview(addressLabel)
        addressContainer.addSubview(noAddressLabel)
        NSLayoutConstraint.activate([
            addressContainer.heightAnchor.constraint(greaterThanOrEqualToConstant: 72),
            addressLabel.topAnchor.constraint(equalTo: addressContainer.topAnchor, constant: 12),
            addressLabel.leadingAnchor.constraint(equalTo: addressContainer.leadingAnchor, constant: 12),
            addressLabel.trailingAnchor.constraint(equalTo: addressContainer.trailingAnchor, constant: -12),
            addressLabel.bottomAnchor.constraint(equalTo: addressContainer.bottomAnchor, constant: -12),
            noAddressLabel.centerXAnchor.constraint(equalTo: addressContainer.centerXAnchor),
            noAddressLabel.centerYAnchor.constraint(equalTo: addressContainer.centerYAnchor)
        ])

        itemsStack.axis = .vertical
        itemsStack.spacing = 8

        submitButton.setTitle("提交订单", for: .normal)
        submitButton.backgroundColor = UIColor(red: 1, green: 0.42, blue: 0.2, alpha: 1)
        submitButton.setTitleColor(.white, for: .normal)
        submitButton.layer.cornerRadius = 8
        submitButton.addTarget(self, action: #selector(submit), for: .touchUpInside)
        submitButton.heightAnchor.constraint(equalToConstant: 48).isActive = true

        contentStack.addArrangedSubview(addressContainer)
        contentStack.addArrangedSubview(itemsStack)
        contentStack.addArrangedSubview(submitButton)

        let guide = view.safeAreaLayoutGuide
        NSLayoutConstraint.activate([
            scrollView.topAnchor.constraint(equalTo: guide.topAnchor),
            scrollView.leadingAnchor.constraint(equalTo: guide.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: guide.trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: guide.bottomAnchor),

            contentStack.topAnchor.constraint(equalTo: scrollView.contentLayoutGuide.topAnchor, constant: 12),
            contentStack.leadingAnchor.constraint(equalTo: scrollView.frameLayoutGuide.leadingAnchor, constant: 12),
            contentStack.trailingAnchor.constraint(equalTo: scrollView.frameLayoutGuide.trailingAnchor, constant: -12),
            contentStack.bottomAnchor.constraint(equalTo: scrollView.contentLayoutGuide.bottomAnchor, constant: -12),
            contentStack.widthAnchor.constraint(equalTo: scrollView.frameLayoutGuide.widthAnchor, constant: -24)
        ])

        rebuildItems()
        refreshAddress()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        refreshAddress()
        rebuildItems()
    }

    private func rebuildItems() {
        itemsStack.arrangedSubviews.forEach { $0.removeFromSuperview() }

        let items = CartManager.getCartItems()
        let subtotal = CartManager.getTotalPrice()
        let total = subtotal + Self.shippingFee

        for it in items {
            let lab = UILabel()
            lab.numberOfLines = 0
            lab.font = UIFont.systemFont(ofSize: 14)
            lab.text = "\(it.product.name) ×\(it.quantity)  " + String(format: "¥%.2f", it.totalPrice)
            itemsStack.addArrangedSubview(lab)
        }

        itemsStack.addArrangedSubview(summaryLabel("商品小计", String(format: "¥%.2f", subtotal)))
        itemsStack.addArrangedSubview(summaryLabel("运费", String(format: "¥%.2f", Self.shippingFee)))
        itemsStack.addArrangedSubview(summaryLabel("实付", String(format: "¥%.2f", total)))
    }

    private func summaryLabel(_ t: String, _ v: String) -> UIView {
        let a = UILabel()
        a.text = t
        let b = UILabel()
        b.text = v
        b.textAlignment = .right
        let row = UIStackView(arrangedSubviews: [a, b])
        row.distribution = .fillEqually
        return row
    }

    private func refreshAddress() {
        currentAddress = AddressManager.getDefaultAddress()
        if let a = currentAddress {
            addressLabel.text = a.displayText()
            addressLabel.isHidden = false
            noAddressLabel.isHidden = true
        } else {
            addressLabel.isHidden = true
            noAddressLabel.isHidden = false
        }
    }

    @objc private func selectAddress() {
        let list = AddressListViewController(selectMode: true)
        list.onPick = { [weak self] id in
            self?.currentAddress = AddressManager.getAddressById(id)
            self?.refreshAddress()
        }
        navigationController?.pushViewController(list, animated: true)
    }

    @objc private func submit() {
        let items = CartManager.getCartItems()
        if items.isEmpty {
            let ac = UIAlertController(title: nil, message: "购物车为空", preferredStyle: .alert)
            ac.addAction(UIAlertAction(title: "确定", style: .default))
            present(ac, animated: true)
            return
        }
        guard let addr = currentAddress ?? AddressManager.getDefaultAddress() else {
            let ac = UIAlertController(title: nil, message: "请选择收货地址", preferredStyle: .alert)
            ac.addAction(UIAlertAction(title: "确定", style: .default))
            present(ac, animated: true)
            return
        }
        let subtotal = CartManager.getTotalPrice()
        let total = subtotal + Self.shippingFee
        let id = "ORD_" + String(UUID().uuidString.prefix(8))
        let order = Order(id: id, createTime: Date().timeIntervalSince1970, items: items, totalPrice: total, address: addr, status: "待发货")
        OrderManager.addOrder(order)
        CartManager.clearCart()

        let ac = UIAlertController(title: nil, message: "订单提交成功！", preferredStyle: .alert)
        ac.addAction(UIAlertAction(title: "确定", style: .default, handler: { [weak self] _ in
            self?.navigationController?.popViewController(animated: true)
        }))
        present(ac, animated: true)
    }
}
