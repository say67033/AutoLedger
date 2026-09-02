import SwiftUI
import SwiftData

struct ContentView: View {
    var body: some View {
        TabView {
            ConfirmListView()
                .tabItem {
                    Label("记账", systemImage: "checkmark.circle")
                }
            MonthlySummaryView()
                .tabItem {
                    Label("汇总", systemImage: "chart.pie")
                }
        }
    }
}

#Preview {
    ContentView()
        .modelContainer(for: [Transaction.self, LedgerCategory.self], inMemory: true)
}