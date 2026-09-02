import SwiftUI
import SwiftData

@main
struct AutoLedgerApp: App {
    private let store: LedgerStore

    init() {
        store = LedgerStore()
        store.seedDefaultCategoriesIfNeeded()
    }

    var body: some Scene {
        WindowGroup {
            ContentView()
        }
        .modelContainer(store.container)
    }
}