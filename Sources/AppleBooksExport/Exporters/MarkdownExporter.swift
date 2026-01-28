import Foundation

struct MarkdownExporter {
    private static let colorEmoji: [AnnotationColor: String] = [
        .yellow: "🟡",
        .green: "🟢",
        .blue: "🔵",
        .pink: "🔴",
        .purple: "🟣",
        .underline: "➖"
    ]

    private static let typeEmoji: [AnnotationType: String] = [
        .highlight: "✨",
        .bookmark: "📌",
        .note: "📝"
    ]

    static func export(books: [Book]) -> String {
        let totalAnnotations = books.reduce(0) { $0 + $1.annotationCount }
        let totalHighlights = books.reduce(0) { $0 + $1.highlightCount }
        let totalBookmarks = books.reduce(0) { $0 + $1.bookmarkCount }
        let totalNotes = books.reduce(0) { $0 + $1.noteCount }

        var content = ""

        // YAML frontmatter
        content += "---\n"
        content += "title: \"Apple Books Export\"\n"
        content += "exported: \"\(ISO8601DateFormatter().string(from: Date()))\"\n"
        content += "totalBooks: \(books.count)\n"
        content += "totalAnnotations: \(totalAnnotations)\n"
        content += "highlights: \(totalHighlights)\n"
        content += "bookmarks: \(totalBookmarks)\n"
        content += "notes: \(totalNotes)\n"
        content += "---\n\n"

        // Header
        content += "# Apple Books Export\n\n"
        content += "Exported \(totalAnnotations) annotations from \(books.count) books\n\n"
        content += "---\n\n"

        // Add each book
        for book in books {
            guard !book.annotations.isEmpty else { continue }

            content += "# \(book.displayTitle)\n"
            if let author = book.author {
                content += "**by \(author)**\n"
            }
            content += "\n*\(book.annotationCount) annotations*\n"

            for annotation in book.annotations {
                content += formatAnnotation(annotation)
            }

            content += "\n\n"
        }

        return content
    }

    private static func formatAnnotation(_ annotation: Annotation) -> String {
        let colorEmoji = colorEmoji[annotation.color] ?? "⚪"
        let typeEmoji = typeEmoji[annotation.type] ?? "📄"

        var markdown = "\n## \(colorEmoji) \(typeEmoji) \(annotation.type.rawValue.capitalized)"

        if let location = annotation.location {
            markdown += " - \(location)"
        }

        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = .long
        dateFormatter.timeStyle = .short
        markdown += "\n**Created:** \(dateFormatter.string(from: annotation.createdAt))\n"

        if let text = annotation.text, !text.isEmpty {
            let quotedText = text.components(separatedBy: "\n").map { "> \($0)" }.joined(separator: "\n")
            markdown += "\n\(quotedText)\n"
        }

        if let note = annotation.note, !note.isEmpty {
            markdown += "\n**Note:** *\(note)*\n"
        }

        markdown += "\n---\n"

        return markdown
    }
}
