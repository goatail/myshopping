//
//  SearchResultViewController.swift
//  myshopping
//
//  对应 Android SearchResultActivity（品牌 + 价格筛选）
//

import UIKit

final class SearchResultViewController: UIViewController, UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {

    private let keyword: String
    private var baseList: [Product] = []
    private var displayList: [Product] = []

    private let brandButton = UIButton(type: .system)
    private let minField = UITextField()
    private let maxField = UITextField()
    private let applyButton = UIButton(type: .system)
    private var collectionView: UICollectionView!

    private var selectedBrand: String?
    private var brandOptions: [String] = []

    init(keyword: String) {
        self.keyword = keyword
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        self.keyword = ""
        super.init(coder: coder)
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        title = "搜索：\(keyword)"
        view.backgroundColor = .white

        SearchState.setSearchKeyword(keyword)
        SearchState.setLastDisplayedKeyword(keyword)

        baseList = DataGenerator.searchByKeyword(keyword)
        brandOptions = ["全部"] + DataGenerator.getDistinctBrands()

        brandButton.setTitle("品牌：全部", for: .normal)
        brandButton.contentHorizontalAlignment = .left
        brandButton.addTarget(self, action: #selector(pickBrand), for: .touchUpInside)

        minField.placeholder = "最低价"
        maxField.placeholder = "最高价"
        minField.borderStyle = .roundedRect
        maxField.borderStyle = .roundedRect
        minField.keyboardType = .decimalPad
        maxField.keyboardType = .decimalPad

        applyButton.setTitle("应用筛选", for: .normal)
        applyButton.addTarget(self, action: #selector(applyFilter), for: .touchUpInside)

        let priceRow = UIStackView(arrangedSubviews: [minField, maxField, applyButton])
        priceRow.axis = .horizontal
        priceRow.spacing = 8
        priceRow.distribution = .fillEqually

        let filterStack = UIStackView(arrangedSubviews: [brandButton, priceRow])
        filterStack.axis = .vertical
        filterStack.spacing = 8
        filterStack.translatesAutoresizingMaskIntoConstraints = false

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

        view.addSubview(filterStack)
        view.addSubview(collectionView)

        let guide = view.safeAreaLayoutGuide
        NSLayoutConstraint.activate([
            filterStack.topAnchor.constraint(equalTo: guide.topAnchor, constant: 8),
            filterStack.leadingAnchor.constraint(equalTo: guide.leadingAnchor, constant: 12),
            filterStack.trailingAnchor.constraint(equalTo: guide.trailingAnchor, constant: -12),

            collectionView.topAnchor.constraint(equalTo: filterStack.bottomAnchor, constant: 8),
            collectionView.leadingAnchor.constraint(equalTo: guide.leadingAnchor),
            collectionView.trailingAnchor.constraint(equalTo: guide.trailingAnchor),
            collectionView.bottomAnchor.constraint(equalTo: guide.bottomAnchor)
        ])

        applyFilter()
    }

    @objc private func pickBrand() {
        let ac = UIAlertController(title: "品牌", message: nil, preferredStyle: .actionSheet)
        for b in brandOptions {
            ac.addAction(UIAlertAction(title: b, style: .default, handler: { [weak self] _ in
                self?.selectedBrand = (b == "全部") ? nil : b
                self?.brandButton.setTitle("品牌：\(b)", for: .normal)
                self?.applyFilter()
            }))
        }
        ac.addAction(UIAlertAction(title: "取消", style: .cancel))
        if let pop = ac.popoverPresentationController {
            pop.sourceView = brandButton
            pop.sourceRect = brandButton.bounds
        }
        present(ac, animated: true)
    }

    @objc private func applyFilter() {
        let minStr = minField.text?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
        let maxStr = maxField.text?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
        var minPrice = Double(-Double.greatestFiniteMagnitude)
        var maxPrice = Double.greatestFiniteMagnitude
        if let v = Double(minStr) { minPrice = v }
        if let v = Double(maxStr) { maxPrice = v }
        if minPrice > maxPrice {
            let ac = UIAlertController(title: nil, message: "最低价不能大于最高价", preferredStyle: .alert)
            ac.addAction(UIAlertAction(title: "确定", style: .default))
            present(ac, animated: true)
            return
        }

        displayList = baseList.filter { p in
            if let b = selectedBrand, b != p.brand { return false }
            if p.price < minPrice || p.price > maxPrice { return false }
            return true
        }
        collectionView.reloadData()
    }

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return displayList.count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: ProductGridCell.reuseId, for: indexPath) as! ProductGridCell
        let p = displayList[indexPath.item]
        cell.configure(product: p, showFavorite: true, onFavoriteChange: { [weak self] in
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
