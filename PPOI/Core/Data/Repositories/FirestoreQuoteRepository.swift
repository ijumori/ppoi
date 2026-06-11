import Foundation
import FirebaseFirestore

protocol QuoteRepository {
    func fetchQuote(for date: String) async throws -> Quote
}

enum QuoteRepositoryError: LocalizedError {
    case firebaseNotConfigured
    case untrustedEnvironment
    case documentNotFound(date: String)

    var errorDescription: String? {
        switch self {
        case .firebaseNotConfigured:
            "Firebase が未設定です。GoogleService-Info.plist を配置してください。"
        case .untrustedEnvironment:
            "セキュリティ上、ネットワークから格言を取得できません。キャッシュをご利用ください。"
        case let .documentNotFound(date):
            "今日（\(date)）の格言がまだ届いていません。"
        }
    }
}

final class FirestoreQuoteRepository: QuoteRepository {
    func fetchQuote(for date: String) async throws -> Quote {
        guard FirebaseBootstrap.isConfigured else {
            throw QuoteRepositoryError.firebaseNotConfigured
        }

        guard SecurityGuard.isEnvironmentTrusted else {
            throw QuoteRepositoryError.untrustedEnvironment
        }

        // configure 前に Firestore.firestore() を呼ぶとクラッシュするため、guard 後に取得
        let snapshot = try await Firestore.firestore()
            .collection("quotes")
            .document(date)
            .getDocument()

        guard snapshot.exists, let data = snapshot.data() else {
            throw QuoteRepositoryError.documentNotFound(date: date)
        }

        guard let text = data["text"] as? String,
              let toneRaw = data["tone"] as? String,
              let tone = QuoteTone(rawValue: toneRaw)
        else {
            throw QuoteRepositoryError.documentNotFound(date: date)
        }

        let interpretation = data["interpretation"] as? String
        let category = (data["category"] as? String).flatMap { QuoteCategory(rawValue: $0) }
        let question = data["question"] as? String
        return Quote(id: date, date: date, text: text, tone: tone, interpretation: interpretation, category: category, question: question)
    }
}
