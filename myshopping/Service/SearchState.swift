//
//  SearchState.swift
//  myshopping
//

import Foundation

/// 搜索关键词状态（内存，与 Android SearchState 一致）
enum SearchState {
    private static var pendingKeyword: String?
    private static var lastDisplayedKeyword: String?

    static func setSearchKeyword(_ keyword: String?) {
        pendingKeyword = keyword
    }

    static func setLastDisplayedKeyword(_ keyword: String?) {
        if let k = keyword {
            lastDisplayedKeyword = k.trimmingCharacters(in: .whitespacesAndNewlines)
        } else {
            lastDisplayedKeyword = nil
        }
    }

    static func getLastDisplayedKeyword() -> String? {
        return lastDisplayedKeyword
    }

    static func hasPendingKeyword() -> Bool {
        guard let p = pendingKeyword else { return false }
        return !p.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }

    /// 获取并清空待处理关键词，供首页「手机」分类 Tab 使用
    static func getAndClearSearchKeyword() -> String? {
        let k = pendingKeyword
        pendingKeyword = nil
        return k
    }
}
