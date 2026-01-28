import Foundation

struct CSVExporter {
    static func export(books: [Book]) -> String {
        // CSV header
        let headers = [
            "assetId", "title", "author", "genre",
            "annotationId", "type", "color",
            "text", "note", "location", "chapter",
            "createdAt", "modifiedAt"
        ]

        var csv = headers.joined(separator: ",") + "\n"

        // Add rows
        for book in books {
            for annotation in book.annotations {
                let row = [
                    escapeCsvField(book.assetId),
                    escapeCsvField(book.title),
                    escapeCsvField(book.author),
                    escapeCsvField(book.genre),
                    escapeCsvField(String(annotation.id)),
                    escapeCsvField(annotation.type.rawValue),
                    escapeCsvField(annotation.color.rawValue),
                    escapeCsvField(annotation.text),
                    escapeCsvField(annotation.note),
                    escapeCsvField(annotation.location),
                    escapeCsvField(annotation.chapter),
                    escapeCsvField(formatDate(annotation.createdAt)),
                    escapeCsvField(formatDate(annotation.modifiedAt))
                ]

                csv += row.joined(separator: ",") + "\n"
            }
        }

        return csv
    }

    private static func escapeCsvField(_ value: String?) -> String {
        guard let value = value, !value.isEmpty else {
            return ""
        }

        // If the value contains quotes, commas, or newlines, it needs to be quoted
        if value.contains("\"") || value.contains(",") || value.contains("\n") {
            // Escape quotes by doubling them
            return "\"\(value.replacingOccurrences(of: "\"", with: "\"\""))\""
        }

        return value
    }

    private static func formatDate(_ date: Date) -> String {
        let formatter = ISO8601DateFormatter()
        return formatter.string(from: date).replacingOccurrences(of: "T", with: " ").prefix(19).description
    }
}
