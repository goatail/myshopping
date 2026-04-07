//
//  DataGenerator.swift
//  myshopping
//
//  逻辑对齐 Android DataGenerator：按分类批量生成占位商品数据
//

import Foundation

enum DataGenerator {

    private static let mobileTitles = [
        "Apple/苹果 17 Pro", "Apple/苹果 17 Air", "Apple/苹果 17",
        "HUAWEI/华为 Mate 70 Pro 鸿蒙AI 红枫原色影像 超可靠玄武架构 旗舰智能手机-178",
        "华为nova15 Pro 新品麒麟9系芯片 前后红枫影像 华为直屏鸿蒙手机官方旗舰店正品2127",
        "华为畅享 80 超能续航玄甲架构双五星超耐摔鸿蒙手机百亿补贴官方"
    ]
    private static let mobileSellerNames = [
        "苹果官方旗舰店", "苹果官方旗舰店", "苹果官方旗舰店",
        "华为官方旗舰店", "华为官方旗舰店", "华为官方旗舰店"
    ]
    private static let mobileNames = ["苹果 17 Pro", "苹果 17 Air", "苹果 17", "华为 Mate 70 Pro", "华为 nova15 Pro", "华为 畅享 80"]
    private static let mobileBrands = ["苹果", "苹果", "苹果", "华为", "华为", "华为"]
    private static let mobileDescriptions = [
        "Apple/苹果 17 Pro 支持国补，性能强悍，顶尖的 Pro 拍摄系统，后摄 4800 万",
        "Apple/苹果 17 Air 支持 eSIM，性能强悍",
        "Apple/苹果 17，性能强悍",
        "【晒单享好礼】HUAWEI/华为 Mate 70 Pro 鸿蒙AI 红枫原色影像 超可靠玄武架构 旗舰智能手机-178",
        "【国家补贴15%】华为nova15 Pro 新品麒麟9系芯片 前后红枫影像 华为直屏鸿蒙手机官方旗舰店正品2127",
        "华为畅享 80 超能续航玄甲架构双五星超耐摔鸿蒙手机百亿补贴官方"
    ]
    private static let mobilePrices: [Double] = [8999, 6999, 7999, 6999, 5999, 2999]

    private static let pcTitles = [
        "【国补】Acer宏碁超薄品牌电脑一体机2025新款24英寸家用办公游戏壁挂14代高配I5i7宏基27大屏台式机全套整机",
        "【人气爆款】联想小新14SE/小新15/小新16 SE可选 2025锐龙轻薄本笔记本电脑 学生办公性价比电脑 官方正品",
        "【国家补贴15%】HP/惠普可选星book 14/15可选锐龙R5处理器笔记本电脑学生办公本惠普官方旗舰店",
        "DELL/戴尔 灵越16 Plus 英特尔酷睿i7/core7笔记本电脑轻薄本商务便携办公电脑灵越7000轻薄笔记本电脑",
        "神舟战神s8/z8游戏笔记本电脑5060独显13代酷睿i7满血学生电竞本"
    ]
    private static let pcSellerNames = ["宏基官方旗舰店", "联想官方旗舰店", "惠普官方旗舰店", "戴尔官方旗舰店", "神舟官方旗舰店"]
    private static let pcNames = ["Acer非凡", "联想 14SE", "惠普 book14", "戴尔灵越 16Plus", "神舟战神 s8"]
    private static let pcBrands = ["宏基", "联想", "惠普", "戴尔", "神舟"]
    private static let pcDescriptions = pcTitles
    private static let pcPrices: [Double] = [3789.9, 3399.15, 2889.06, 4599, 2899.3]

    private static let outdoorTitles = [
        "骆驼户外折叠椅月亮椅露营野餐椅子沙滩便携凳子野外写生钓鱼桌椅",
        "骆驼清风帐篷户外黑胶全自动便携式折叠加厚防雨野营露营装备套餐",
        "camel户外露营聚拢手推车折叠野餐营地车大容量旅行拉车儿童可躺",
        "骆驼专业户外登山爬山徒步7系铝合金伸缩登山杖手杖",
        "骆驼双人户外吊床秋千成人加厚防侧翻寝室室内学生吊椅露营大吊床"
    ]
    private static let outdoorSeller = "骆驼官方旗舰店"
    private static let outdoorNames = ["折叠椅", "帐篷", "手推车", "登山杖", "吊床"]
    private static let outdoorBrands = ["骆驼", "骆驼", "骆驼", "骆驼", "骆驼"]
    private static let outdoorDescriptions = outdoorTitles
    private static let outdoorPrices: [Double] = [120, 356, 209, 87.66, 99]

    private static let clothTitles = [
        "HM女装毛呢外套25冬季新款静奢老钱风双面呢长款羊毛大衣1000031",
        "HM女装红色毛针织衫长袖宽松圆领上衣1269572",
        "HM女装毛呢外套冬季宽松毛毡纽扣翻领及膝大衣1255546",
        "HM男装卫衣冬季半拉链加绒立领宽松美式慵懒重磅套头上衣1245648",
        "HM男装羽绒服冬季户外运动防风疏水女装轻薄防寒服外套1238584"
    ]
    private static let clothSeller = "HM官方旗舰店"
    private static let clothNames = ["羊毛大衣", "针织衫", "毛呢外套", "卫衣", "羽绒服"]
    private static let clothBrands = ["HM", "HM", "HM", "HM", "HM"]
    private static let clothDescriptions = clothTitles
    private static let clothPrices: [Double] = [659, 132, 523, 163, 242]

    private static let foodTitles = [
        "杏花楼中华老字号万家灯火糕点年货礼盒上海特产伴手礼礼物1210g",
        "杏花楼广式腊肠 香肠227g 煲仔饭腊肠 腊味 中华老字号",
        "杏花楼老字号咸蛋黄肉松青团礼盒装糯米团子上海豆沙团子麻薯糕点",
        "杏花楼中华老字号上海腊海鸭风干腊味年货熟食真空包装750g",
        "杏花楼中华老字号 鸡仔饼250g袋糕点传统点心散装袋装零食上海"
    ]
    private static let foodSeller = "杏花楼旗舰店"
    private static let foodNames = ["糕点", "腊肠", "肉松", "腊鸭", "鸡仔饼"]
    private static let foodBrands = ["杏花楼", "杏花楼", "杏花楼", "杏花楼", "杏花楼"]
    private static let foodDescriptions = foodTitles
    private static let foodPrices: [Double] = [191.16, 49.3, 14.30, 147.05, 28]

    static func generateProducts() -> [Product] {
        var products: [Product] = []
        let n = 35
        for i in 0..<n {
            let t = i % mobileTitles.count
            products.append(Product(
                id: "phone\(i)",
                title: mobileTitles[t],
                sellerName: mobileSellerNames[t],
                viewsCount: (t % 2 == 0 ? "180万" : "160万") + "浏览",
                transactionCount: t % 2 == 0 ? "2万+" : "3万+",
                imageIndex: t,
                name: mobileNames[t],
                description: mobileDescriptions[t],
                price: mobilePrices[t],
                category: "手机",
                brand: mobileBrands[t]
            ))
        }
        for i in 0..<n {
            let t = i % pcTitles.count
            products.append(Product(
                id: "pc\(i)",
                title: pcTitles[t],
                sellerName: pcSellerNames[t],
                viewsCount: pcSellerNames[t].hashValue % 3 == 0 ? "90万浏览" : "120万浏览",
                transactionCount: "1万+",
                imageIndex: t,
                name: pcNames[t],
                description: pcDescriptions[t],
                price: pcPrices[t],
                category: "电脑",
                brand: pcBrands[t]
            ))
        }
        for i in 0..<n {
            let t = i % outdoorTitles.count
            products.append(Product(
                id: "outdoor\(i)",
                title: outdoorTitles[t],
                sellerName: outdoorSeller,
                viewsCount: "20万+浏览",
                transactionCount: "5千+",
                imageIndex: t,
                name: outdoorNames[t],
                description: outdoorDescriptions[t],
                price: outdoorPrices[t],
                category: "户外",
                brand: outdoorBrands[t]
            ))
        }
        for i in 0..<n {
            let t = i % clothTitles.count
            products.append(Product(
                id: "cloth\(i)",
                title: clothTitles[t],
                sellerName: clothSeller,
                viewsCount: "100万+浏览",
                transactionCount: "1万+",
                imageIndex: t,
                name: clothNames[t],
                description: clothDescriptions[t],
                price: clothPrices[t],
                category: "衣服",
                brand: clothBrands[t]
            ))
        }
        for i in 0..<n {
            let t = i % foodTitles.count
            products.append(Product(
                id: "food\(i)",
                title: foodTitles[t],
                sellerName: foodSeller,
                viewsCount: "10万+浏览",
                transactionCount: "4千+",
                imageIndex: t,
                name: foodNames[t],
                description: foodDescriptions[t],
                price: foodPrices[t],
                category: "零食",
                brand: foodBrands[t]
            ))
        }
        return products
    }

    static func getAllProducts() -> [Product] {
        return generateProducts()
    }

    static func getProductById(_ productId: String) -> Product? {
        return getAllProducts().first { $0.id == productId }
    }

    static func getProductsByCategory(_ category: String) -> [Product] {
        return getAllProducts().filter { $0.category == category }
    }

    static func searchByKeyword(_ keyword: String?) -> [Product] {
        guard let raw = keyword?.trimmingCharacters(in: .whitespacesAndNewlines), !raw.isEmpty else {
            return getAllProducts()
        }
        let lower = raw.lowercased()
        return getAllProducts().filter { p in
            return p.title.lowercased().contains(lower)
                || p.name.lowercased().contains(lower)
                || p.description.lowercased().contains(lower)
                || p.category.lowercased().contains(lower)
                || p.brand.lowercased().contains(lower)
                || p.sellerName.lowercased().contains(lower)
        }
    }

    static func getDistinctCategories() -> [String] {
        var list: [String] = []
        for p in getAllProducts() {
            if !list.contains(p.category) {
                list.append(p.category)
            }
        }
        return list
    }

    static func getDistinctBrands() -> [String] {
        var list: [String] = []
        for p in getAllProducts() {
            if !list.contains(p.brand) {
                list.append(p.brand)
            }
        }
        return list.sorted()
    }
}
