import Foundation

enum BookSortOption: String, CaseIterable, Identifiable {
    case title = "Book Title"
    case author = "Author Name"
    case lastHighlightAsc = "Last Highlight (Oldest)"
    case lastHighlightDesc = "Last Highlight (Newest)"

    var id: String { rawValue }
}

enum HighlightSortOption: String, CaseIterable, Identifiable {
    case book = "By Book"
    case dateAsc = "Date (Oldest)"
    case dateDesc = "Date (Newest)"

    var id: String { rawValue }
}
