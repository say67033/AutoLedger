import Foundation

struct ParsedReceipt {
    var amountInFen: Int64?
    var date: Date?
}

enum ReceiptParser {
    static func parse(lines: [String], referenceDate: Date = .now, calendar: Calendar = .current) -> ParsedReceipt {
        var result = ParsedReceipt()
        for line in lines {
            if result.amountInFen == nil {
                result.amountInFen = parseAmount(line)
            }
            if result.date == nil {
                result.date = parseDate(line, referenceDate: referenceDate, calendar: calendar)
            }
            if result.amountInFen != nil && result.date != nil {
                break
            }
        }
        return result
    }

    static func parseAmount(_ text: String) -> Int64? {
        for pattern in amountPatterns {
            if let token = capture(group: 1, pattern: pattern, in: text), let fen = fen(from: token) {
                return fen
            }
        }
        if containsAmountKeyword(text),
           let token = capture(group: 1, pattern: rawNumberPattern, in: text),
           let fen = fen(from: token) {
            return fen
        }
        return nil
    }

    static func parseDate(_ text: String, referenceDate: Date = .now, calendar: Calendar = .current) -> Date? {
        guard let regex = try? NSRegularExpression(pattern: dateTokenPattern) else { return nil }
        let range = NSRange(text.startIndex..<text.endIndex, in: text)
        guard let match = regex.firstMatch(in: text, range: range) else { return nil }

        func intGroup(_ index: Int) -> Int? {
            guard match.numberOfRanges > index, let r = Range(match.range(at: index), in: text) else { return nil }
            return Int(String(text[r]))
        }

        var components = DateComponents()
        if let year = intGroup(1) {
            components.year = year
        } else {
            components.year = calendar.component(.year, from: referenceDate)
        }
        guard let month = intGroup(2), let day = intGroup(3) else { return nil }
        components.month = month
        components.day = day
        components.hour = intGroup(4)
        components.minute = intGroup(5)
        components.second = intGroup(6)
        return calendar.date(from: components)
    }

    private static let amountPatterns = [
        #"[¥￥]\s*(-?\d+(?:\.\d{1,2})?)"#,
        #"(-?\d+(?:\.\d{1,2})?)\s*元"#,
    ]

    private static let rawNumberPattern = #"(-?\d+(?:\.\d{1,2})?)"#

    private static let dateTokenPattern = #"(?:(\d{4})[年/\-.\s]*)?(\d{1,2})[月/\-.](\d{1,2})日?(?:\s+(\d{1,2}):(\d{2})(?::(\d{2}))?)?"#

    private static let amountKeywords = ["实付", "应付", "支付金额", "付款金额", "实付款", "消费金额", "金额", "合计", "扣款"]

    private static func containsAmountKeyword(_ text: String) -> Bool {
        amountKeywords.contains { text.contains($0) }
    }

    private static func capture(group: Int, pattern: String, in text: String) -> String? {
        guard let regex = try? NSRegularExpression(pattern: pattern) else { return nil }
        let range = NSRange(text.startIndex..<text.endIndex, in: text)
        guard let match = regex.firstMatch(in: text, range: range) else { return nil }
        guard match.numberOfRanges > group, let r = Range(match.range(at: group), in: text) else { return nil }
        return String(text[r])
    }

    private static func fen(from decimalString: String) -> Int64? {
        var s = decimalString
        var sign: Int64 = 1
        if s.hasPrefix("-") {
            sign = -1
            s.removeFirst()
        } else if s.hasPrefix("+") {
            s.removeFirst()
        }

        let parts = s.split(separator: ".", omittingEmptySubsequences: false)
        guard let yuan = Int64(String(parts[0])) else { return nil }

        var cents: Int64 = 0
        if parts.count > 1 {
            var fraction = String(parts[1])
            if fraction.count < 2 {
                fraction += "0"
            } else if fraction.count > 2 {
                fraction = String(fraction.prefix(2))
            }
            cents = Int64(fraction) ?? 0
        }
        return sign * (yuan * 100 + cents)
    }
}