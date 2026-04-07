//
//  ProductGridCell.swift
//  myshopping
//
//  对齐 Android ProductAdapter：收藏按钮与商品区域点击分离，避免误触
//

import UIKit

final class ProductGridCell: UICollectionViewCell {
    static let reuseId = "ProductGridCell"

    /// 封面 + 文案区域，点击进详情（不含收藏按钮）
    private let tapContainer = UIView()
    private let coverView = UIView()
    private let titleLabel = UILabel()
    private let sellerLabel = UILabel()
    private let metaLabel = UILabel()
    private let priceLabel = UILabel()
    private let favoriteButton = UIButton(type: .system)

    var onFavoriteTap: (() -> Void)?
    var onCellTap: (() -> Void)?

    override init(frame: CGRect) {
        super.init(frame: frame)
        contentView.layer.cornerRadius = 8
        contentView.layer.borderWidth = 1 / UIScreen.main.scale
        contentView.layer.borderColor = UIColor(white: 0.9, alpha: 1).cgColor
        contentView.clipsToBounds = true

        tapContainer.translatesAutoresizingMaskIntoConstraints = false
        coverView.clipsToBounds = true
        coverView.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.font = UIFont.systemFont(ofSize: 12)
        titleLabel.numberOfLines = 2
        sellerLabel.font = UIFont.systemFont(ofSize: 11)
        sellerLabel.textColor = .darkGray
        metaLabel.font = UIFont.systemFont(ofSize: 10)
        metaLabel.textColor = .gray
        priceLabel.font = UIFont.boldSystemFont(ofSize: 14)
        priceLabel.textColor = UIColor(red: 0.9, green: 0.2, blue: 0.2, alpha: 1)

        favoriteButton.translatesAutoresizingMaskIntoConstraints = false
        favoriteButton.addTarget(self, action: #selector(favTapped), for: .touchUpInside)
        if #available(iOS 13.0, *) {
            favoriteButton.setImage(UIImage(systemName: "heart"), for: .normal)
        } else {
            favoriteButton.setTitle("♡", for: .normal)
        }

        let tap = UITapGestureRecognizer(target: self, action: #selector(cellTapped))
        tapContainer.addGestureRecognizer(tap)
        tapContainer.isUserInteractionEnabled = true

        let stack = UIStackView(arrangedSubviews: [titleLabel, sellerLabel, metaLabel, priceLabel])
        stack.axis = .vertical
        stack.spacing = 4
        stack.translatesAutoresizingMaskIntoConstraints = false

        tapContainer.addSubview(coverView)
        tapContainer.addSubview(stack)
        contentView.addSubview(tapContainer)
        contentView.addSubview(favoriteButton)

        NSLayoutConstraint.activate([
            tapContainer.topAnchor.constraint(equalTo: contentView.topAnchor),
            tapContainer.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            tapContainer.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            tapContainer.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),

            coverView.topAnchor.constraint(equalTo: tapContainer.topAnchor),
            coverView.leadingAnchor.constraint(equalTo: tapContainer.leadingAnchor),
            coverView.trailingAnchor.constraint(equalTo: tapContainer.trailingAnchor),
            coverView.heightAnchor.constraint(equalTo: tapContainer.widthAnchor, multiplier: 1),

            stack.topAnchor.constraint(equalTo: coverView.bottomAnchor, constant: 8),
            stack.leadingAnchor.constraint(equalTo: tapContainer.leadingAnchor, constant: 8),
            stack.trailingAnchor.constraint(equalTo: tapContainer.trailingAnchor, constant: -8),
            stack.bottomAnchor.constraint(lessThanOrEqualTo: tapContainer.bottomAnchor, constant: -8),

            favoriteButton.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 4),
            favoriteButton.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -4),
            favoriteButton.widthAnchor.constraint(equalToConstant: 36),
            favoriteButton.heightAnchor.constraint(equalToConstant: 36)
        ])
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        contentView.bringSubviewToFront(favoriteButton)
    }

    func configure(product: Product, showFavorite: Bool, onFavoriteChange: (() -> Void)?) {
        onFavoriteTap = onFavoriteChange
        titleLabel.text = product.title
        sellerLabel.text = product.sellerName
        metaLabel.text = "\(product.viewsCount) · \(product.transactionCount)"
        priceLabel.text = String(format: "¥%.2f", product.price)

        ProductCoverStyle.fillCoverView(coverView, product: product)

        favoriteButton.isHidden = !showFavorite
        let fav = FavoriteManager.isFavorite(productId: product.id)
        if #available(iOS 13.0, *) {
            let name = fav ? "heart.fill" : "heart"
            favoriteButton.setImage(UIImage(systemName: name), for: .normal)
        } else {
            favoriteButton.setTitle(fav ? "♥" : "♡", for: .normal)
        }
    }

    @objc private func favTapped() {
        onFavoriteTap?()
    }

    @objc private func cellTapped() {
        onCellTap?()
    }
}
