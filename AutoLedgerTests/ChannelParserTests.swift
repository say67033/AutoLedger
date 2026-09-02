import XCTest
@testable import AutoLedger

final class ChannelParserTests: XCTestCase {

    func testDetectWeChat() {
        XCTAssertEqual(ChannelParser.detect(lines: ["微信支付", "商户：某餐厅", "支付金额：¥25.00"]), .wechatPay)
    }

    func testDetectAlipay() {
        XCTAssertEqual(ChannelParser.detect(lines: ["支付宝", "交易成功", "金额 128.50元"]), .alipay)
    }

    func testDetectBankCard() {
        XCTAssertEqual(ChannelParser.detect(lines: ["招商银行", "信用卡 尾号1234", "消费金额 ¥99.00"]), .bankCard)
    }

    func testDetectMeituan() {
        XCTAssertEqual(ChannelParser.detect(lines: ["美团", "订单号 123456", "实付 ¥35.80"]), .meituan)
    }

    func testDetectDouyin() {
        XCTAssertEqual(ChannelParser.detect(lines: ["抖音", "支付成功", "¥12.00"]), .douyin)
    }

    func testDetectApplePay() {
        XCTAssertEqual(ChannelParser.detect(lines: ["Apple Pay", "已支付", "¥5.00"]), .applePay)
    }

    func testDetectOther() {
        XCTAssertEqual(ChannelParser.detect(lines: ["未知来源", "金额 10元"]), .other)
    }
}