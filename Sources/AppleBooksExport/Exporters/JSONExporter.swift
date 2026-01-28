import Foundation

struct JSONExporter {
    struct ExportData: Codable {
        let exported: String
        let totalBooks: Int
        let totalAnnotations: Int
        let statistics: Statistics
        let books: [BookData]

        struct Statistics: Codable {
            let highlights: Int
            let bookmarks: Int
            let notes: Int
        }

        struct BookData: Codable {
            let assetId: String
            let title: String?
            let author: String?
            let genre: String?
            let annotationCount: Int
            let annotations: [AnnotationData]
        }

        struct AnnotationData: Codable {
            let id: Int
            let type: String
            let color: String
            let text: String?
            let note: String?
            let location: String?
            let chapter: String?
            let createdAt: String
            let modifiedAt: String
        }
    }

    static func export(books: [Book]) throws -> String {
        let totalAnnotations = books.reduce(0) { $0 + $1.annotationCount }
        let totalHighlights = books.reduce(0) { $0 + $1.highlightCount }
        let totalBookmarks = books.reduce(0) { $0 + $1.bookmarkCount }
        let totalNotes = books.reduce(0) { $0 + $1.noteCount }

        let isoFormatter = ISO8601DateFormatter()

        let exportData = ExportData(
            exported: isoFormatter.string(from: Date()),
            totalBooks: books.count,
            totalAnnotations: totalAnnotations,
            statistics: ExportData.Statistics(
                highlights: totalHighlights,
                bookmarks: totalBookmarks,
                notes: totalNotes
            ),
            books: books.map { book in
                ExportData.BookData(
                    assetId: book.assetId,
                    title: book.title,
                    author: book.author,
                    genre: book.genre,
                    annotationCount: book.annotationCount,
                    annotations: book.annotations.map { annotation in
                        ExportData.AnnotationData(
                            id: annotation.id,
                            type: annotation.type.rawValue,
                            color: annotation.color.rawValue,
                            text: annotation.text,
                            note: annotation.note,
                            location: annotation.location,
                            chapter: annotation.chapter,
                            createdAt: isoFormatter.string(from: annotation.createdAt),
                            modifiedAt: isoFormatter.string(from: annotation.modifiedAt)
                        )
                    }
                )
            }
        )

        let encoder = JSONEncoder()
        encoder.outputFormatting = [.prettyPrinted, .sortedKeys]
        let jsonData = try encoder.encode(exportData)

        guard let jsonString = String(data: jsonData, encoding: .utf8) else {
            throw ExportError.exportFailed("Failed to convert JSON data to string")
        }

        return jsonString
    }
}
