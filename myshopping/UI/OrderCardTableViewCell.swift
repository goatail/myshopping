//
//  OrderCardTableViewCell.swift
//  myshopping
//
//  对齐 Android PendingOrderAdapter + ItemPendingOrderBinding 卡片结构
//

import UIKit

final class OrderCardTableViewCell: UITableViewCell {

    static let reuseId = "OrderCardTableViewCell"

    private let cardView = UIView()
    private let orderIdLabel = UILabel()
    private let timeLabel = UILabel()
    private let statusLabel = UILabel()
    private let totalLabel = UILabel()
    private let itemsStack = UIStackView()

    private static let timeFormatter: DateFormatter = {
        let f = DateFormatter()
        f.dateFormat = "yyyy-MM-dd HH:mm"
        f.locale = Locale(identifier: "zh_CN")
        return f
    }()

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        selectionStyle = .none
        backgroundColor = UIColor(white: 0.96, alpha: 1)
        contentView.backgroundColor = UIColor(white: 0.96, alpha: 1)

        cardView.backgroundColor = .white
        cardView.layer.cornerRadius = 8
        cardView.layer.borderWidth = 1 / UIScreen.main.scale
        cardView.layer.borderColor = UIColor(white: 0.9, alpha: 1).cgColor
        cardView.translatesAutoresizingMaskIntoConstraints = false

        orderIdLabel.font = UIFont.systemFont(ofSize: 14)
        orderIdLabel.textColor = .darkText
        orderIdLabel.numberOfLines = 1

        timeLabel.font = UIFont.systemFont(ofSize: 12)
        timeLabel.textColor = .gray

        statusLabel.font = UIFont.systemFont(ofSize: 13)
        statusLabel.textColor = UIColor(red: 1, green: 0.42, blue: 0.2, alpha: 1)
        statusLabel.textAlignment = .right

        totalLabel.font = UIFont.boldSystemFont(ofSize: 16)
        totalLabel.textColor = .darkText
        totalLabel.textAlignment = .right

        let headerSpacer = UIView()
        let headerRow = UIStackView(arrangedSubviews: [timeLabel, headerSpacer, statusLabel])
        headerRow.axis = .horizontal
        headerRow.alignment = .center

        let totalRow = UIStackView(arrangedSubviews: [UIView(), totalLabel])
        totalRow.axis = .horizontal

        itemsStack.axis = .vertical
        itemsStack.spacing = 8
        itemsStack.translatesAutoresizingMaskIntoConstraints = false

        let inner = UIStackView(arrangedSubviews: [orderIdLabel, headerRow, totalRow, itemsStack])
        inner.axis = .vertical
        inner.spacing = 8
        inner.translatesAutoresizingMaskIntoConstraints = false
        inner.isLayoutMarginsRelativeArrangement = true
        inner.layoutMargins = UIEdgeInsets(top: 12, left: 12, bottom: 12, right: 12)

        cardView.addSubview(inner)
        contentView.addSubview(cardView)

        NSLayoutConstraint.activate([
            cardView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 6),
            cardView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 12),
            cardView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -12),
            cardView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -6),

            inner.topAnchor.constraint(equalTo: cardView.topAnchor),
            inner.leadingAnchor.constraint(equalTo: cardView.leadingAnchor),
            inner.trailingAnchor.constraint(equalTo: cardView.trailingAnchor),
            inner.bottomAnchor.constraint(equalTo: cardView.bottomAnchor)
        ])
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func configure(order: Order) {
        orderIdLabel.text = "订单号：\(order.id)"
        timeLabel.text = Self.formatTime(order.createTime)
        statusLabel.text = order.status
        totalLabel.text = String(format: "¥%.2f", order.totalPrice)

        itemsStack.arrangedSubviews.forEach { $0.removeFromSuperview() }
        for item in order.items {
            itemsStack.addArrangedSubview(makeProductRow(item))
        }
    }

    private func makeProductRow(_ item: CartItem) -> UIView {
        let p = item.product
        let thumb = UIView()
        thumb.translatesAutoresizingMaskIntoConstraints = false
        thumb.layer.cornerRadius = 4
        thumb.clipsToBounds = true
        ProductCoverStyle.fillCoverView(thumb, product: p)
        thumb.widthAnchor.constraint(equalToConstant: 48).isActive = true
        thumb.heightAnchor.constraint(equalToConstant: 48).isActive = true

        let name = UILabel()
        name.font = UIFont.systemFont(ofSize: 13)
        name.text = p.name
        name.numberOfLines = 2

        let line1 = UIStackView(arrangedSubviews: [
            priceText(String(format: "¥%.2f", p.price)),
            qtyText("x\(item.quantity)")
        ])
        line1.axis = .horizontal
        line1.distribution = .equalSpacing

        let sub = UILabel()
        sub.font = UIFont.systemFont(ofSize: 12)
        sub.textColor = .gray
        sub.text = String(format: "小计：¥%.2f", item.totalPrice)

        let textStack = UIStackView(arrangedSubviews: [name, line1, sub])
        textStack.axis = .vertical
        textStack.spacing = 4

        let row = UIStackView(arrangedSubviews: [thumb, textStack])
        row.axis = .horizontal
        row.spacing = 10
        row.alignment = .top
        return row
    }

    private func priceText(_ s: String) -> UILabel {
        let l = UILabel()
        l.font = UIFont.systemFont(ofSize: 12)
        l.textColor = .darkGray
        l.text = s
        return l
    }

    private func qtyText(_ s: String) -> UILabel {
        let l = UILabel()
        l.font = UIFont.systemFont(ofSize: 12)
        l.textColor = .gray
        l.text = s
        return l
    }

    private static func formatTime(_ raw: TimeInterval) -> String {
        let seconds: TimeInterval
        // Java 侧为毫秒时放大显示
        if raw > 100_000_000_000 {
            seconds = raw / 1000
        } else {
            seconds = raw
        }
        return timeFormatter.string(from: Date(timeIntervalSince1970: seconds))
    }
}
