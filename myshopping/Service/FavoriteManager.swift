//
//  FavoriteManager.swift
//  myshopping
//

import Foundation

enum FavoriteManager {
    private static let prefName = "favorite_prefs"
    private static let keyIds = "favorite_product_ids"

    private static func loadIds() -> Set<String> {
        guard let arr = UserDefaults.standard.array(forKey: keyIds) as? [String] else {
            return []
        }
        return Set(arr)
    }

    private static func saveIds(_ set: Set<String>) {
        UserDefaults.standard.set(Array(set), forKey: keyIds)
    }

    static func addFavorite(productId: String) {
        var s = loadIds()
        s.insert(productId)
        saveIds(s)
    }

    static func removeFavorite(productId: String) {
        var s = loadIds()
        s.remove(productId)
        saveIds(s)
    }

    @discardableResult
    static func toggleFavorite(productId: String) -> Bool {
        if isFavorite(productId: productId) {
            removeFavorite(productId: productId)
            return false
        }
        addFavorite(productId: productId)
        return true
    }

    static func isFavorite(productId: String) -> Bool {
        return loadIds().contains(productId)
    }

    static func getFavoriteProducts() -> [Product] {
        let ids = loadIds()
        var list: [Product] = []
        for p in DataGenerator.getAllProducts() where ids.contains(p.id) {
            list.append(p)
        }
        return list
    }
}
