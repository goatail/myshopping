//
//  Product.swift
//  myshopping
//
//  对应 Android com.example.myshopping.model.Product
//

import Foundation

/// 商品模型
struct Product: Equatable {
    let id: String
    var title: String
    var sellerName: String
    var viewsCount: String
    var transactionCount: String
    /// 用于界面占位色或后续接入 Assets 的图片索引
    var imageIndex: Int
    var name: String
    var description: String
    var price: Double
    /// 手机、电脑、户外、衣服、零食
    var category: String
    var brand: String
}
