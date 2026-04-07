//
//  AddressManager.swift
//  myshopping
//

import Foundation

enum AddressManager {
    private static let keyList = "address_list"

    private static func loadFromStorage() -> [Address] {
        guard let data = UserDefaults.standard.data(forKey: keyList),
              let list = try? JSONDecoder().decode([Address].self, from: data) else {
            let def = Address(
                id: "addr_default",
                name: "张三",
                phone: "13800138000",
                province: "北京市",
                city: "市辖区",
                district: "朝阳区",
                detail: "中关村大街1号",
                isDefault: true
            )
            saveToStorage([def])
            return [def]
        }
        return list
    }

    private static func saveToStorage(_ list: [Address]) {
        if let data = try? JSONEncoder().encode(list) {
            UserDefaults.standard.set(data, forKey: keyList)
        }
    }

    static func getAllAddresses() -> [Address] {
        return loadFromStorage()
    }

    static func getAddressById(_ addressId: String) -> Address? {
        return loadFromStorage().first { $0.id == addressId }
    }

    static func getDefaultAddress() -> Address? {
        let list = loadFromStorage()
        if let d = list.first(where: { $0.isDefault }) {
            return d
        }
        return list.first
    }

    /// 新增地址，返回最终 id（与 Android 添加后 `setDefaultAddress(id)` 一致使用）
    @discardableResult
    static func addAddress(_ address: Address) -> String {
        var list = loadFromStorage()
        var a = address
        if a.id.isEmpty {
            a.id = "addr_" + String(UUID().uuidString.prefix(8))
        }
        if list.isEmpty {
            a.isDefault = true
        }
        list.append(a)
        saveToStorage(list)
        return a.id
    }

    static func updateAddress(_ address: Address) {
        var list = loadFromStorage()
        guard let idx = list.firstIndex(where: { $0.id == address.id }) else { return }
        list[idx] = address
        saveToStorage(list)
    }

    static func removeAddress(_ addressId: String) {
        var list = loadFromStorage()
        list.removeAll { $0.id == addressId }
        saveToStorage(list)
    }

    static func setDefaultAddress(_ addressId: String) {
        var list = loadFromStorage()
        for i in list.indices {
            list[i].isDefault = (list[i].id == addressId)
        }
        saveToStorage(list)
    }
}
