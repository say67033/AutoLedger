import SwiftUI
import SwiftData

struct ConfirmListView: View {
    @Query(
        filter: #Predicate<Transaction> { !$0.isConfirmed },
        sort: \Transaction.date,
        order: .reverse
    )
    private var drafts: [Transaction]

    var body: some View {
        NavigationStack {
            Group {
                if drafts.isEmpty {
                    ContentUnavailableView(
                        "暂无待确认账单",
                        systemImage: "checkmark.circle",
                        description: Text("双击手机背面，自动读取最新截图")
                    )
                } else {
                    List {
                        ForEach(drafts) { tx in
                            NavigationLink {
                                DraftEditorView(transaction: tx)
                            } label: {
                                DraftRow(transaction: tx)
                            }
                        }
                    }
                }
            }
            .navigationTitle("待确认")
        }
    }
}

struct DraftRow: View {
    let transaction: Transaction

    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text(transaction.merchant)
                    .font(.headline)
                Text("\(transaction.channel.rawValue) · \(transaction.categoryName)")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
            Spacer()
            Text("¥\(transaction.amountString)")
                .font(.headline)
                .foregroundStyle(.orange)
        }
    }
}

struct DraftEditorView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext

    @Bindable var transaction: Transaction

    @State private var amountText: String
    @State private var merchant: String
    @State private var categoryName: String

    private let categories = LedgerStore.defaultCategories

    init(transaction: Transaction) {
        _amountText = State(initialValue: transaction.amountString)
        _merchant = State(initialValue: transaction.merchant)
        _categoryName = State(initialValue: transaction.categoryName)
        self.transaction = transaction
    }

    var body: some View {
        NavigationStack {
            Form {
                Section("金额") {
                    TextField("0.00", text: $amountText)
                        .keyboardType(.decimalPad)
                }
                Section("分类") {
                    Picker("分类", selection: $categoryName) {
                        ForEach(categories.indices, id: \.self) { index in
                            Label(categories[index].name, systemImage: categories[index].icon)
                                .tag(categories[index].name)
                        }
                    }
                }
                Section("商户") {
                    TextField("商户", text: $merchant)
                }
                Section {
                    Button {
                        confirm()
                    } label: {
                        Text("确认记账")
                            .frame(maxWidth: .infinity)
                    }
                    Button(role: .destructive) {
                        delete()
                    } label: {
                        Text("删除这条")
                            .frame(maxWidth: .infinity)
                    }
                }
            }
            .navigationTitle("确认记账")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("取消") { dismiss() }
                }
            }
        }
    }

    private func confirm() {
        let cleaned = amountText.replacingOccurrences(of: ",", with: "")
        let decimal = Decimal(string: cleaned) ?? 0
        let fen = NSDecimalNumber(decimal: decimal * 100).int64Value
        transaction.amountInFen = fen
        transaction.merchant = merchant.isEmpty ? "未知商户" : merchant
        transaction.categoryName = categoryName
        transaction.isConfirmed = true
        try? modelContext.save()
        dismiss()
    }

    private func delete() {
        modelContext.delete(transaction)
        try? modelContext.save()
        dismiss()
    }
}

#Preview {
    ConfirmListView()
        .modelContainer(for: [Transaction.self, LedgerCategory.self], inMemory: true)
}