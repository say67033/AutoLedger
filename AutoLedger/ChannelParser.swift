import Foundation

enum ChannelParser {
    static func detect(lines: [String]) -> PaymentChannel {
        detect(fullText: lines.joined(separator: "\n"))
    }

    static func detect(fullText text: String) -> PaymentChannel {
        let lowercased = text.lowercased()

        if text.contains("美团") {
            return .meituan
        }
        if text.contains("抖音") {
            return .douyin
        }
        if text.contains("支付宝") || text.contains("花呗") || text.contains("余额宝") || lowercased.contains("alipay") {
            return .alipay
        }
        if text.contains("微信支付") || text.contains("微信") || text.contains("零钱") || lowercased.contains("wechat") {
            return .wechatPay
        }
        if lowercased.contains("apple pay") || lowercased.contains("applepay") {
            return .applePay
        }
        if text.contains("银行") || text.contains("信用卡") || text.contains("储蓄卡") || text.contains("借记卡") || text.contains("银联") || text.contains("尾号") {
            return .bankCard
        }
        return .other
    }
}