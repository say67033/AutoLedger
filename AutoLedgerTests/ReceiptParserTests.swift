import XCTest
@testable import AutoLedger

final class ReceiptParserTests: XCTestCase {

    func testParseAmountWithCurrencySymbol() {
        XCTAssertEqual(ReceiptParser.parseAmount("¥25.00"), 2500)
        XCTAssertEqual(ReceiptParser.parseAmount("￥128.50"), 12850)
        XCTAssertEqual(ReceiptParser.parseAmount("微信支付 ¥89.90"), 8990)
    }

    func testParseAmountWithYuanSuffix() {
        XCTAssertEqual(ReceiptParser.parseAmount("25.00元"), 2500)
        XCTAssertEqual(ReceiptParser.parseAmount("-25.00元"), -2500)
        XCTAssertEqual(ReceiptParser.parseAmount("实付 520元"), 52000)
    }

    func testParseAmountWithKeywordOnly() {
        XCTAssertEqual(ReceiptParser.parseAmount("实付金额：25.00"), 2500)
        XCTAssertEqual(ReceiptParser.parseAmount("支付金额 9.9"), 990)
    }

    func testParseAmountFractionPrecision() {
        XCTAssertEqual(ReceiptParser.parseAmount("¥25.5"), 2550)
        XCTAssertEqual(ReceiptParser.parseAmount("¥25"), 2500)
        XCTAssertEqual(ReceiptParser.parseAmount("¥0.05"), 5)
    }

    func testParseFullDate() {
        let calendar = Calendar(identifier: .gregorian)
        let date = ReceiptParser.parseDate("交易时间：2026-09-02 09:50:44", calendar: calendar)
        XCTAssertNotNil(date)
        guard let date else { return }
        XCTAssertEqual(calendar.component(.year, from: date), 2026)
        XCTAssertEqual(calendar.component(.month, from: date), 9)
        XCTAssertEqual(calendar.component(.day, from: date), 2)
        XCTAssertEqual(calendar.component(.hour, from: date), 9)
        XCTAssertEqual(calendar.component(.minute, from: date), 50)
    }

    func testParseChineseDate() {
        let calendar = Calendar(identifier: .gregorian)
        let date = ReceiptParser.parseDate("2026年9月2日 09:50", calendar: calendar)
        XCTAssertNotNil(date)
        guard let date else { return }
        XCTAssertEqual(calendar.component(.year, from: date), 2026)
        XCTAssertEqual(calendar.component(.month, from: date), 9)
        XCTAssertEqual(calendar.component(.day, from: date), 2)
    }

    func testParseMonthDayWithoutYear() {
        let calendar = Calendar(identifier: .gregorian)
        let reference = calendar.date(from: DateComponents(year: 2026, month: 9, day: 2))!
        let date = ReceiptParser.parseDate("09-02 09:50", referenceDate: reference, calendar: calendar)
        XCTAssertNotNil(date)
        guard let date else { return }
        XCTAssertEqual(calendar.component(.year, from: date), 2026)
        XCTAssertEqual(calendar.component(.month, from: date), 9)
        XCTAssertEqual(calendar.component(.day, from: date), 2)
    }

    func testParseLinesExtractsAmountAndDate() {
        let calendar = Calendar(identifier: .gregorian)
        let lines = [
            "微信支付",
            "商户：某餐厅",
            "交易时间：2026-09-02 09:50:44",
            "支付金额：¥89.90",
        ]
        let receipt = ReceiptParser.parse(lines: lines, calendar: calendar)
        XCTAssertEqual(receipt.amountInFen, 8990)
        XCTAssertEqual(calendar.component(.month, from: receipt.date!), 9)
        XCTAssertEqual(calendar.component(.day, from: receipt.date!), 2)
    }
}