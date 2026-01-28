import Foundation

struct Book: Identifiable, Codable, Hashable {
    let assetId: String
    var title: String?
    var author: String?
    var genre: String?
    var annotations: [Annotation]

    var id: String { assetId }

    var displayTitle: String {
        title ?? "Unknown Book"
    }

    var displayAuthor: String {
        author ?? "Unknown Author"
    }

    var highlightCount: Int {
        annotations.filter { $0.type == .highlight }.count
    }

    var bookmarkCount: Int {
        annotations.filter { $0.type == .bookmark }.count
    }

    var noteCount: Int {
        annotations.filter { $0.type == .note }.count
    }

    var annotationCount: Int {
        annotations.count
    }
}
