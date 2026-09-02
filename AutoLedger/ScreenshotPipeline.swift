import Foundation

final class ScreenshotPipeline {
    let store: LedgerStore

    init(store: LedgerStore) {
        self.store = store
    }

    @MainActor
    func process(ocrLines: [String], referenceDate: Date = .now) -> Transaction {
        let fullText = ocrLines.joined(separator: "\n")
        let receipt = ReceiptParser.parse(lines: ocrLines, referenceDate: referenceDate)
        let channel = ChannelParser.detect(lines: ocrLines)
        let category = CategoryEngine.categorize(fullText)

        return store.insertTransaction(
            amountInFen: receipt.amountInFen ?? 0,
            merchant: Self.merchantHint(from: ocrLines),
            channel: channel,
            date: receipt.date ?? referenceDate,
            categoryName: category,
            isConfirmed: false
        )
    }

    @MainActor
    func processLatestScreenshot() async throws -> Transaction {
        let image = try await ScreenshotLoader.fetchLatestScreenshotCGImage()
        let ocr = try OCRService().recognize(image)
        return process(ocrLines: ocr.lines)
    }

    static func merchantHint(from lines: [String]) -> String {
        let prefixes = ["商户", "收款方", "付款给", "商家"]
        for line in lines {
            for prefix in prefixes {
                guard let range = line.range(of: prefix) else { continue }
                let rest = line[range.upperBound...]
                    .trimmingCharacters(in: CharacterSet(charactersIn: "：: "))
                if !rest.isEmpty {
                    return rest
                }
            }
        }
        return "未知商户"
    }
}