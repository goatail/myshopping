//
//  CartManager.swift
//  myshopping
//

import Foundation

/// 购物车（内存，与 Android 一致）
enum CartManager {
    private static var cartItems: [CartItem] = []

    static func addToCart(product: Product, quantity: Int) {
        if let idx = cartItems.firstIndex(where: { $0.product.id == product.id }) {
            var item = cartItems[idx]
            item.quantity += quantity
            cartItems[idx] = item
        } else {
            cartItems.append(CartItem(product: product, quantity: quantity))
        }
    }

    static func removeFromCart(productId: String) {
        cartItems.removeAll { $0.product.id == productId }
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
    }

    static func getCartItems() -> [CartItem] {
        return cartItems
    }

    static func clearCart() {
        cartItems.removeAll()
    }

    static func getTotalPrice() -> Double {
        return cartItems.reduce(0) { $0 + $1.totalPrice }
    }
}
