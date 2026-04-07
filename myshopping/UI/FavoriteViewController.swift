//
//  FavoriteViewController.swift
//  myshopping
//
//  对应 Android FavoriteFragment
//

import UIKit

final class FavoriteViewController: UIViewController, UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {

    private var collectionView: UICollectionView!
    private var products: [Product] = []
    private var manageMode = false
    private let manageButton = UIButton(type: .system)
    private let emptyLabel = UILabel()

    override func viewDidLoad() {
        super.viewDidLoad()
        title = "收藏"
        view.backgroundColor = .white

        manageButton.setTitle("管理收藏", for: .normal)
        manageButton.addTarget(self, action: #selector(toggleManage), for: .touchUpInside)
        manageButton.translatesAutoresizingMaskIntoConstraints = false

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

        emptyLabel.text = "暂无收藏"
        emptyLabel.textAlignment = .center
        emptyLabel.textColor = .gray
        emptyLabel.translatesAutoresizingMaskIntoConstraints = false

        view.addSubview(manageButton)
        view.addSubview(collectionView)
        view.addSubview(emptyLabel)

        let guide = view.safeAreaLayoutGuide
        NSLayoutConstraint.activate([
            manageButton.topAnchor.constraint(equalTo: guide.topAnchor, constant: 8),
            manageButton.trailingAnchor.constraint(equalTo: guide.trailingAnchor, constant: -16),
            collectionView.topAnchor.constraint(equalTo: manageButton.bottomAnchor, constant: 8),
            collectionView.leadingAnchor.constraint(equalTo: guide.leadingAnchor),
            collectionView.trailingAnchor.constraint(equalTo: guide.trailingAnchor),
            collectionView.bottomAnchor.constraint(equalTo: guide.bottomAnchor),
            emptyLabel.centerXAnchor.constraint(equalTo: guide.centerXAnchor),
            emptyLabel.centerYAnchor.constraint(equalTo: guide.centerYAnchor)
        ])
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        loadFavorites()
    }

    private func loadFavorites() {
        products = FavoriteManager.getFavoriteProducts()
        collectionView.reloadData()
        let empty = products.isEmpty
        emptyLabel.isHidden = !empty
        collectionView.isHidden = empty
        manageButton.isHidden = empty
        if empty {
            manageMode = false
            manageButton.setTitle("管理收藏", for: .normal)
        }
    }

    @objc private func toggleManage() {
        manageMode.toggle()
        manageButton.setTitle(manageMode ? "完成" : "管理收藏", for: .normal)
        collectionView.reloadData()
    }

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return products.count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: ProductGridCell.reuseId, for: indexPath) as! ProductGridCell
        let p = products[indexPath.item]
        cell.configure(product: p, showFavorite: manageMode, onFavoriteChange: { [weak self] in
            _ = FavoriteManager.toggleFavorite(productId: p.id)
            self?.loadFavorites()
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
