import CryptoKit
import Foundation

/// 格言キャッシュを Keychain + AES-GCM で保護（UserDefaults 平文保存を廃止）
enum SecureQuoteCache {
    private struct Payload: Codable {
        let date: String
        let text: String
        let tone: String
    }

    static func save(_ quote: Quote) {
        let payload = Payload(date: quote.date, text: quote.text, tone: quote.tone.rawValue)
        guard let plain = try? JSONEncoder().encode(payload) else { return }

        do {
            let key = try KeychainStore.encryptionKey()
            let sealed = try AES.GCM.seal(plain, using: key)
            guard let combined = sealed.combined else { return }
            try KeychainStore.save(combined, for: .quoteCache)
        } catch {
            SecureLogger.error("quote cache encrypt failed: \(error)", category: .security)
        }
    }

    static func load(for date: String) -> Quote? {
        guard let combined = try? KeychainStore.load(for: .quoteCache) else { return nil }

        do {
            let key = try KeychainStore.encryptionKey()
            let box = try AES.GCM.SealedBox(combined: combined)
            let plain = try AES.GCM.open(box, using: key)
            let payload = try JSONDecoder().decode(Payload.self, from: plain)
            guard payload.date == date,
                  let tone = QuoteTone(rawValue: payload.tone)
            else { return nil }
            return Quote(id: payload.date, date: payload.date, text: payload.text, tone: tone)
        } catch {
            KeychainStore.delete(.quoteCache)
            return nil
        }
    }

    static func clearLegacyUserDefaults(_ defaults: UserDefaults) {
        defaults.removeObject(forKey: "cachedQuoteDate")
        defaults.removeObject(forKey: "cachedQuoteText")
        defaults.removeObject(forKey: "cachedQuoteTone")
    }
}
