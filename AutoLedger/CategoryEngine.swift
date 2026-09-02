import Foundation

enum CategoryEngine {
    static func categorize(
        _ text: String,
        using categories: [(name: String, icon: String, keywords: [String])] = LedgerStore.defaultCategories
    ) -> String {
        var bestName = "未分类"
        var bestScore = 0
        for category in categories {
            var score = 0
            for keyword in category.keywords where !keyword.isEmpty {
                if text.contains(keyword) {
                    score += keyword.count
                }
            }
            if score > bestScore {
                bestScore = score
                bestName = category.name
            }
        }
        return bestName
    }
}