//
//  HomeViewController.swift
//  myshopping
//
//  对应 Android HomeFragment：假搜索框 + TabLayout/ViewPager 分类
//

import UIKit

final class HomeViewController: UIViewController, UIPageViewControllerDataSource, UIPageViewControllerDelegate {

    private let categories = ["手机", "电脑", "户外", "衣服", "零食"]
    private let defaultSearchHint = "搜索手机、电脑、户外、衣服"

    private let searchButton = UIButton(type: .system)
    private let searchHintLabel = UILabel()
    private var headerStack: UIStackView!
    private var segmented: UISegmentedControl!
    private var pageController: UIPageViewController!
    private var pages: [CategoryProductsViewController] = []
    private var currentIndex = 0

    override func viewDidLoad() {
        super.viewDidLoad()
        title = "首页"
        view.backgroundColor = UIColor(white: 0.96, alpha: 1)
        setupSearchHeader()
        setupPages()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        updateSearchHint()
        // 与 Android HomeFragment 一致：有待应用的关键词时切到第一个分类（手机）并刷新列表
        syncFirstCategoryForPendingSearch()
    }

    /// 当从搜索栈返回且存在待消费关键词时，切换到「手机」并触发分类页 `reloadProducts`
    private func syncFirstCategoryForPendingSearch() {
        guard SearchState.hasPendingKeyword() else { return }
        segmented.selectedSegmentIndex = 0
        currentIndex = 0
        pageController.setViewControllers([pages[0]], direction: .forward, animated: false, completion: nil)
        pages[0].reloadProducts()
    }

    private func setupSearchHeader() {
        searchButton.layer.cornerRadius = 8
        searchButton.backgroundColor = .white
        searchButton.contentHorizontalAlignment = .left
        searchButton.contentEdgeInsets = UIEdgeInsets(top: 10, left: 12, bottom: 10, right: 12)
        searchButton.addTarget(self, action: #selector(openSearch), for: .touchUpInside)
        searchButton.translatesAutoresizingMaskIntoConstraints = false

        searchHintLabel.font = UIFont.systemFont(ofSize: 14)
        searchHintLabel.textColor = .lightGray
        searchHintLabel.translatesAutoresizingMaskIntoConstraints = false
        searchButton.addSubview(searchHintLabel)

        NSLayoutConstraint.activate([
            searchHintLabel.leadingAnchor.constraint(equalTo: searchButton.leadingAnchor, constant: 12),
            searchHintLabel.centerYAnchor.constraint(equalTo: searchButton.centerYAnchor)
        ])

        segmented = UISegmentedControl(items: categories)
        segmented.selectedSegmentIndex = 0
        segmented.addTarget(self, action: #selector(segmentChanged), for: .valueChanged)
        segmented.translatesAutoresizingMaskIntoConstraints = false

        headerStack = UIStackView(arrangedSubviews: [searchButton, segmented])
        headerStack.axis = .vertical
        headerStack.spacing = 12
        headerStack.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(headerStack)

        let guide = view.safeAreaLayoutGuide
        NSLayoutConstraint.activate([
            headerStack.topAnchor.constraint(equalTo: guide.topAnchor, constant: 8),
            headerStack.leadingAnchor.constraint(equalTo: guide.leadingAnchor, constant: 12),
            headerStack.trailingAnchor.constraint(equalTo: guide.trailingAnchor, constant: -12),
            searchButton.heightAnchor.constraint(equalToConstant: 40)
        ])
    }

    private func setupPages() {
        pages = categories.map { CategoryProductsViewController(category: $0) }
        pageController = UIPageViewController(transitionStyle: .scroll, navigationOrientation: .horizontal, options: nil)
        pageController.dataSource = self
        pageController.delegate = self
        pageController.setViewControllers([pages[0]], direction: .forward, animated: false, completion: nil)

        addChild(pageController)
        pageController.view.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(pageController.view)
        pageController.didMove(toParent: self)

        NSLayoutConstraint.activate([
            pageController.view.topAnchor.constraint(equalTo: headerStack.bottomAnchor, constant: 8),
            pageController.view.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            pageController.view.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            pageController.view.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
    }

    private func updateSearchHint() {
        let text = SearchState.getLastDisplayedKeyword()
        searchHintLabel.text = (text == nil || text!.isEmpty) ? defaultSearchHint : text!
    }

    @objc private func openSearch() {
        navigationController?.pushViewController(SearchViewController(), animated: true)
    }

    @objc private func segmentChanged() {
        let idx = segmented.selectedSegmentIndex
        guard idx != currentIndex, idx >= 0, idx < pages.count else { return }
        let dir: UIPageViewController.NavigationDirection = idx > currentIndex ? .forward : .reverse
        currentIndex = idx
        pageController.setViewControllers([pages[idx]], direction: dir, animated: true, completion: nil)
    }

    func pageViewController(_ pageViewController: UIPageViewController, viewControllerBefore viewController: UIViewController) -> UIViewController? {
        guard let vc = viewController as? CategoryProductsViewController,
              let i = pages.firstIndex(where: { $0 === vc }), i > 0 else { return nil }
        return pages[i - 1]
    }

    func pageViewController(_ pageViewController: UIPageViewController, viewControllerAfter viewController: UIViewController) -> UIViewController? {
        guard let vc = viewController as? CategoryProductsViewController,
              let i = pages.firstIndex(where: { $0 === vc }), i < pages.count - 1 else { return nil }
        return pages[i + 1]
    }

    func pageViewController(_ pageViewController: UIPageViewController, didFinishAnimating finished: Bool, previousViewControllers: [UIViewController], transitionCompleted completed: Bool) {
        guard completed,
              let cur = pageViewController.viewControllers?.first as? CategoryProductsViewController,
              let idx = pages.firstIndex(where: { $0 === cur }) else { return }
        currentIndex = idx
        segmented.selectedSegmentIndex = idx
    }
}
