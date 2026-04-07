//
//  Order.swift
//  myshopping
//

import Foundation

/// 订单（结算后生成）
struct Order: Equatable {
    let id: String
    let createTime: TimeInterval
    var items: [CartItem]
    let totalPrice: Double
    let address: Address
    /// 如：待付款、待发货、待收货、待评价、退款/售后
    let status: String
}
