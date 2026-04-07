//
//  CartItem.swift
//  myshopping
//

import Foundation

/// 购物车行
struct CartItem: Equatable {
    var product: Product
    var quantity: Int

    var totalPrice: Double {
        return product.price * Double(quantity)
    }
}
