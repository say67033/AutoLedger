import XCTest
@testable import AutoLedger

final class CategoryEngineTests: XCTestCase {

    func testCategorizeDining() {
        XCTAssertEqual(CategoryEngine.categorize("美团外卖 某餐厅"), "餐饮")
    }

    func testCategorizeTransport() {
        XCTAssertEqual(CategoryEngine.categorize("滴滴打车"), "交通")
    }

    func testCategorizeShopping() {
        XCTAssertEqual(CategoryEngine.categorize("淘宝购物订单"), "购物")
    }

    func testCategorizeUtilities() {
        XCTAssertEqual(CategoryEngine.categorize("缴纳电费"), "生活缴费")
    }

    func testCategorizeTransfer() {
        XCTAssertEqual(CategoryEngine.categorize("转账红包"), "转账")
    }

    func testCategorizeEntertainment() {
        XCTAssertEqual(CategoryEngine.categorize("购买电影票"), "娱乐")
    }

    func testCategorizeFallback() {
        XCTAssertEqual(CategoryEngine.categorize("一条没有关键词的记录"), "未分类")
    }
}