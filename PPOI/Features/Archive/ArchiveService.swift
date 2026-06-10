import FirebaseFirestore
import Foundation

final class ArchiveService {
    func fetchRecentQuotes(limit: Int = 30) async -> [Quote] {
        guard FirebaseBootstrap.isConfigured,
              SecurityGuard.isEnvironmentTrusted
        else { return [] }

        do {
            let snapshot = try await Firestore.firestore()
                .collection("quotes")
                .order(by: FieldPath.documentID(), descending: true)
                .limit(to: limit)
                .getDocuments()

            return snapshot.documents.compactMap { doc -> Quote? in
                let data = doc.data()
                guard let text = data["text"] as? String,
                      let toneRaw = data["tone"] as? String,
                      let tone = QuoteTone(rawValue: toneRaw)
                else { return nil }
                let interpretation = data["interpretation"] as? String
                let category = (data["category"] as? String).flatMap { QuoteCategory(rawValue: $0) }
                let question = data["question"] as? String
                return Quote(id: doc.documentID, date: doc.documentID, text: text, tone: tone, interpretation: interpretation, category: category, question: question)
            }
        } catch {
            return []
        }
    }
}
