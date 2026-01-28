import Foundation
import GRDB

class AppleBooksDatabase {
    private let annotationsDbPath: String
    private let libraryDbPath: String

    private static let appleBooksContainer = FileManager.default.homeDirectoryForCurrentUser
        .appendingPathComponent("Library/Containers/com.apple.iBooksX/Data/Documents")

    // Apple epoch starts at 2001-01-01 00:00:00 UTC
    // Unix epoch starts at 1970-01-01 00:00:00 UTC
    // Difference is 978307200 seconds
    private static let appleEpochOffset: TimeInterval = 978307200

    init(annotationsDbPath: String, libraryDbPath: String) {
        self.annotationsDbPath = annotationsDbPath
        self.libraryDbPath = libraryDbPath
    }

    static func findDatabases() throws -> AppleBooksDatabase {
        let fileManager = FileManager.default

        // Find AEAnnotation database
        let annotationsDir = appleBooksContainer.appendingPathComponent("AEAnnotation")
        guard fileManager.fileExists(atPath: annotationsDir.path) else {
            throw DatabaseError.databaseNotFound(annotationsDir.path)
        }

        let annotationFiles = try fileManager.contentsOfDirectory(atPath: annotationsDir.path)
            .filter { $0.hasPrefix("AEAnnotation_") && $0.hasSuffix(".sqlite") }

        guard let annotationFile = annotationFiles.first else {
            throw DatabaseError.databaseNotFound("No annotation database found in \(annotationsDir.path)")
        }

        let annotationsDbPath = annotationsDir.appendingPathComponent(annotationFile).path

        // Find BKLibrary database
        let libraryDir = appleBooksContainer.appendingPathComponent("BKLibrary")
        guard fileManager.fileExists(atPath: libraryDir.path) else {
            throw DatabaseError.databaseNotFound(libraryDir.path)
        }

        let libraryFiles = try fileManager.contentsOfDirectory(atPath: libraryDir.path)
            .filter { $0.hasPrefix("BKLibrary") && $0.hasSuffix(".sqlite") }

        guard let libraryFile = libraryFiles.first else {
            throw DatabaseError.databaseNotFound("No library database found in \(libraryDir.path)")
        }

        let libraryDbPath = libraryDir.appendingPathComponent(libraryFile).path

        return AppleBooksDatabase(annotationsDbPath: annotationsDbPath, libraryDbPath: libraryDbPath)
    }

    func loadBooks() throws -> [Book] {
        try queryAndGroupAnnotations()
    }

    private func queryAndGroupAnnotations() throws -> [Book] {
        let dbQueue = try DatabaseQueue(path: annotationsDbPath)

        let books = try dbQueue.read { db in
            // Attach the library database
            try db.execute(sql: "ATTACH DATABASE ? AS library", arguments: [libraryDbPath])

            let query = """
                SELECT
                    ZAEANNOTATION.Z_PK as id,
                    ZAEANNOTATION.ZANNOTATIONASSETID as assetId,
                    ZAEANNOTATION.ZANNOTATIONSELECTEDTEXT as text,
                    ZAEANNOTATION.ZANNOTATIONNOTE as note,
                    ZAEANNOTATION.ZANNOTATIONSTYLE as style,
                    ZAEANNOTATION.ZFUTUREPROOFING5 as location,
                    ZAEANNOTATION.ZANNOTATIONCREATIONDATE as createdAt,
                    ZAEANNOTATION.ZANNOTATIONMODIFICATIONDATE as modifiedAt,
                    library.ZBKLIBRARYASSET.ZTITLE as title,
                    library.ZBKLIBRARYASSET.ZAUTHOR as author,
                    library.ZBKLIBRARYASSET.ZGENRE as genre
                FROM ZAEANNOTATION
                LEFT JOIN library.ZBKLIBRARYASSET
                    ON ZAEANNOTATION.ZANNOTATIONASSETID = library.ZBKLIBRARYASSET.ZASSETID
                WHERE ZAEANNOTATION.ZANNOTATIONDELETED = 0
                ORDER BY title, createdAt
                """

            let rows = try Row.fetchAll(db, sql: query)

            // Group annotations by book
            var bookMap: [String: Book] = [:]

            for row in rows {
                let assetId: String = row["assetId"]
                let rawText: String? = row["text"]
                let rawNote: String? = row["note"]
                let style: Int = row["style"]
                let createdAtTimestamp: Double = row["createdAt"]
                let modifiedAtTimestamp: Double = row["modifiedAt"]

                // Get or create book
                if bookMap[assetId] == nil {
                    bookMap[assetId] = Book(
                        assetId: assetId,
                        title: row["title"],
                        author: row["author"],
                        genre: row["genre"],
                        annotations: []
                    )
                }

                // Determine annotation type
                let type = self.determineAnnotationType(text: rawText, note: rawNote)
                let color = self.mapAnnotationStyle(style)

                let annotation = Annotation(
                    id: row["id"],
                    type: type,
                    color: color,
                    text: rawText,
                    note: rawNote,
                    location: row["location"],
                    chapter: nil,
                    createdAt: self.convertAppleDate(createdAtTimestamp),
                    modifiedAt: self.convertAppleDate(modifiedAtTimestamp)
                )

                bookMap[assetId]?.annotations.append(annotation)
            }

            return Array(bookMap.values).sorted { ($0.title ?? "") < ($1.title ?? "") }
        }

        if books.isEmpty {
            throw DatabaseError.noAnnotationsFound
        }

        return books
    }

    // MARK: - Helper Methods

    private func convertAppleDate(_ timestamp: Double) -> Date {
        Date(timeIntervalSince1970: timestamp + Self.appleEpochOffset)
    }

    private func mapAnnotationStyle(_ style: Int) -> AnnotationColor {
        // Based on research:
        // 0 = underline (highlight)
        // 1 = green highlight
        // 2 = blue highlight
        // 3 = yellow highlight
        // 4 = pink highlight
        // 5 = purple highlight
        switch style {
        case 0: return .underline
        case 1: return .green
        case 2: return .blue
        case 3: return .yellow
        case 4: return .pink
        case 5: return .purple
        default: return .yellow
        }
    }

    private func determineAnnotationType(text: String?, note: String?) -> AnnotationType {
        // If it has a note, it's a note annotation
        if let note = note, !note.trimmingCharacters(in: .whitespaces).isEmpty {
            return .note
        }

        // If it has no selected text, it's a bookmark
        if text == nil || text?.trimmingCharacters(in: .whitespaces).isEmpty == true {
            return .bookmark
        }

        // Otherwise it's a highlight
        return .highlight
    }
}
