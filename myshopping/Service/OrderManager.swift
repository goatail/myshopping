//
//  OrderManager.swift
//  myshopping
//

import Foundation

enum OrderManager {
    private static var orders: [Order] = []

    static func addOrder(_ order: Order) {
        orders.append(order)
    }

    static func getAllOrders() -> [Order] {
        return orders
    }

    static func getOrdersByStatus(_ status: String) -> [Order] {
        return orders.filter { $0.status == status }
    }

    static func getPendingPaymentCount() -> Int {
        return getOrdersByStatus("待付款").count
    }

    static func getPendingShipmentCount() -> Int {
        return getOrdersByStatus("待发货").count
    }

    static func getPendingReceiptCount() -> Int {
        return getOrdersByStatus("待收货").count
    }

    static func getPendingReviewCount() -> Int {
        return getOrdersByStatus("待评价").count
    }

    static func getRefundCount() -> Int {
        return getOrdersByStatus("退款/售后").count
    }
}
