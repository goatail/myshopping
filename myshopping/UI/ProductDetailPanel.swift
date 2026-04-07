//
//  ProductDetailPanel.swift
//  myshopping
//
//  对应 Android BottomSheet 商品详情：自定义底部面板，兼容 iOS 11
//

import UIKit

private final class ProductDetailOverlay: NSObject {
    private weak var host: UIViewController?
    private var dimView: UIView?
    private var panelView: UIView?
    private var product: Product?

    func show(on host: UIViewController, product: Product) {
        self.host = host
        self.product = product

        let dim = UIView(frame: host.view.bounds)
        dim.backgroundColor = UIColor(white: 0, alpha: 0.4)
        dim.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        dim.alpha = 0
        host.view.addSubview(dim)
        dimView = dim

        let panel = UIView()
        panel.backgroundColor = .white
        panel.layer.cornerRadius = 12
        if #available(iOS 11.0, *) {
            panel.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
        }
        panel.translatesAutoresizingMaskIntoConstraints = false
        panelView = panel

        let title = UILabel()
        title.numberOfLines = 0
        title.font = UIFont.boldSystemFont(ofSize: 16)
        title.text = product.title

        let name = UILabel()
        name.font = UIFont.systemFont(ofSize: 14)
        name.text = product.name

        let desc = UILabel()
        desc.numberOfLines = 0
        desc.font = UIFont.systemFont(ofSize: 13)
        desc.textColor = .darkGray
        desc.text = product.description

        let seller = UILabel()
        seller.font = UIFont.systemFont(ofSize: 13)
        seller.text = "卖家：\(product.sellerName)"

        let meta = UILabel()
        meta.font = UIFont.systemFont(ofSize: 12)
        meta.textColor = .gray
        meta.text = "\(product.viewsCount)  \(product.transactionCount)"

        let price = UILabel()
        price.font = UIFont.boldSystemFont(ofSize: 18)
        price.textColor = UIColor(red: 0.9, green: 0.2, blue: 0.2, alpha: 1)
        price.text = String(format: "¥%.2f", product.price)

        let hero = UIView()
        hero.translatesAutoresizingMaskIntoConstraints = false
        hero.clipsToBounds = true
        if #available(iOS 11.0, *) {
            hero.layer.cornerRadius = 12
            hero.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
        }
        ProductCoverStyle.fillCoverView(hero, product: product)

        let addBtn = UIButton(type: .system)
        addBtn.setTitle("加入购物车", for: .normal)
        addBtn.backgroundColor = UIColor(red: 1, green: 0.42, blue: 0.2, alpha: 1)
        addBtn.setTitleColor(.white, for: .normal)
        addBtn.layer.cornerRadius = 8

        let closeBtn = UIButton(type: .system)
        closeBtn.setTitle("关闭", for: .normal)

        let stack = UIStackView(arrangedSubviews: [title, name, desc, seller, meta, price, addBtn, closeBtn])
        stack.axis = .vertical
        stack.spacing = 10
        stack.translatesAutoresizingMaskIntoConstraints = false

        let outer = UIStackView(arrangedSubviews: [hero, stack])
        outer.axis = .vertical
        outer.spacing = 16
        outer.translatesAutoresizingMaskIntoConstraints = false

        panel.addSubview(outer)
        dim.addSubview(panel)

        let guide = host.view.safeAreaLayoutGuide
        NSLayoutConstraint.activate([
            panel.leadingAnchor.constraint(equalTo: host.view.leadingAnchor),
            panel.trailingAnchor.constraint(equalTo: host.view.trailingAnchor),
            panel.bottomAnchor.constraint(equalTo: host.view.bottomAnchor),

            hero.heightAnchor.constraint(equalToConstant: 140),

            outer.topAnchor.constraint(equalTo: panel.topAnchor),
            outer.leadingAnchor.constraint(equalTo: panel.leadingAnchor),
            outer.trailingAnchor.constraint(equalTo: panel.trailingAnchor),
            outer.bottomAnchor.constraint(equalTo: guide.bottomAnchor, constant: -12),

            stack.leadingAnchor.constraint(equalTo: outer.leadingAnchor, constant: 16),
            stack.trailingAnchor.constraint(equalTo: outer.trailingAnchor, constant: -16)
        ])

        addBtn.heightAnchor.constraint(equalToConstant: 44).isActive = true

        addBtn.addTarget(self, action: #selector(onAddCart), for: .touchUpInside)
        closeBtn.addTarget(self, action: #selector(onClose), for: .touchUpInside)

        let tap = UITapGestureRecognizer(target: self, action: #selector(onDimTap(_:)))
        dim.addGestureRecognizer(tap)

        panel.transform = CGAffineTransform(translationX: 0, y: 400)
        UIView.animate(withDuration: 0.25) {
            dim.alpha = 1
            panel.transform = .identity
        }
    }

    @objc private func onAddCart() {
        guard let product = product, let host = host else { return }
        CartManager.addToCart(product: product, quantity: 1)
        let ac = UIAlertController(title: nil, message: "已添加到购物车", preferredStyle: .alert)
        ac.addAction(UIAlertAction(title: "确定", style: .default, handler: { [weak self] _ in
            self?.tearDown()
        }))
        host.present(ac, animated: true)
    }

    @objc private func onClose() {
        tearDown()
    }

    @objc private func onDimTap(_ g: UITapGestureRecognizer) {
        if g.state == .ended {
            tearDown()
        }
    }

    private func tearDown() {
        guard let dim = dimView, let panel = panelView else { return }
        UIView.animate(withDuration: 0.25, animations: {
            dim.alpha = 0
            panel.transform = CGAffineTransform(translationX: 0, y: 400)
        }, completion: { _ in
            dim.removeFromSuperview()
        })
    }
}

enum ProductDetailPanel {
    private static var current: ProductDetailOverlay?

    static func present(on host: UIViewController, product: Product) {
        let o = ProductDetailOverlay()
        current = o
        o.show(on: host, product: product)
    }
}
