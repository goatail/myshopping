//
//  ProductCoverStyle.swift
//  myshopping
//
//  商品封面占位：与 DataGenerator.imageIndex 对应，列表/购物车/详情统一；
//  若在 Assets 中提供 `product_cover_<imageIndex>` 图片则优先显示，否则使用占位色。
//

import UIKit

enum ProductCoverStyle {

    private static let coverImageTag = 9_001

    /// Assets 命名：`product_cover_0`、`product_cover_1` … 与 `Product.imageIndex` 一致
    static func coverAssetName(for product: Product) -> String {
        return "product_cover_\(product.imageIndex)"
    }

    /// 由 DataGenerator 写入的 imageIndex 生成稳定占位色
    static func placeholderColor(for product: Product) -> UIColor {
        return placeholderColor(imageIndex: product.imageIndex)
    }

    static func placeholderColor(imageIndex: Int) -> UIColor {
        let i = abs(imageIndex)
        let hue = CGFloat(i % 36) / 36.0
        let sat = 0.36 + CGFloat(i % 5) * 0.02
        let bri = 0.90 + CGFloat(i % 3) * 0.02
        return UIColor(hue: hue, saturation: sat, brightness: bri, alpha: 1)
    }

    /// 填充商品封面区域：有同名 Asset 则铺满，否则纯色占位
    static func fillCoverView(_ container: UIView, product: Product) {
        container.subviews.filter { $0.tag == coverImageTag }.forEach { $0.removeFromSuperview() }
        if let img = UIImage(named: coverAssetName(for: product)) {
            container.backgroundColor = .clear
            let iv = UIImageView(image: img)
            iv.tag = coverImageTag
            iv.contentMode = .scaleAspectFill
            iv.clipsToBounds = true
            iv.translatesAutoresizingMaskIntoConstraints = false
            container.addSubview(iv)
            NSLayoutConstraint.activate([
                iv.topAnchor.constraint(equalTo: container.topAnchor),
                iv.leadingAnchor.constraint(equalTo: container.leadingAnchor),
                iv.trailingAnchor.constraint(equalTo: container.trailingAnchor),
                iv.bottomAnchor.constraint(equalTo: container.bottomAnchor)
            ])
            let r = container.layer.cornerRadius
            if r > 0 {
                iv.layer.cornerRadius = r
            }
        } else {
            container.backgroundColor = placeholderColor(for: product)
        }
    }
}

// MARK: - 列表空状态（与购物车/收藏页灰阶双行一致）

enum EmptyStateStack {

    static func make(title: String, subtitle: String) -> UIStackView {
        let t = UILabel()
        t.text = title
        t.textAlignment = .center
        t.textColor = UIColor(white: 0.6, alpha: 1)
        t.font = UIFont.systemFont(ofSize: 16)
        let s = UILabel()
        s.text = subtitle
        s.textAlignment = .center
        s.textColor = UIColor(white: 0.8, alpha: 1)
        s.font = UIFont.systemFont(ofSize: 14)
        let stack = UIStackView(arrangedSubviews: [t, s])
        stack.axis = .vertical
        stack.spacing = 8
        stack.translatesAutoresizingMaskIntoConstraints = false
        stack.isHidden = true
        return stack
    }
}
