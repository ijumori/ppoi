import FirebaseFirestore
import Foundation

struct RankedQuote: Identifiable {
    let quote: Quote
    let totalVotes: Int
    let topReaction: String

    var id: String {
        quote.id
    }
}

final class RankingService {
    private let archiveService = ArchiveService()

    /// 直近 N 件の格言の投票数を集計してランキングを返す
    func fetchWeeklyRanking(limit: Int = 7) async -> [RankedQuote] {
        guard FirebaseBootstrap.isConfigured else { return [] }

        let quotes = await archiveService.fetchRecentQuotes(limit: limit)
        guard !quotes.isEmpty else { return [] }

        var ranked: [RankedQuote] = []

        await withTaskGroup(of: RankedQuote?.self) { group in
            for quote in quotes {
                group.addTask {
                    await self.fetchVotesAndRank(quote: quote)
                }
            }
            for await result in group {
                if let r = result { ranked.append(r) }
            }
        }

        return ranked
            .filter { $0.totalVotes > 0 }
            .sorted { $0.totalVotes > $1.totalVotes }
            .prefix(3)
            .map { $0 }
    }

    private func fetchVotesAndRank(quote: Quote) async -> RankedQuote? {
        do {
            let doc = try await Firestore.firestore()
                .collection("votes")
                .document(quote.date)
                .getDocument()

            guard let data = doc.data() else { return nil }

            let thinking = data["thinking"] as? Int ?? 0
            let laughing = data["laughing"] as? Int ?? 0
            let crying = data["crying"] as? Int ?? 0
            let fire = data["fire"] as? Int ?? 0
            let total = thinking + laughing + crying + fire

            let reactions = [
                ("🤔", thinking), ("😂", laughing),
                ("🥹", crying), ("🔥", fire),
            ]
            let top = reactions.max(by: { $0.1 < $1.1 })?.0 ?? "🔥"

            return RankedQuote(quote: quote, totalVotes: total, topReaction: top)
        } catch {
            return nil
        }
    }
}
