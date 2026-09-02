import XCTest
import SwiftData
@testable import AutoLedger

final class LedgerTests: XCTestCase {

    @MainActor
    func testAmountStoredAsFenWithExactDecimal() {
        let tx = Transaction(amountInFen: 12345, merchant: "测试商户", channel: .wechatPay)
        XCTAssertEqual(tx.amountInFen, 12345)
        XCTAssertEqual(tx.amount, Decimal(123.45))
        XCTAssertEqual(tx.channel, .wechatPay)
        XCTAssertEqual(tx.channelRawValue, "微信支付")
    }

    @MainActor
    func testMonthRangeSpansExactlyOneMonth() {
        let calendar = Calendar(identifier: .gregorian)
        let anchor = calendar.date(from: DateComponents(year: 2026, month: 9, day: 15))!
        let range = LedgerAggregator.monthRange(containing: anchor, calendar: calendar)
        XCTAssertEqual(calendar.component(.month, from: range.start), 9)
        XCTAssertEqual(calendar.component(.day, from: range.start), 1)
        XCTAssertEqual(calendar.component(.month, from: range.end), 10)
        XCTAssertEqual(calendar.component(.day, from: range.end), 1)
    }

    @MainActor
    func testMonthlySummaryFiltersByMonthAndGroupsByCategory() {
        let calendar = Calendar(identifier: .gregorian)
        let sep = calendar.date(from: DateComponents(year: 2026, month: 9, day: 15))!
        let aug = calendar.date(from: DateComponents(year: 2026, month: 8, day: 15))!

        let tx1 = Transaction(amountInFen: 1000, merchant: "午餐", date: sep, categoryName: "餐饮")
        let tx2 = Transaction(amountInFen: 2500, merchant: "奶茶", date: sep, categoryName: "餐饮")
        let tx3 = Transaction(amountInFen: 5000, merchant: "打车", date: sep, categoryName: "交通")
        let tx4 = Transaction(amountInFen: 9999, merchant: "上月开销", date: aug, categoryName: "餐饮")

        let summary = LedgerAggregator.summarize(transactions: [tx1, tx2, tx3, tx4], in: sep, calendar: calendar)

        XCTAssertEqual(summary.totalInFen, 8500)
        XCTAssertEqual(summary.byCategory.count, 2)
        XCTAssertEqual(summary.byCategory.first?.category, "交通")
        XCTAssertEqual(summary.byCategory.first?.totalInFen, 5000)
        XCTAssertEqual(summary.byCategory.last?.category, "餐饮")
        XCTAssertEqual(summary.byCategory.last?.totalInFen, 3500)
    }

    @MainActor
    func testStorePersistsAndReadsTransactions() {
        let store = LedgerStore(inMemory: true)
        store.seedDefaultCategoriesIfNeeded()

        let tx = store.insertTransaction(
            amountInFen: 1999,
            merchant: "肯德基",
            channel: .meituan,
            categoryName: "餐饮"
        )

        let all = store.fetchAll()
        XCTAssertEqual(all.count, 1)
        XCTAssertEqual(all.first?.merchant, "肯德基")
        XCTAssertEqual(all.first?.amountInFen, 1999)
        XCTAssertTrue(all.first?.isConfirmed == true)
        XCTAssertEqual(all.first?.channel, .meituan)
        XCTAssertEqual(tx.id, all.first?.id)
    }

    @MainActor
    func testSeedCategoriesIsIdempotent() throws {
        let store = LedgerStore(inMemory: true)
        store.seedDefaultCategoriesIfNeeded()

        let context = store.container.mainContext
        let count = try context.fetchCount(FetchDescriptor<LedgerCategory>())
        XCTAssertEqual(count, LedgerStore.defaultCategories.count)

        store.seedDefaultCategoriesIfNeeded()
        let countAfterSecondSeed = try context.fetchCount(FetchDescriptor<LedgerCategory>())
        XCTAssertEqual(countAfterSecondSeed, count)
    }
}