import AppIntents
import Foundation

struct CaptureLatestScreenshotIntent: AppIntent {
    static var title: LocalizedStringResource = "自动记账"
    static let description = IntentDescription("读取最新截图，自动识别金额、渠道与分类并记账")
    static var openAppWhenRun: Bool = true

    @MainActor
    func perform() async throws -> some IntentResult {
        let store = LedgerStore.shared
        store.seedDefaultCategoriesIfNeeded()

        do {
            let tx = try await ScreenshotPipeline(store: store).processLatestScreenshot()
            return .result(dialog: IntentDialog("已识别 ¥\(tx.amountString) · \(tx.merchant)，请在「待确认」中核对"))
        } catch {
            return .result(dialog: IntentDialog("没有读取到可用的截图，请先截图，再双击背面重试"))
        }
    }
}

struct AutoLedgerShortcuts: AppShortcutsProvider {
    static var appShortcuts: [AppShortcut] {
        AppShortcut(
            intent: CaptureLatestScreenshotIntent(),
            phrases: ["自动记账", "记账"],
            shortTitle: "自动记账",
            systemImageName: "camera.on.rectangle"
        )
    }
}