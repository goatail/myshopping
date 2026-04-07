//
//  CartManager.swift
//  myshopping
//

import Foundation

/// 购物车（内存，与 Android 一致）
enum CartManager {

    /// 购物车数据变更（用于 Tab 角标等）
    static let cartDidChangeNotification = Notification.Name("myshopping.CartDidChange")

    private static var cartItems: [CartItem] = []

    private static func postChange() {
        NotificationCenter.default.post(name: cartDidChangeNotification, object: nil)
    }

    static func addToCart(product: Product, quantity: Int) {
        if let idx = cartItems.firstIndex(where: { $0.product.id == product.id }) {
            var item = cartItems[idx]
            item.quantity += quantity
            cartItems[idx] = item
        } else {
            cartItems.append(CartItem(product: product, quantity: quantity))
        }
        postChange()
    }

    static func removeFromCart(productId: String) {
        cartItems.removeAll { $0.product.id == productId }
        postChange()
    }

    static func updateQuantity(productId: String, quantity: Int) {
        guard let idx = cartItems.firstIndex(where: { $0.product.id == productId }) else { return }
        if quantity <= 0 {
            cartItems.remove(at: idx)
        } else {
            var item = cartItems[idx]
            item.quantity = quantity
            cartItems[idx] = item
        }
        postChange()
    }

    static func getCartItems() -> [CartItem] {
        return cartItems
    }

    static func clearCart() {
        cartItems.removeAll()
        postChange()
    }

    /// 购物车中商品种类数（用于角标）
    static func cartLineCount() -> Int {
        return cartItems.count
    }

    static func getTotalPrice() -> Double {
        return cartItems.reduce(0) { $0 + $1.totalPrice }
    }
}
