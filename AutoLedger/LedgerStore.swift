import Foundation
import SwiftData

final class LedgerStore {
    let container: ModelContainer

    static let defaultCategories: [(name: String, icon: String, keywords: [String])] = [
        ("餐饮", "fork.knife", ["外卖", "美团", "饿了么", "餐厅", "咖啡", "奶茶", "麦当劳", "肯德基", "小吃"]),
        ("购物", "cart", ["淘宝", "京东", "拼多多", "商城", "购物", "订单", "抖音"]),
        ("交通", "car", ["滴滴", "打车", "地铁", "公交", "加油", "停车", "高铁", "火车", "机票"]),
        ("娱乐", "gamecontroller", ["电影", "游戏", "视频", "会员", "演出", "KTV"]),
        ("生活缴费", "bolt", ["电费", "水费", "燃气", "话费", "宽带", "物业"]),
        ("医疗", "cross.case", ["医院", "药", "挂号", "诊所", "体检"]),
        ("转账", "arrow.left.arrow.right", ["转账", "红包"]),
        ("其他", "ellipsis.circle", []),
    ]

    init(inMemory: Bool = false) {
        let schema = Schema([Transaction.self, LedgerCategory.self])
        let configuration = ModelConfiguration(schema: schema, isStoredInMemoryOnly: inMemory)
        do {
            container = try ModelContainer(for: schema, configurations: [configuration])
        } catch {
            fatalError("无法初始化本地数据库: \(error)")
        }
    }

    @MainActor
    func seedDefaultCategoriesIfNeeded() {
        let context = container.mainContext
        let existing = (try? context.fetchCount(FetchDescriptor<LedgerCategory>())) ?? 0
        guard existing == 0 else { return }
        for item in Self.defaultCategories {
            context.insert(LedgerCategory(name: item.name, icon: item.icon, keywords: item.keywords))
        }
        try? context.save()
    }

    @MainActor
    @discardableResult
    func insertTransaction(
        amountInFen: Int64,
        merchant: String,
        channel: PaymentChannel = .other,
        date: Date = .now,
        categoryName: String = "未分类",
        sourceImageFileName: String? = nil,
        note: String? = nil
    ) -> Transaction {
        let tx = Transaction(
            amountInFen: amountInFen,
            merchant: merchant,
            channel: channel,
            date: date,
            categoryName: categoryName,
            sourceImageFileName: sourceImageFileName,
            isConfirmed: true,
            note: note
        )
        container.mainContext.insert(tx)
        try? container.mainContext.save()
        return tx
    }

    @MainActor
    func fetchAll() -> [Transaction] {
        let descriptor = FetchDescriptor<Transaction>(
            sortBy: [SortDescriptor(\.date, order: .reverse)]
        )
        return (try? container.mainContext.fetch(descriptor)) ?? []
    }
}