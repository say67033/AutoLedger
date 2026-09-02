import XCTest
@testable import AutoLedger

final class ConfirmationFlowTests: XCTestCase {

    @MainActor
    func testDraftAndConfirmFlow() {
        let store = LedgerStore(inMemory: true)
        let draft = store.insertTransaction(
            amountInFen: 8990,
            merchant: "某咖啡店",
            channel: .wechatPay,
            categoryName: "餐饮",
            isConfirmed: false
        )

        XCTAssertEqual(store.fetchDrafts().count, 1)
        XCTAssertEqual(store.fetchConfirmed().count, 0)

        draft.isConfirmed = true
        try? store.container.mainContext.save()

        XCTAssertEqual(store.fetchDrafts().count, 0)
        XCTAssertEqual(store.fetchConfirmed().count, 1)
    }

    @MainActor
    func testSummaryCountsOnlyConfirmed() {
        let store = LedgerStore(inMemory: true)
        store.insertTransaction(amountInFen: 1000, merchant: "草稿", isConfirmed: false)
        store.insertTransaction(amountInFen: 2000, merchant: "已确认", isConfirmed: true)

        let confirmed = store.fetchConfirmed()
        let summary = LedgerAggregator.summarize(transactions: confirmed, in: .now)
        XCTAssertEqual(summary.totalInFen, 2000)
    }
}