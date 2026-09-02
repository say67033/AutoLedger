import AppIntents
import Foundation

struct CaptureLatestScreenshotIntent: AppIntent {
    static var title: LocalizedStringResource = "自动记账"
    static let description = IntentDescription("读取最新截图，自动识别金额、渠道与分类并记账")
    static var openAppWhenRun: Bool = true

    @MainActor
    func perform() async throws -> some IntentResult {
        let pipeline = ScreenshotPipeline(store: .shared)
        _ = try await pipeline.processLatestScreenshot()
        return .result()
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