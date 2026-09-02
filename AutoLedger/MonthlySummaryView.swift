import SwiftUI
import SwiftData

struct MonthlySummaryView: View {
    @Query(
        filter: #Predicate<Transaction> { $0.isConfirmed },
        sort: \Transaction.date,
        order: .reverse
    )
    private var transactions: [Transaction]

    @State private var month: Date = .now

    private var summary: MonthlySummary {
        LedgerAggregator.summarize(transactions: transactions, in: month)
    }

    var body: some View {
        NavigationStack {
            List {
                Section {
                    HStack {
                        Button {
                            shiftMonth(-1)
                        } label: {
                            Image(systemName: "chevron.left")
                        }
                        Spacer()
                        Text(month, format: .dateTime.year().month())
                            .font(.headline)
                        Spacer()
                        Button {
                            shiftMonth(1)
                        } label: {
                            Image(systemName: "chevron.right")
                        }
                    }
                    .buttonStyle(.borderless)
                }

                Section {
                    VStack(spacing: 8) {
                        Text(summary.totalString)
                            .font(.system(size: 42, weight: .bold))
                        Text("本月支出")
                            .foregroundStyle(.secondary)
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 8)
                }

                if summary.byCategory.isEmpty {
                    Section {
                        Text("本月暂无记账")
                            .foregroundStyle(.secondary)
                    }
                } else {
                    Section("分类明细") {
                        ForEach(summary.byCategory) { item in
                            HStack {
                                Label(item.category, systemImage: icon(for: item.category))
                                Spacer()
                                Text(item.totalString)
                                    .foregroundStyle(.secondary)
                            }
                        }
                    }
                }
            }
            .navigationTitle("月度汇总")
        }
    }

    private func shiftMonth(_ value: Int) {
        guard let newMonth = Calendar.current.date(byAdding: .month, value: value, to: month) else {
            return
        }
        month = newMonth
    }

    private func icon(for category: String) -> String {
        LedgerStore.defaultCategories.first { $0.name == category }?.icon ?? "ellipsis.circle"
    }
}

#Preview {
    MonthlySummaryView()
        .modelContainer(for: [Transaction.self, LedgerCategory.self], inMemory: true)
}