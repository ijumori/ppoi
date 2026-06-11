import Foundation
import os.log

/// Release-safe logging. All output is suppressed in non-DEBUG builds.
/// Uses os_log subsystem for proper log management.
enum SecureLogger {
    private static let subsystem = "com.takahiro.ppoi"

    enum Category: String {
        case security
        case network
        case ads
        case general
    }

    static func debug(_ message: String, category: Category = .general) {
        #if DEBUG
            let logger = Logger(subsystem: subsystem, category: category.rawValue)
            logger.debug("\(message, privacy: .private)")
        #endif
    }

    static func info(_ message: String, category: Category = .general) {
        #if DEBUG
            let logger = Logger(subsystem: subsystem, category: category.rawValue)
            logger.info("\(message, privacy: .private)")
        #endif
    }

    static func error(_ message: String, category: Category = .general) {
        #if DEBUG
            let logger = Logger(subsystem: subsystem, category: category.rawValue)
            logger.error("\(message, privacy: .private)")
        #endif
    }
}
