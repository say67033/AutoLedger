import Foundation

struct CategoryTotal: Identifiable {
    var id: String { category }
    let category: String
    let totalInFen: Int64

    var total: Decimal {
        Decimal(totalInFen) / 100
    }

    var totalString: String {
        String(format: "¥%.2f", NSDecimalNumber(decimal: total).doubleValue)
    }
}

struct MonthlySummary {
    let month: Date
    let totalInFen: Int64
    let byCategory: [CategoryTotal]

    var total: Decimal {
        Decimal(totalInFen) / 100
    }

    var totalString: String {
        String(format: "¥%.2f", NSDecimalNumber(decimal: total).doubleValue)
    }
}

enum LedgerAggregator {
    static func monthRange(containing date: Date, calendar: Calendar = .current) -> (start: Date, end: Date) {
        let components = calendar.dateComponents([.year, .month], from: date)
        let start = calendar.date(from: components) ?? date
        let end = calendar.date(byAdding: .month, value: 1, to: start) ?? start
        return (start, end)
    }

    static func summarize(transactions: [Transaction], in month: Date, calendar: Calendar = .current) -> MonthlySummary {
        let range = monthRange(containing: month, calendar: calendar)
        let filtered = transactions.filter { $0.date >= range.start && $0.date < range.end }
        let total = filtered.reduce(Int64(0)) { $0 + $1.amountInFen }

        let grouped = Dictionary(grouping: filtered, by: { $0.categoryName })
        let byCategory = grouped.map { (key: String, value: [Transaction]) -> CategoryTotal in
            let sum = value.reduce(Int64(0)) { $0 + $1.amountInFen }
            return CategoryTotal(category: key, totalInFen: sum)
        }
        .sorted { $0.totalInFen > $1.totalInFen }

        return MonthlySummary(month: range.start, totalInFen: total, byCategory: byCategory)
    }
}