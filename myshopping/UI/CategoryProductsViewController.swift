//
//  CategoryProductsViewController.swift
//  myshopping
//
//  对应 Android CategoryFragment：分类商品网格
//

import UIKit

final class CategoryProductsViewController: UIViewController, UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {

    private let category: String
    private var products: [Product] = []
    private var collectionView: UICollectionView!

    /// 收藏页「管理收藏」模式才显示爱心；首页为 true
    var showsFavoriteButton: Bool = true

    init(category: String) {
        self.category = category
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        self.category = "手机"
        super.init(coder: coder)
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        let layout = UICollectionViewFlowLayout()
        layout.minimumInteritemSpacing = 8
        layout.minimumLineSpacing = 8
        layout.sectionInset = UIEdgeInsets(top: 8, left: 8, bottom: 8, right: 8)
        collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.backgroundColor = .white
        collectionView.dataSource = self
        collectionView.delegate = self
        collectionView.register(ProductGridCell.self, forCellWithReuseIdentifier: ProductGridCell.reuseId)
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        collectionView.contentInsetAdjustmentBehavior = .never
        view.addSubview(collectionView)
        NSLayoutConstraint.activate([
            collectionView.topAnchor.constraint(equalTo: view.topAnchor),
            collectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            collectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            collectionView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        reloadProducts()
    }

    func reloadProducts() {
        if category == "手机" {
            if SearchState.hasPendingKeyword() {
                let kw = SearchState.getAndClearSearchKeyword()
                products = DataGenerator.searchByKeyword(kw)
            } else {
                products = DataGenerator.getProductsByCategory("手机")
            }
        } else {
            products = DataGenerator.getProductsByCategory(category)
        }
        collectionView.reloadData()
    }

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return products.count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: ProductGridCell.reuseId, for: indexPath) as! ProductGridCell
        let p = products[indexPath.item]
        cell.configure(product: p, showFavorite: showsFavoriteButton, onFavoriteChange: { [weak self] in
            _ = FavoriteManager.toggleFavorite(productId: p.id)
            self?.collectionView.reloadItems(at: [indexPath])
        })
        cell.onCellTap = { [weak self] in
            guard let self = self else { return }
            ProductDetailPanel.present(on: self, product: p)
        }
        return cell
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let w = collectionView.bounds.width - 8 * 3
        let cellW = floor(w / 2)
        return CGSize(width: cellW, height: cellW + 115)
    }
}
