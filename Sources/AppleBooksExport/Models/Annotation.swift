import Foundation

struct Annotation: Identifiable, Codable, Hashable {
    let id: Int
    var type: AnnotationType
    var color: AnnotationColor
    var text: String?
    var note: String?
    var location: String?
    var chapter: String?
    var createdAt: Date
    var modifiedAt: Date

    var hasText: Bool {
        text?.isEmpty == false
    }

    var hasNote: Bool {
        note?.isEmpty == false
    }

    var displayText: String {
        if let text = text, !text.isEmpty {
            return text
        }
        if let note = note, !note.isEmpty {
            return note
        }
        return "Bookmark"
    }
}
