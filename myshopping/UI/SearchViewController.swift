//
//  SearchViewController.swift
//  myshopping
//
//  对应 Android SearchActivity
//

import UIKit

final class SearchViewController: UIViewController {

    private let field = UITextField()
    private let searchBtn = UIButton(type: .system)

    override func viewDidLoad() {
        super.viewDidLoad()
        title = "搜索商品"
        view.backgroundColor = .white

        field.placeholder = "输入关键词"
        field.borderStyle = .roundedRect
        field.returnKeyType = .search
        field.delegate = self
        field.translatesAutoresizingMaskIntoConstraints = false

        searchBtn.setTitle("搜索", for: .normal)
        searchBtn.addTarget(self, action: #selector(performSearch), for: .touchUpInside)
        searchBtn.translatesAutoresizingMaskIntoConstraints = false

        let row = UIStackView(arrangedSubviews: [field, searchBtn])
        row.axis = .horizontal
        row.spacing = 8
        row.translatesAutoresizingMaskIntoConstraints = false

        view.addSubview(row)
        let guide = view.safeAreaLayoutGuide
        NSLayoutConstraint.activate([
            row.topAnchor.constraint(equalTo: guide.topAnchor, constant: 16),
            row.leadingAnchor.constraint(equalTo: guide.leadingAnchor, constant: 16),
            row.trailingAnchor.constraint(equalTo: guide.trailingAnchor, constant: -16),
            field.heightAnchor.constraint(equalToConstant: 40),
            searchBtn.widthAnchor.constraint(equalToConstant: 72)
        ])
    }

    @objc private func performSearch() {
        let keyword = field.text?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
        if keyword.isEmpty {
            let ac = UIAlertController(title: nil, message: "请输入搜索关键词", preferredStyle: .alert)
            ac.addAction(UIAlertAction(title: "确定", style: .default))
            present(ac, animated: true)
            return
        }
        SearchState.setLastDisplayedKeyword(keyword)
        let resultVC = SearchResultViewController(keyword: keyword)
        // 与 Android SearchActivity 一致：进入结果页后搜索页不再留在返回栈上（finish）
        guard let nav = navigationController else { return }
        let keep = nav.viewControllers.filter { !($0 is SearchViewController) }
        nav.setViewControllers(keep + [resultVC], animated: true)
    }
}

extension SearchViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        performSearch()
        return true
    }
}
