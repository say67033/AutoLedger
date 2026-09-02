import XCTest
@testable import AutoLedger

final class ScreenshotPipelineTests: XCTestCase {

    @MainActor
    func testProcessCreatesUnconfirmedDraft() {
        let store = LedgerStore(inMemory: true)
        let pipeline = ScreenshotPipeline(store: store)

        let lines = [
            "微信支付",
            "商户：某咖啡店",
            "交易时间：2026-09-02 09:50:44",
            "支付金额：¥89.90",
        ]

        let tx = pipeline.process(ocrLines: lines)

        XCTAssertEqual(tx.amountInFen, 8990)
        XCTAssertEqual(tx.channel, .wechatPay)
        XCTAssertEqual(tx.categoryName, "餐饮")
        XCTAssertEqual(tx.merchant, "某咖啡店")
        XCTAssertEqual(tx.isConfirmed, false)
        XCTAssertEqual(store.fetchAll().count, 1)
    }

    func testMerchantHint() {
        XCTAssertEqual(ScreenshotPipeline.merchantHint(from: ["商户：某餐厅", "金额：10元"]), "某餐厅")
        XCTAssertEqual(ScreenshotPipeline.merchantHint(from: ["金额：10元"]), "未知商户")
    }
}