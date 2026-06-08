import FirebaseFirestore
import Foundation

enum Reaction: String, CaseIterable, Identifiable {
    case thinking  // 🤔
    case laughing  // 😂
    case crying    // 🥹
    case fire      // 🔥

    var id: String { rawValue }

    var emoji: String {
        switch self {
        case .thinking: "🤔"
        case .laughing: "😂"
        case .crying: "🥹"
        case .fire: "🔥"
        }
    }
}

struct VoteCounts: Equatable {
    var thinking: Int = 0
    var laughing: Int = 0
    var crying: Int = 0
    var fire: Int = 0

    func count(for reaction: Reaction) -> Int {
        switch reaction {
        case .thinking: thinking
        case .laughing: laughing
        case .crying: crying
        case .fire: fire
        }
    }

    var total: Int { thinking + laughing + crying + fire }
}

final class VoteService {
    private let collection = "votes"

    func fetchCounts(for date: String) async -> VoteCounts {
        guard FirebaseBootstrap.isConfigured else { return VoteCounts() }

        do {
            let doc = try await Firestore.firestore()
                .collection(collection)
                .document(date)
                .getDocument()

            guard let data = doc.data() else { return VoteCounts() }

            return VoteCounts(
                thinking: data["thinking"] as? Int ?? 0,
                laughing: data["laughing"] as? Int ?? 0,
                crying: data["crying"] as? Int ?? 0,
                fire: data["fire"] as? Int ?? 0
            )
        } catch {
            return VoteCounts()
        }
    }

    func vote(date: String, reaction: Reaction, previousReaction: Reaction?) async {
        guard FirebaseBootstrap.isConfigured else { return }

        let docRef = Firestore.firestore()
            .collection(collection)
            .document(date)

        var updates: [String: Any] = [
            reaction.rawValue: FieldValue.increment(Int64(1))
        ]
        if let previous = previousReaction, previous != reaction {
            updates[previous.rawValue] = FieldValue.increment(Int64(-1))
        }

        try? await docRef.setData(updates, merge: true)
    }
}
