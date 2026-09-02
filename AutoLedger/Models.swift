import Foundation
import SwiftData

enum PaymentChannel: String, Codable, CaseIterable {
    case wechatPay = "微信支付"
    case alipay = "支付宝"
    case bankCard = "银行卡"
    case meituan = "美团"
    case douyin = "抖音"
    case applePay = "ApplePay"
    case other = "其他"
}

@Model
final class Category {
    @Attribute(.unique) var name: String
    var icon: String
    var keywords: [String]

    init(name: String, icon: String, keywords: [String]) {
        self.name = name
        self.icon = icon
        self.keywords = keywords
    }
}

@Model
final class Transaction {
    @Attribute(.unique) var id: UUID
    var amountInFen: Int64
    var merchant: String
    var channelRawValue: String
    var date: Date
    var categoryName: String
    var sourceImageFileName: String?
    var isConfirmed: Bool
    var note: String?

    init(
        id: UUID = UUID(),
        amountInFen: Int64,
        merchant: String,
        channel: PaymentChannel = .other,
        date: Date = .now,
        categoryName: String = "未分类",
        sourceImageFileName: String? = nil,
        isConfirmed: Bool = false,
        note: String? = nil
    ) {
        self.id = id
        self.amountInFen = amountInFen
        self.merchant = merchant
        self.channelRawValue = channel.rawValue
        self.date = date
        self.categoryName = categoryName
        self.sourceImageFileName = sourceImageFileName
        self.isConfirmed = isConfirmed
        self.note = note
    }

    var channel: PaymentChannel {
        PaymentChannel(rawValue: channelRawValue) ?? .other
    }

    var amount: Decimal {
        Decimal(amountInFen) / 100
    }
}