//
//  CartItemTableViewCell.swift
//  myshopping
//
//  对齐 Android CartAdapter + ItemCartBinding
//

import UIKit

final class CartItemTableViewCell: UITableViewCell {

    static let reuseId = "CartItemTableViewCell"

    private let thumbView = UIView()
    private let nameLabel = UILabel()
    private let priceLabel = UILabel()
    private let subtotalLabel = UILabel()
    private let decreaseButton = UIButton(type: .system)
    private let quantityLabel = UILabel()
    private let increaseButton = UIButton(type: .system)
    private let deleteButton = UIButton(type: .system)

    private var productId: String = ""
    private var onChanged: (() -> Void)?

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        selectionStyle = .none

        thumbView.layer.cornerRadius = 4
        thumbView.clipsToBounds = true
        thumbView.translatesAutoresizingMaskIntoConstraints = false

        nameLabel.font = UIFont.systemFont(ofSize: 15)
        nameLabel.numberOfLines = 2

        priceLabel.font = UIFont.systemFont(ofSize: 14)
        priceLabel.textColor = .darkGray

        subtotalLabel.font = UIFont.systemFont(ofSize: 13)
        subtotalLabel.textColor = .gray

        quantityLabel.font = UIFont.systemFont(ofSize: 15)
        quantityLabel.textAlignment = .center
        quantityLabel.textColor = .darkText

        decreaseButton.setTitle("−", for: .normal)
        decreaseButton.titleLabel?.font = UIFont.boldSystemFont(ofSize: 18)
        decreaseButton.layer.borderWidth = 1 / UIScreen.main.scale
        decreaseButton.layer.borderColor = UIColor.lightGray.cgColor
        decreaseButton.layer.cornerRadius = 4
        decreaseButton.addTarget(self, action: #selector(onDecrease), for: .touchUpInside)

        increaseButton.setTitle("+", for: .normal)
        increaseButton.titleLabel?.font = UIFont.boldSystemFont(ofSize: 18)
        increaseButton.layer.borderWidth = 1 / UIScreen.main.scale
        increaseButton.layer.borderColor = UIColor.lightGray.cgColor
        increaseButton.layer.cornerRadius = 4
        increaseButton.addTarget(self, action: #selector(onIncrease), for: .touchUpInside)

        deleteButton.setTitle("删除", for: .normal)
        if #available(iOS 13.0, *) {
            deleteButton.setTitleColor(.systemRed, for: .normal)
        } else {
            deleteButton.setTitleColor(UIColor.red, for: .normal)
        }
        deleteButton.titleLabel?.font = UIFont.systemFont(ofSize: 14)
        deleteButton.addTarget(self, action: #selector(onDelete), for: .touchUpInside)

        let qtyStack = UIStackView(arrangedSubviews: [decreaseButton, quantityLabel, increaseButton])
        qtyStack.axis = .horizontal
        qtyStack.spacing = 6
        qtyStack.alignment = .center

        decreaseButton.widthAnchor.constraint(equalToConstant: 32).isActive = true
        decreaseButton.heightAnchor.constraint(equalToConstant: 32).isActive = true
        increaseButton.widthAnchor.constraint(equalToConstant: 32).isActive = true
        increaseButton.heightAnchor.constraint(equalToConstant: 32).isActive = true
        quantityLabel.widthAnchor.constraint(greaterThanOrEqualToConstant: 24).isActive = true

        // 单价 + 数量步进器（与 Android 一行语义一致）
        let priceRow = UIStackView(arrangedSubviews: [priceLabel, UIView(), qtyStack])
        priceRow.axis = .horizontal
        priceRow.alignment = .center

        // 小计 + 删除
        let bottomRow = UIStackView(arrangedSubviews: [subtotalLabel, UIView(), deleteButton])
        bottomRow.axis = .horizontal
        bottomRow.alignment = .center

        let textColumn = UIStackView(arrangedSubviews: [nameLabel, priceRow, bottomRow])
        textColumn.axis = .vertical
        textColumn.spacing = 8
        textColumn.translatesAutoresizingMaskIntoConstraints = false

        let row = UIStackView(arrangedSubviews: [thumbView, textColumn])
        row.axis = .horizontal
        row.spacing = 12
        row.alignment = .top
        row.translatesAutoresizingMaskIntoConstraints = false

        contentView.addSubview(row)
        NSLayoutConstraint.activate([
            thumbView.widthAnchor.constraint(equalToConstant: 72),
            thumbView.heightAnchor.constraint(equalToConstant: 72),
            row.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 12),
            row.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            row.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            row.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -12)
        ])
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func configure(item: CartItem, onChanged: @escaping () -> Void) {
        self.onChanged = onChanged
        productId = item.product.id
        let p = item.product
        nameLabel.text = p.name
        priceLabel.text = String(format: "¥%.2f", p.price)
        quantityLabel.text = "\(item.quantity)"
        subtotalLabel.text = "小计：¥" + String(format: "%.2f", item.totalPrice)

        ProductCoverStyle.fillCoverView(thumbView, product: p)
    }

    @objc private func onDecrease() {
        guard let item = CartManager.getCartItems().first(where: { $0.product.id == productId }) else { return }
        let q = item.quantity
        if q > 1 {
            CartManager.updateQuantity(productId: productId, quantity: q - 1)
            onChanged?()
        }
    }

    @objc private func onIncrease() {
        guard let item = CartManager.getCartItems().first(where: { $0.product.id == productId }) else { return }
        CartManager.updateQuantity(productId: productId, quantity: item.quantity + 1)
        onChanged?()
    }

    @objc private func onDelete() {
        CartManager.removeFromCart(productId: productId)
        onChanged?()
    }
}
