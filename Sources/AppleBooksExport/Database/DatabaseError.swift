import Foundation

enum DatabaseError: LocalizedError {
    case databaseNotFound(String)
    case queryFailed(String)
    case noAnnotationsFound
    case attachFailed(String)

    var errorDescription: String? {
        switch self {
        case .databaseNotFound(let path):
            return "Database not found at: \(path). Make sure you have Apple Books installed and have highlighted at least one book."
        case .queryFailed(let message):
            return "Failed to query database: \(message)"
        case .noAnnotationsFound:
            return "No annotations found. Please highlight some text in Apple Books first."
        case .attachFailed(let message):
            return "Failed to attach database: \(message)"
        }
    }
}
